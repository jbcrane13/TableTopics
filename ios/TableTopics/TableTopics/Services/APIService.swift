// APIService.swift
// Table Topics API Service - wraps Shovels.ai API for commercial project leads

import B2BCore
import Foundation

/// Mutable state container for thread-safe access
private final class APIState: @unchecked Sendable {
    var apiKey: String?
    var creditsUsed: Int = 0
    var creditsRemaining: Int = 250
    var enrichmentProvider: ContactEnrichmentService.EnrichmentProvider = .patternMatching
    
    /// Test mode: enrich first lead with Apollo, next 5 with Hunter only
    var testModeEnabled = false
    var testModeApolloCount = 1  // First N leads use Apollo
    var testModeHunterCount = 5  // Next N leads use Hunter only
    
    init(apiKey: String?) {
        self.apiKey = apiKey
    }
}

/// Default API key (Shovels free tier - 250 credits)
private let defaultAPIKey = "k08-LvykVPjfJROkN7FXUYKEmOfsqCp8SSWvMb8VbC0"

/// API Service for Table Topics
/// Searches commercial construction permits to find restaurant/hotel projects
/// that will need tables and furniture
public final class APIService: Sendable {
    
    // MARK: - Singleton
    
    public static let shared = APIService()
    
    // MARK: - Properties
    
    private let state: APIState
    private let userDefaultsKey = "com.tabletopics.shovelsApiKey"
    private let enrichmentService = ContactEnrichmentService()
    private let descriptionAnalyzer = RuleBasedDescriptionAnalyzer()
    private let analysisCache = AnalysisCache.shared
    
    // MARK: - Init
    
    private init() {
        let savedKey = UserDefaults.standard.string(forKey: userDefaultsKey)
        self.state = APIState(apiKey: savedKey ?? defaultAPIKey)
    }
    
    // MARK: - API Key Management
    
