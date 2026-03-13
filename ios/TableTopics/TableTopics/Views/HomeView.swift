// HomeView.swift
// Unified search + results — single screen for Table Topics sales reps

import SwiftUI
import B2BCore

struct HomeView: View {
    @State private var viewModel = LeadsViewModel()
    @State private var selectedTier: LeadTier?
    @State private var searchText = ""
    @State private var showingSettings = false
    @State private var isSearchBarExpanded = true

    /// Search categories mapped to Shovels permit queries
    private let searchCategories: [(label: String, query: String)] = [
        ("Restaurant", "restaurant"),
        ("Hotel", "hotel"),
        ("Bar / Lounge", "bar lounge"),
        ("Cafe", "cafe coffee"),
        ("Banquet Hall", "banquet event center"),
        ("Kitchen", "commercial kitchen"),
        ("New Build", "__tag:new_construction"),
        ("Remodel", "__tag:remodel"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    searchHeader
                    statsStrip
                    tierFilterBar

                    if viewModel.isLoading && viewModel.leads.isEmpty {
                        loadingView
                    } else if let error = viewModel.error {
                        errorView(error)
                    } else if viewModel.leads.isEmpty && !viewModel.isLoading {
                        emptyView
                    } else {
                        leadsList
                    }
                }
            }
            .navigationTitle("Table Topics")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.brandBlue)
                    }
                    .accessibilityIdentifier("home_button_settings")
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsSheet(viewModel: viewModel, isPresented: $showingSettings)
            }
            .navigationDestination(for: Lead.self) { lead in
                LeadDetailView(lead: lead)
            }
            .task {
                if viewModel.leads.isEmpty { await viewModel.loadLeads() }
            }
        }
        .accessibilityIdentifier("screen_home")
    }

    // MARK: - Search Header

    private var searchHeader: some View {
        VStack(spacing: 10) {
            // Location row: State picker + City/Zip field + Search button
            HStack(spacing: 8) {
                // State picker
                Menu {
                    ForEach(LeadsViewModel.usStates, id: \.self) { state in
                        Button(state) {
                            viewModel.searchState = state
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(.brandBlue)
                        Text(viewModel.searchState)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.primary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.brandSlate)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 11)
                    .background(Color.brandCardElevated)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.brandBorder.opacity(0.4), lineWidth: 0.5)
                    )
                }
                .accessibilityIdentifier("home_picker_state")

                // City/Zip text field
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.caption)
                        .foregroundColor(.brandSlate)
                    TextField("City or zip code", text: $viewModel.searchCity)
                        .font(.subheadline)
                        .foregroundColor(Color.primary)
                        #if os(iOS)
                        .textInputAutocapitalization(.words)
                        #endif
                        .accessibilityIdentifier("home_textfield_city")
                }
                .searchFieldStyle()

                // Search button
                Button {
                    performSearch()
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Image(systemName: "arrow.right")
                                .font(.subheadline.weight(.bold))
                        }
                    }
                    .frame(width: 44, height: 44)
                    .background(Color.brandBlue)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .accessibilityIdentifier("home_button_search")
            }

            // Category pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(searchCategories.enumerated()), id: \.offset) { index, category in
                        CategoryPill(
                            label: category.label,
                            isSelected: viewModel.selectedCategory == index
                        ) {
                            viewModel.selectedCategory = index
                        }
                    }
                }
            }

            // Area lock indicator
            if viewModel.areaLocked {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(.brandAmber)
                    Text("Locked to \(viewModel.lockedArea)")
                        .font(.caption2)
                        .foregroundColor(.brandAmber)
                    Spacer()
                    Button("Unlock") {
                        viewModel.unlockArea()
                    }
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.brandBlue)
                    .accessibilityIdentifier("home_button_unlock_area")
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.brandCard)
        .overlay(
            Rectangle()
                .fill(Color.brandBorder.opacity(0.3))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }

    // MARK: - Stats Strip

    private var statsStrip: some View {
        HStack(spacing: 0) {
            statCell(
                value: "\(hotCount)",
                label: "Hot",
                icon: "flame.fill",
                iconColor: LeadTier.hot.color
            )

            Rectangle()
                .fill(Color.brandBorder.opacity(0.4))
                .frame(width: 1, height: 30)

            statCell(
                value: totalPipelineValue,
                label: "Pipeline",
                icon: "chart.line.uptrend.xyaxis",
                iconColor: .brandBlue
            )

            Rectangle()
                .fill(Color.brandBorder.opacity(0.4))
                .frame(width: 1, height: 30)

            statCell(
                value: "\(viewModel.leads.count)",
                label: "Total",
                icon: "person.crop.rectangle.stack",
                iconColor: Color.primary.opacity(0.4)
            )
        }
        .padding(.vertical, 10)
        .background(Color.brandBackground)
    }

    private func statCell(value: String, label: String, icon: String, iconColor: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(iconColor)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color.primary)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundColor(Color.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tier Filter Bar

    private var tierFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                TierChip(
                    title: "All",
                    count: viewModel.leads.count,
                    color: .brandSlate,
                    isSelected: selectedTier == nil
                ) { selectedTier = nil }

                ForEach([LeadTier.hot, .warm, .cool, .cold], id: \.self) { tier in
                    TierChip(
                        title: tier.shortLabel,
                        count: viewModel.leads.filter { $0.score?.tier == tier }.count,
                        color: tier.color,
                        isSelected: selectedTier == tier
                    ) {
                        selectedTier = (selectedTier == tier) ? nil : tier
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.brandBackground)
    }

    // MARK: - Leads List

    private var leadsList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredLeads) { lead in
                    NavigationLink(value: lead) {
                        LeadCard(lead: lead)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .refreshable { await viewModel.refresh() }
    }

    // MARK: - State Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.brandBlue)
            Text("Searching for leads...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.orange)
            }
            VStack(spacing: 6) {
                Text("Search failed")
                    .font(.headline)
                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button {
                performSearch()
            } label: {
                Text("Try Again")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.brandBlue)
                    .foregroundColor(.black)
                    .cornerRadius(20)
            }
            .accessibilityIdentifier("home_button_retry")
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.brandBlue.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "building.2.crop.circle")
                    .font(.system(size: 36))
                    .foregroundColor(.brandBlue)
            }
            VStack(spacing: 6) {
                Text("Find Your Next Lead")
                    .font(.headline)
                Text("Search by city and category to discover\nhotels and restaurants needing tables")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button {
                performSearch()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                    Text("Search Now")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.brandBlue)
                .foregroundColor(.black)
                .cornerRadius(20)
            }
            .accessibilityIdentifier("home_button_search_empty")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func performSearch() {
        let query = searchCategories[viewModel.selectedCategory].query
        Task<Void, Never> {
            await viewModel.search(
                query: query,
                stateCode: viewModel.searchState,
                city: viewModel.searchCity.isEmpty ? nil : viewModel.searchCity
            )
        }
    }

    // MARK: - Computed

    private var hotCount: Int {
        viewModel.leads.filter { $0.score?.tier == .hot }.count
    }

    private var totalPipelineValue: String {
        viewModel.leads.compactMap { $0.project.estimatedValue }.reduce(0, +).compactCurrency
    }

    private var filteredLeads: [Lead] {
        var result = viewModel.leads
        if let tier = selectedTier {
            result = result.filter { $0.score?.tier == tier }
        }
        result.sort { ($0.score?.overall ?? 0) > ($1.score?.overall ?? 0) }
        return result
    }
}

