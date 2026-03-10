// APIService.swift
// Table Topics API Service - wraps Shovels.ai API for commercial project leads

import B2BCore
import Foundation

/// Mutable state container for thread-safe access
private final class APIState: @unchecked Sendable {
    var apiKey: String?
    var creditsUsed: Int = 0
    var creditsRemaining: Int = 250
    
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
        
        // Build leads from permit data
        var leads: [Lead] = []
        for permit in permits {
            let project = permit.toProject()
            
            // Use property owner as the company (they're the buyer),
            // fall back to permit jurisdiction/description
            let companyName = permit.propertyLegalOwner
                ?? permit.jurisdiction
                ?? "Commercial Project"
            
            let company = Company(
                id: UUID(),
                name: companyName,
                address: permit.address?.toAddress() ?? Address(),
                phone: nil,
                email: nil,
                website: nil
            )
            
            var lead = Lead(
                company: company,
                project: project,
                source: .permitScout
            )
            
            lead.updateScore(LeadScore.calculate(for: lead))
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
