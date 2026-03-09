// APIService.swift
// Table Topics API Service - wraps Shovels.ai API for contractor leads

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
/// Manages API keys and wraps Shovels.ai for contractor lead data
public final class APIService: Sendable {
    
    // MARK: - Singleton
    
    public static let shared = APIService()
    
    // MARK: - Properties
    
    private let state: APIState
    private let userDefaultsKey = "com.tabletopics.shovelsApiKey"
    
    // MARK: - Init
    
    private init() {
        let savedKey = UserDefaults.standard.string(forKey: userDefaultsKey)
        // Use saved key, or fall back to default key
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
    
    // MARK: - Shovels API Methods
    
    /// Search for contractors by work type and location
    /// - Parameters:
    ///   - query: Work type (e.g., "restaurant furniture", "hotel renovation")
    ///   - stateCode: Two-letter state code (e.g., "AL", "TX")
    ///   - city: Optional city name
    ///   - limit: Max results (default 20)
    /// - Returns: Array of Lead objects
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
        
        let contractors = try await shovels.searchContractors(
            query: query,
            state: stateCode,
            city: city,
            limit: limit
        )
        
        // Convert contractors to leads
        var leads: [Lead] = []
        for contractor in contractors {
            // Get permits for this contractor to build the project
            let permits = try await shovels.getPermitsByContractor(
                contractorId: contractor.id,
                limit: 5
            )
            
            // Create lead from contractor + most recent permit
            let project = permits.first?.toProject() ?? Project(
                description: "No active permits",
                address: contractor.address?.toAddress() ?? Address(),
                status: .filed
            )
            
            var lead = Lead(
                company: contractor.toCompany(),
                project: project,
                source: .permitScout
            )
            
            // Calculate lead score
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
        // Each contractor result = 1 credit
        // + 5 permits per contractor = 5 credits
        // Total: 6 credits per result
        return limit * 6
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