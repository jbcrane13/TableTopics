// ContractorSearchView.swift
// Search for hotel/restaurant contractors — focused on table sales leads

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
    
    // Search queries for hotel/restaurant contractors
    // These are the types of contractors who buy tables
    private let searchQueries = [
        "restaurant furniture",
        "hotel furniture",
        "commercial tables",
        "restaurant renovation",
        "hotel renovation",
        "bar furniture",
        "cafe furniture",
        "banquet furniture"
    ]
    
    @State private var selectedQuery: String = "restaurant furniture"
    
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
                } header: {
                    Text("Shovels API")
                } footer: {
                    Text("Free tier: 250 credits. Each search uses ~6 credits per result.")
                }
                
                // Contractor Type
                Section("Contractor Type") {
                    Picker("Looking For", selection: $selectedQuery) {
                        ForEach(searchQueries, id: \.self) { query in
                            Text(query.capitalized).tag(query)
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
                        }
                    }
                }
                
                // Search Button
                Section {
                    Button(action: performSearch) {
                        HStack {
                            Text("Find Contractors")
                            Spacer()
                            if isSearching {
                                ProgressView()
                            }
                        }
                    }
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
                    Section("Results (\(viewModel.leads.count) contractors)") {
                        ForEach(viewModel.leads.prefix(5)) { lead in
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
                                
                                Text("\(lead.project.address.city), \(lead.project.address.state)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Demo Toggle
                Section {
                    Toggle("Use Demo Data", isOn: $viewModel.useMockData)
                        .toggleStyle(.switch)
                    
                    Text("Demo data doesn't use API credits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Data Source")
                }
            }
            .navigationTitle("Find Contractors")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await viewModel.refreshUsage() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        showingAreaLock = true
                    } label: {
                        Image(systemName: viewModel.areaLocked ? "lock.fill" : "lock.open")
                    }
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
        Task {
            isSearching = true
            searchError = nil
            
            do {
                await viewModel.search(
                    query: selectedQuery,
                    stateCode: selectedState,
                    city: searchCity.isEmpty ? nil : searchCity
                )
            } catch {
                searchError = error.localizedDescription
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
                    .disabled(apiKey.isEmpty)
                    
                    if viewModel.isAPIConfigured {
                        Button("Clear API Key", role: .destructive) {
                            viewModel.clearAPIKey()
                            isPresented = false
                        }
                    }
                }
            }
            .navigationTitle("API Configuration")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
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
#if os(iOS)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
#endif
                    
                    TextField("City (optional)", text: $lockCity)
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
                        let area = lockCity.isEmpty ? lockState : "\(lockCity), \(lockState)"
                        viewModel.lockArea(state: lockState, city: lockCity.isEmpty ? nil : lockCity)
                        isPresented = false
                    }
                    .disabled(lockState.count != 2)
                    
                    if viewModel.areaLocked {
                        Button("Unlock Current Area", role: .destructive) {
                            viewModel.unlockArea()
                            isPresented = false
                        }
                    }
                }
            }
            .navigationTitle("Area Lock")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
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