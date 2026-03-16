// ContractorSearchView.swift
// Search for hotel/restaurant construction projects — focused on table sales leads

import SwiftUI
import B2BCore

struct ContractorSearchView: View {
    @State private var viewModel = LeadsViewModel()
    @State private var selectedState: String = "AL"
    @State private var searchCity: String = ""
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var showingSettings = false
    @State private var showingAreaLock = false
    
    /// Search categories mapped to Shovels permit_q free-text search
    /// These search permit descriptions for commercial property types
    private let searchCategories: [(label: String, query: String)] = [
        ("Restaurant — New Build", "restaurant"),
        ("Restaurant — Renovation", "restaurant remodel"),
        ("Hotel / Hospitality", "hotel"),
        ("Bar / Lounge", "bar lounge"),
        ("Cafe / Coffee Shop", "cafe coffee"),
        ("Banquet / Event Space", "banquet event center"),
        ("Commercial Kitchen", "commercial kitchen"),
        ("All Commercial New Construction", "__tag:new_construction"),
        ("All Commercial Remodels", "__tag:remodel"),
    ]
    
    @State private var selectedCategory: Int = 0
    
    let states = [
        "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
        "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
        "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
        "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
        "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // API Configuration Section
                Section {
                    HStack {
                        Text("API Status")
                        Spacer()
                        if viewModel.isAPIConfigured {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.orange)
                        }
                    }
                    
                    if viewModel.isAPIConfigured {
                        HStack {
                            Text("Credits Remaining")
                            Spacer()
                            Text("\(viewModel.creditsRemaining)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button("Configure API Key") {
                        showingSettings = true
                    }
                    .accessibilityIdentifier("contractor_configure_api_button")
                } header: {
                    Text("Shovels API")
                } footer: {
                    Text("Searches commercial construction permits. ~1 credit per result.")
                }
                
                // Search Category
                Section("What Are You Looking For?") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(0..<searchCategories.count, id: \.self) { index in
                            Text(searchCategories[index].label).tag(index)
                        }
                    }
#if os(iOS)
                    .pickerStyle(.menu)
#endif
                }
                
                // Location
                Section("Location") {
                    Picker("State", selection: $selectedState) {
                        ForEach(states, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    
                    TextField("City (optional)", text: $searchCity)
                        .accessibilityIdentifier("contractor_search_city_field")
#if os(iOS)
                        .textInputAutocapitalization(.words)
#endif
                    
                    // Area Lock indicator
                    if viewModel.areaLocked {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.brandBlue)
                            Text("Area Locked: \(viewModel.lockedArea)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Unlock") {
                                viewModel.unlockArea()
                            }
                            .font(.caption)
                            .accessibilityIdentifier("contractor_unlock_button")
                        }
                    }
                }
                
                // Search Button
                Section {
                    Button(action: performSearch) {
                        HStack {
                            Text("Find Projects")
                            Spacer()
                            if isSearching {
                                ProgressView()
                            }
                        }
                    }
                    .accessibilityIdentifier("contractor_search_button")
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.isAPIConfigured || isSearching)
                }
                
                // Error Display
                if let error = searchError {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                    }
                }
                
                // Results Preview
                if !viewModel.leads.isEmpty {
                    Section("Results (\(viewModel.leads.count) projects)") {
                        ForEach(viewModel.leads.prefix(10)) { lead in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(lead.company.name)
                                        .font(.headline)
                                    Spacer()
                                    if let score = lead.score {
                                        Text("\(Int(score.overall * 100))")
                                            .bold()
                                            .foregroundColor(score.tier.color)
                                    }
                                }
                                
                                Text(lead.project.description)
                                    .font(.caption)
                                    .lineLimit(2)
                                    .foregroundColor(.secondary)
                                
                                if !lead.project.address.city.isEmpty {
                                    Text("\(lead.project.address.city), \(lead.project.address.state)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let value = lead.project.estimatedValue, value > 0 {
                                    Text("Est. Value: $\(Int(value).formatted())")
                                        .font(.caption2)
                                        .foregroundColor(.brandBlue)
                                }
                            }
                        }
                    }
                }
                
                // Demo Toggle
                Section {
                    Toggle("Use Demo Data", isOn: $viewModel.useMockData)
                        .accessibilityIdentifier("contractor_toggle_demo_data")
                        .toggleStyle(.switch)
                    
                    Text("Demo data doesn't use API credits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Data Source")
                }
            }
            .navigationTitle("Find Projects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await viewModel.refreshUsage() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityIdentifier("contractor_refresh_button")
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        showingAreaLock = true
                    } label: {
                        Image(systemName: viewModel.areaLocked ? "lock.fill" : "lock.open")
                    }
                    .accessibilityIdentifier("contractor_area_lock_button")
                }
            }
            .sheet(isPresented: $showingSettings) {
                APIKeySheet(viewModel: viewModel, isPresented: $showingSettings)
            }
            .sheet(isPresented: $showingAreaLock) {
                AreaLockSheet(viewModel: viewModel, isPresented: $showingAreaLock)
            }
        }
    }
    
    private func performSearch() {
        let category = searchCategories[selectedCategory]
        
        Task {
            isSearching = true
            searchError = nil
            
            await viewModel.search(
                query: category.query,
                stateCode: selectedState,
                city: searchCity.isEmpty ? nil : searchCity
            )
            
            if let error = viewModel.error {
                searchError = error
            }
            
            isSearching = false
        }
    }
}