// MARK: - Lead Card (with inline contact actions)

struct LeadCard: View {
    let lead: Lead

    private var tierColor: Color { lead.score?.tier.color ?? .brandSlate }

    var body: some View {
        VStack(spacing: 0) {
            // Main content
            HStack(spacing: 0) {
                // Tier accent bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(tierColor)
                    .frame(width: 3)

                VStack(alignment: .leading, spacing: 8) {
                    // Row 1: Company name + score
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(lead.company.name)
                                .font(.headline)
                                .foregroundColor(Color.primary)
                                .lineLimit(1)
                            HStack(spacing: 6) {
                                Text(lead.project.permitType.rawValue.capitalized)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.brandBlue)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.brandBlue.opacity(0.12))
                                    .cornerRadius(4)
                                if let value = lead.project.estimatedValue {
                                    Text(value.compactCurrency)
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.brandGreen)
                                }
                            }
                        }
                        Spacer(minLength: 8)
                        if let score = lead.score {
                            ScoreBadge(score: score)
                        }
                    }

                    // Row 2: Description
                    Text(lead.project.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    // Row 3: Location + contact quick actions
                    HStack(spacing: 0) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.system(size: 9))
                                .foregroundColor(.brandBlue)
                            Text("\(lead.project.address.city), \(lead.project.address.state)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer(minLength: 12)

                        // Inline contact actions
                        HStack(spacing: 8) {
                            if lead.company.phone != nil || lead.decisionMakers.contains(where: { $0.phone != nil }) {
                                contactActionIcon(
                                    icon: "phone.fill",
                                    color: .brandGreen,
                                    identifier: "lead_card_phone_\(lead.id)"
                                ) {
                                    callBestPhone()
                                }
                            }

                            if lead.company.email != nil || lead.decisionMakers.contains(where: { $0.email != nil }) {
                                contactActionIcon(
                                    icon: "envelope.fill",
                                    color: .brandBlue,
                                    identifier: "lead_card_email_\(lead.id)"
                                ) {
                                    emailBestContact()
                                }
                            }

                            if lead.company.phone != nil || lead.decisionMakers.contains(where: { $0.phone != nil }) {
                                contactActionIcon(
                                    icon: "message.fill",
                                    color: .brandAmber,
                                    identifier: "lead_card_text_\(lead.id)"
                                ) {
                                    textBestPhone()
                                }
                            }
                        }
                    }
                }
                .padding(14)
            }
        }
        .darkCard()
        .accessibilityIdentifier("lead_card_\(lead.id)")
    }

    private func contactActionIcon(icon: String, color: Color, identifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .frame(width: 32, height: 32)
                .background(color.opacity(0.15))
                .foregroundColor(color)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.25), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    // MARK: - Contact Helpers

    private func callBestPhone() {
        let phone = lead.company.phone
            ?? lead.decisionMakers.first(where: { $0.phone != nil })?.phone
        guard let phone else { return }
        openURL("tel://\(cleanPhone(phone))")
    }

    private func emailBestContact() {
        let email = lead.company.email
            ?? lead.decisionMakers.first(where: { $0.email != nil })?.email
        guard let email else { return }
        openURL("mailto:\(email)")
    }

    private func textBestPhone() {
        let phone = lead.company.phone
            ?? lead.decisionMakers.first(where: { $0.phone != nil })?.phone
        guard let phone else { return }
        openURL("sms:\(cleanPhone(phone))")
    }

    private func cleanPhone(_ phone: String) -> String {
        phone.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
    }

    private func openURL(_ string: String) {
        #if canImport(UIKit)
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

#Preview {
    HomeView()
}
