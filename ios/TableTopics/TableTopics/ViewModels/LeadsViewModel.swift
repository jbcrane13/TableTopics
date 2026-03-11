// LeadsViewModel.swift
// Observable state for contractor leads — Table Topics

import SwiftUI
import B2BCore

@MainActor
@Observable
final class LeadsViewModel {
    var leads: [Lead] = []
    var isLoading = false
    var error: String?
    
    /// When true, uses mock data instead of API (for demos without backend)
    var useMockData = true  // Default to mock for demo
    
    /// Search location (state code for API, e.g., "AL", "TX")
    var searchState: String = "AL"
    
    /// Search city (optional filter)
    var searchCity: String = ""
    
    /// Search query (contractor type: "restaurant furniture", "hotel renovation", etc.)
    var searchQuery: String = "restaurant furniture"

    /// Currently selected search category index
    var selectedCategory: Int = 0

    /// Result limit (be conservative with free tier - 250 credits)
    var resultLimit: Int = 10
    
    /// Area lock - restricts all searches to a specific area
    var areaLocked: Bool = false
    var lockedState: String = ""
    var lockedCity: String?
    
    private let apiService = APIService.shared
    private let areaLockKey = "com.tabletopics.areaLock"
    private let areaLockStateKey = "com.tabletopics.areaLockState"
    private let areaLockCityKey = "com.tabletopics.areaLockCity"
    
    /// Whether API is configured with a key
    var isAPIConfigured: Bool {
        apiService.isConfigured
    }
    
    /// Credits remaining for Shovels API
    var creditsRemaining: Int {
        apiService.creditsRemaining
    }
    
    /// Estimated credits for current search
    var estimatedCredits: Int {
        apiService.estimatedCredits(for: resultLimit)
    }
    
    /// Locked area display string
    var lockedArea: String {
        if let city = lockedCity, !city.isEmpty {
            return "\(city), \(lockedState)"
        }
        return lockedState
    }
    
    // MARK: - US States

    static let usStates = [
        "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
        "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
        "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
        "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
        "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
    ]

    // MARK: - Computed Properties

    var hotLeads: [Lead] { leads.filter { $0.score?.tier == .hot } }
    var warmLeads: [Lead] { leads.filter { $0.score?.tier == .warm } }
    var coolLeads: [Lead] { leads.filter { $0.score?.tier == .cool } }
    var coldLeads: [Lead] { leads.filter { $0.score?.tier == .cold } }
    
    var filteredLeads: [Lead] {
        leads
    }
    
    // MARK: - Init
    
    init() {
        loadAreaLock()
    }
    
    // MARK: - Actions
    
    func loadLeads() async {
        isLoading = true
        error = nil
        
        // Apply area lock if set
        let effectiveState = areaLocked ? lockedState : searchState
        let effectiveCity = areaLocked ? lockedCity : (searchCity.isEmpty ? nil : searchCity)
        
        if useMockData {
            // Simulate network delay for realistic demo
            try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5s
            leads = MockData.sampleLeads
            isLoading = false
            return
        }
        
        // Real API call to Shovels
        do {
            leads = try await apiService.searchLeads(
                query: searchQuery,
                stateCode: effectiveState,
                city: effectiveCity,
                limit: resultLimit
            )
        } catch {
            self.error = error.localizedDescription
            leads = []
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadLeads()
    }
    
    /// Search for contractors by work type and location
    func search(query: String, stateCode: String, city: String? = nil) async {
        searchQuery = query
        // Only update search state/city if area is not locked
        if !areaLocked {
            searchState = stateCode
            searchCity = city ?? ""
        }
        await loadLeads()
    }
    
    /// Lock searches to a specific area
    func lockArea(state: String, city: String? = nil) {
        areaLocked = true
        lockedState = state
        lockedCity = city
        saveAreaLock()
    }
    
    /// Unlock area restrictions
    func unlockArea() {
        areaLocked = false
        lockedState = ""
        lockedCity = nil
        clearAreaLock()
    }
    
    /// Configure API key for Shovels
    func setAPIKey(_ key: String) {
        apiService.setAPIKey(key)
    }
    
    /// Clear stored API key
    func clearAPIKey() {
        apiService.clearAPIKey()
    }
    
    /// Refresh credit usage from API
    func refreshUsage() async {
        await apiService.refreshUsage()
    }
    
    // MARK: - Persistence
    
    private func saveAreaLock() {
        UserDefaults.standard.set(areaLocked, forKey: areaLockKey)
        UserDefaults.standard.set(lockedState, forKey: areaLockStateKey)
        UserDefaults.standard.set(lockedCity, forKey: areaLockCityKey)
        UserDefaults.standard.synchronize()
    }
    
    private func clearAreaLock() {
        UserDefaults.standard.removeObject(forKey: areaLockKey)
        UserDefaults.standard.removeObject(forKey: areaLockStateKey)
        UserDefaults.standard.removeObject(forKey: areaLockCityKey)
        UserDefaults.standard.synchronize()
    }
    
    private func loadAreaLock() {
        areaLocked = UserDefaults.standard.bool(forKey: areaLockKey)
        lockedState = UserDefaults.standard.string(forKey: areaLockStateKey) ?? ""
        lockedCity = UserDefaults.standard.string(forKey: areaLockCityKey)
    }
}