    public func setAPIKey(_ key: String) {
        state.apiKey = key
        UserDefaults.standard.set(key, forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }
    
    public func clearAPIKey() {
        state.apiKey = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }
    
    public var apiKey: String? { state.apiKey }
    
    // MARK: - Enrichment Provider
    
    /// Set which enrichment provider to use for contact discovery
    public func setEnrichmentProvider(_ provider: ContactEnrichmentService.EnrichmentProvider) {
        state.enrichmentProvider = provider
    }
    
    public var enrichmentProvider: ContactEnrichmentService.EnrichmentProvider {
        state.enrichmentProvider
    }
    
    // MARK: - Test Mode
    
    /// Enable test mode: first N leads use Apollo, next M leads use Hunter only
    /// This preserves Apollo credits (10 free/mo) by using Hunter (50 free/mo) for most enrichment
    public func enableTestMode(apolloCount: Int = 1, hunterCount: Int = 5) {
        state.testModeEnabled = true
        state.testModeApolloCount = apolloCount
        state.testModeHunterCount = hunterCount
    }
    
    public func disableTestMode() {
        state.testModeEnabled = false
    }
    
    public var isTestModeEnabled: Bool {
        state.testModeEnabled
    }
    
    // MARK: - Search Methods
    
    /// Search for commercial projects (restaurants, hotels, etc.)
    /// Uses permit-based search with free-text matching on descriptions
    /// - Parameters:
    ///   - query: Search query — either a free-text term (e.g., "restaurant")
    ///            or a tag prefixed with "__tag:" (e.g., "__tag:new_construction")
    ///   - stateCode: Two-letter state code (e.g., "AL", "TX")
    ///   - city: Optional city name (informational — not used by Shovels directly)
    ///   - limit: Max results (default 20)
    /// - Returns: Array of Lead objects built from permit data
    public func searchLeads(
        query: String,
        stateCode: String,
        city: String? = nil,
        limit: Int = 20
    ) async throws -> [Lead] {
        guard let key = state.apiKey else {
            throw APIError.noAPIKey
        }
        
        let shovels = ShovelsAPIService(apiKey: key)
        
        // Determine search mode: tag-based or free-text
        let isTagSearch = query.hasPrefix("__tag:")
        let permits: [ShovelsPermit]
        
        if isTagSearch {
            let tag = String(query.dropFirst("__tag:".count))
            permits = try await shovels.searchPermits(
                tags: tag,
                state: stateCode,
                propertyType: "commercial",
                hasContractor: true,
                limit: limit
            )
        } else {
            permits = try await shovels.searchPermits(
                textQuery: query,
                state: stateCode,
                propertyType: "commercial",
                hasContractor: nil,  // Don't restrict — many permits lack contractor links
                limit: limit
            )
        }
        
        if permits.isEmpty {
            throw APIError.noResults
        }
        
        // Pre-fetch contractor details for permits that have contractor IDs
        var contractorCache: [String: ShovelsContractor] = [:]
        let contractorIds = permits.compactMap { $0.contractorId }
        print("[APIService] Found \(permits.count) permits, \(contractorIds.count) have contractorId")
        for contractorId in Set(contractorIds) {
            do {
                if let contractor = try await shovels.getContractor(byId: contractorId) {
                    contractorCache[contractorId] = contractor
                    print("[APIService] Fetched contractor: \(contractor.businessName ?? contractor.name ?? "unnamed")")
                }
            } catch {
                print("[APIService] Failed to fetch contractor \(contractorId): \(error)")
            }
        }
        print("[APIService] Contractor cache: \(contractorCache.count) contractors fetched")

        // Pre-analyze all permits for description relevance (with caching)
        let permitInputs = permits.map { permit in
            DescriptionInput(
                id: permit.id,
                description: permit.description,
                permitType: permit.tags?.first.flatMap { PermitType(rawValue: $0) } ?? .other,
                estimatedValue: permit.jobValue.map { Double($0) / 100.0 },
                jurisdiction: permit.jurisdiction
            )
        }
        let analyses = await analysisCache.getOrComputeBatch(permits: permitInputs, analyzer: descriptionAnalyzer)
        
        // Filter out rejected permits (residential minor, utility, etc.)
        let rejectedCount = analyses.values.filter { $0.shouldReject }.count
        if rejectedCount > 0 {
            print("[APIService] Filtered out \(rejectedCount) non-commercial permits")
        }

        // Build leads from permit data (skip rejected)
        var leads: [Lead] = []
        for (index, permit) in permits.enumerated() {
            // Check if this permit should be filtered out
            guard let analysis = analyses[permit.id], !analysis.shouldReject else {
                continue
            }
            
            let project = permit.toProject()

            // Try to get contractor info from the pre-fetched cache
            let contractor: ShovelsContractor? = permit.contractorId.flatMap { contractorCache[$0] }

            // Use contractor name if available, otherwise fall back to property owner/jurisdiction
            // Note: contractor.businessName is the actual company, propertyLegalOwner is often a city name
            let companyName = contractor?.businessName
                ?? contractor?.name
                ?? permit.propertyLegalOwner
                ?? permit.jurisdiction
                ?? "Commercial Project"

            // Determine license status from contractor's statusTally
            var licStatus: LicenseStatus = .unknown
            if let tally = contractor?.statusTally {
                if tally["active"] != nil && (tally["active"] ?? 0) > 0 {
                    licStatus = .active
                } else if tally["inactive"] != nil {
                    licStatus = .inactive
                }
            }

            let company = Company(
                id: UUID(),
                name: companyName,
                address: contractor?.address?.toAddress() ?? permit.address?.toAddress() ?? Address(),
                phone: contractor?.primaryPhone ?? contractor?.phone?.components(separatedBy: ",").first,
                email: contractor?.primaryEmail ?? contractor?.email?.components(separatedBy: ",").first,
                website: contractor?.website.flatMap { URL(string: $0.hasPrefix("http") ? $0 : "https://\($0)") },
                licenseNumber: contractor?.license,
                licenseStatus: licStatus,
                yearsInBusiness: nil,
                completedProjects: contractor?.statusTally?["final"],
                totalProjects: contractor?.permitCount,
                rating: contractor?.rating
            )

            var lead = Lead(
                company: company,
                project: project,
                source: .permitScout
            )

            // Enrich with contact information
            do {
                if state.testModeEnabled {
                    // Test mode: first N with Apollo, next M with Hunter only
                    let mode: EnrichmentMode
                    if index < state.testModeApolloCount {
                        mode = .apolloFirst
                    } else if index < state.testModeApolloCount + state.testModeHunterCount {
                        mode = .hunterOnly
                    } else {
                        mode = .patternOnly  // Remaining leads use free pattern matching
                    }
                    _ = try await enrichmentService.enrichLead(&lead, mode: mode, maxContacts: 3)
                } else {
                    try await enrichmentService.enrichLead(&lead, provider: state.enrichmentProvider, maxContacts: 3)
                }
            } catch {
                // Enrichment failed - keep lead without additional contacts
                // This is acceptable; leads can still be scored and contacted manually
            }

            // Score with description analysis
            let scoringService = DefaultScoringService()
            if let analysis = analyses[permit.id] {
                lead.updateScore(scoringService.score(lead: lead, descriptionAnalysis: analysis))
            } else {
                lead.updateScore(LeadScore.calculate(for: lead))
            }
            leads.append(lead)
        }
        
        // Update credits
        state.creditsUsed = shovels.creditsUsed
        state.creditsRemaining = shovels.maxCredits - shovels.creditsUsed
        
        return leads
    }
    
    /// Get current API usage
    public func refreshUsage() async {
        guard let key = state.apiKey else { return }
        
        let shovels = ShovelsAPIService(apiKey: key)
        
        do {
            let usage = try await shovels.getUsage()
            state.creditsUsed = usage.creditsUsed
            state.creditsRemaining = usage.creditsRemaining
        } catch {
            // Silently fail - usage is optional
        }
    }
    
    /// Check if API is configured
    public var isConfigured: Bool {
        state.apiKey != nil && !state.apiKey!.isEmpty
    }
    
    /// Credits remaining for Shovels API
    public var creditsRemaining: Int { state.creditsRemaining }
    
    /// Credits used in current period
    public var creditsUsed: Int { state.creditsUsed }
    
    /// Estimate credits for a search
    public func estimatedCredits(for limit: Int) -> Int {
        // One permit search uses 1 credit per result returned
        return limit
    }
}

// MARK: - Errors

public enum APIError: Error, LocalizedError {
    case noAPIKey
    case rateLimited(retryAfter: Int?)
    case noResults
    case networkError(Error)
    case invalidResponse
    
    public var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key configured. Add your Shovels.ai API key in Settings."
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Rate limited. Try again in \(seconds) seconds."
            }
            return "Rate limited. Please wait before making more requests."
        case .noResults:
            return "No results found for your search."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from API."
        }
    }
}