// MARK: - API Key Configuration Sheet

struct APIKeySheet: View {
    @Bindable var viewModel: LeadsViewModel
    @Binding var isPresented: Bool
    @State private var apiKey: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Shovels API Key", text: $apiKey)
                        .accessibilityIdentifier("apikey_securefield_key")
#if os(iOS)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
#endif
                } header: {
                    Text("API Key")
                } footer: {
                    Text("Get your API key from shovels.ai")
                }
                
                Section {
                    Button("Save") {
                        viewModel.setAPIKey(apiKey)
                        isPresented = false
                    }
                    .accessibilityIdentifier("apikey_button_save")
                    .disabled(apiKey.isEmpty)
                    
                    if viewModel.isAPIConfigured {
                        Button("Clear API Key", role: .destructive) {
                            viewModel.clearAPIKey()
                            isPresented = false
                        }
                        .accessibilityIdentifier("apikey_button_clear")
                    }
                }
            }
            .navigationTitle("API Configuration")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .accessibilityIdentifier("apikey_button_cancel")
                }
            }
            .onAppear {
                if viewModel.isAPIConfigured {
                    apiKey = "••••••••••••"
                }
            }
        }
    }
}

// MARK: - Area Lock Sheet

struct AreaLockSheet: View {
    @Bindable var viewModel: LeadsViewModel
    @Binding var isPresented: Bool
    @State private var lockState: String = ""
    @State private var lockCity: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("State (e.g., TX)", text: $lockState)
                        .accessibilityIdentifier("contractor_search_state_field")
#if os(iOS)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
#endif
                    
                    TextField("City (optional)", text: $lockCity)
                        .accessibilityIdentifier("contractor_lock_city_field")
#if os(iOS)
                        .textInputAutocapitalization(.words)
#endif
                } header: {
                    Text("Lock Area")
                } footer: {
                    Text("Lock an area to focus your search. All future searches will be restricted to this area until unlocked.")
                }
                
                Section {
                    Button("Lock Area") {
                        viewModel.lockArea(state: lockState, city: lockCity.isEmpty ? nil : lockCity)
                        isPresented = false
                    }
                    .accessibilityIdentifier("area_lock_button_lock")
                    .disabled(lockState.count != 2)
                    
                    if viewModel.areaLocked {
                        Button("Unlock Current Area", role: .destructive) {
                            viewModel.unlockArea()
                            isPresented = false
                        }
                        .accessibilityIdentifier("area_lock_button_unlock")
                    }
                }
            }
            .navigationTitle("Area Lock")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .accessibilityIdentifier("area_lock_button_cancel")
                }
            }
            .onAppear {
                lockState = viewModel.lockedState
                lockCity = viewModel.lockedCity ?? ""
            }
        }
    }
}

#Preview {
    ContractorSearchView()
}
