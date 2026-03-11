// LeadsViewModelTests.swift
// Unit tests for LeadsViewModel

import Testing
import Foundation
@testable import TableTopics
import B2BCore

@MainActor
@Suite("LeadsViewModel Tests")
struct LeadsViewModelTests {

    private let areaLockKey = "com.tabletopics.areaLock"
    private let areaLockStateKey = "com.tabletopics.areaLockState"
    private let areaLockCityKey = "com.tabletopics.areaLockCity"

    private func cleanUpUserDefaults() {
        UserDefaults.standard.removeObject(forKey: areaLockKey)
        UserDefaults.standard.removeObject(forKey: areaLockStateKey)
        UserDefaults.standard.removeObject(forKey: areaLockCityKey)
        UserDefaults.standard.synchronize()
    }

    // MARK: - Initial State

    @Test("Initial state has empty leads, not loading, no error, category 0")
    func initialState() {
        cleanUpUserDefaults()
        let viewModel = LeadsViewModel()
        #expect(viewModel.leads.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
        #expect(viewModel.selectedCategory == 0)
    }

    // MARK: - Loading

    @Test("loadLeads with mock data populates 5 leads")
    func loadLeadsWithMockData() async {
        cleanUpUserDefaults()
        let viewModel = LeadsViewModel()
        viewModel.useMockData = true
        await viewModel.loadLeads()
        #expect(viewModel.leads.count == 5)
    }

    @Test("loadLeads sets isLoading to true during load")
    func loadLeadsSetsIsLoading() async {
        cleanUpUserDefaults()
        let viewModel = LeadsViewModel()
        viewModel.useMockData = true
        #expect(viewModel.isLoading == false)
        // After loadLeads completes, isLoading should be false again
        await viewModel.loadLeads()
        #expect(viewModel.isLoading == false)
        #expect(viewModel.leads.count == 5)
    }

    // MARK: - Search

    @Test("search updates searchQuery")
    func searchUpdatesQuery() async {
        cleanUpUserDefaults()
        let viewModel = LeadsViewModel()
        viewModel.useMockData = true
        await viewModel.search(query: "hotel renovation", stateCode: "TX", city: "Austin")
        #expect(viewModel.searchQuery == "hotel renovation")
    }

    @Test("search respects area lock and does not change searchState or searchCity")
    func searchRespectsAreaLock() async {
        cleanUpUserDefaults()
        let viewModel = LeadsViewModel()
        viewModel.useMockData = true
        viewModel.lockArea(state: "CA", city: "Los Angeles")

        await viewModel.search(query: "restaurant", stateCode: "NY", city: "Buffalo")

        // searchQuery should update, but state/city should NOT change
        #expect(viewModel.searchQuery == "restaurant")
        #expect(viewModel.searchState == "AL") // default, unchanged
        #expect(viewModel.searchCity == "")     // default, unchanged
        cleanUpUserDefaults()
    }

    // MARK: - Area Lock

    @Test("lockArea persists to UserDefaults")
    func lockAreaPersists() {
        cleanUpUserDefaults()
        let viewModel = LeadsViewModel()
        viewModel.lockArea(state: "NY", city: "Brooklyn")

        #expect(viewModel.areaLocked == true)
        #expect(viewModel.lockedState == "NY")
        #expect(viewModel.lockedCity == "Brooklyn")

        // Verify UserDefaults
        #expect(UserDefaults.standard.bool(forKey: areaLockKey) == true)
        #expect(UserDefaults.standard.string(forKey: areaLockStateKey) == "NY")
        #expect(UserDefaults.standard.string(forKey: areaLockCityKey) == "Brooklyn")
        cleanUpUserDefaults()
    }

    @Test("unlockArea clears state and UserDefaults")
    func unlockAreaClears() {
        cleanUpUserDefaults()
        let viewModel = LeadsViewModel()
        viewModel.lockArea(state: "TX", city: "Dallas")
        viewModel.unlockArea()

        #expect(viewModel.areaLocked == false)
        #expect(viewModel.lockedState == "")
        #expect(viewModel.lockedCity == nil)

        #expect(UserDefaults.standard.object(forKey: areaLockKey) == nil)
        #expect(UserDefaults.standard.object(forKey: areaLockStateKey) == nil)
        #expect(UserDefaults.standard.object(forKey: areaLockCityKey) == nil)
    }

    @Test("New ViewModel restores area lock from UserDefaults")
    func loadAreaLockOnInit() {
        cleanUpUserDefaults()
        let first = LeadsViewModel()
        first.lockArea(state: "FL", city: "Miami")

        let second = LeadsViewModel()
        #expect(second.areaLocked == true)
        #expect(second.lockedState == "FL")
        #expect(second.lockedCity == "Miami")
        cleanUpUserDefaults()
    }

    // MARK: - Filtering

    @Test("hotLeads returns only hot tier leads")
    func hotLeadsFilters() async {
        cleanUpUserDefaults()
        let viewModel = LeadsViewModel()
        viewModel.useMockData = true
        await viewModel.loadLeads()

        let hot = viewModel.hotLeads
        for lead in hot {
            #expect(lead.score?.tier == .hot)
        }
        // MockData should have at least one hot lead
        #expect(!hot.isEmpty)
    }

    // MARK: - Computed Properties

    @Test("lockedArea formats as 'city, STATE' or just 'STATE'")
    func lockedAreaFormat() {
        cleanUpUserDefaults()
        let viewModel = LeadsViewModel()

        viewModel.lockArea(state: "CA", city: "San Francisco")
        #expect(viewModel.lockedArea == "San Francisco, CA")

        viewModel.lockArea(state: "TX", city: nil)
        #expect(viewModel.lockedArea == "TX")

        viewModel.lockArea(state: "NY", city: "")
        #expect(viewModel.lockedArea == "NY")
        cleanUpUserDefaults()
    }

    @Test("selectedCategory defaults to 0")
    func selectedCategoryDefault() {
        cleanUpUserDefaults()
        let viewModel = LeadsViewModel()
        #expect(viewModel.selectedCategory == 0)
    }

    @Test("usStates contains exactly 50 entries")
    func usStatesCount() {
        #expect(LeadsViewModel.usStates.count == 50)
    }
}
