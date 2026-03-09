// LeadListView.swift
// Lead list with tier filtering and dark OLED card layout

import SwiftUI
import B2BCore
import B2BUI

struct LeadListView: View {
    @State private var viewModel = LeadsViewModel()
    @State private var selectedTier: LeadTier?
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    statsStrip
                    tierFilterBar

                    if viewModel.isLoading && viewModel.leads.isEmpty {
                        loadingView
                    } else if let error = viewModel.error {
                        errorView(error)
                    } else if filteredLeads.isEmpty {
                        emptyView
                    } else {
                        leadsList
                    }
                }
            }
            .navigationTitle("Leads")
            .searchable(text: $searchText, prompt: "Search contractors...")
            .refreshable { await viewModel.refresh() }
            .task {
                if viewModel.leads.isEmpty { await viewModel.loadLeads() }
            }
            .navigationDestination(for: Lead.self) { lead in
                LeadDetailView(lead: lead)
            }
        }
    }

    // MARK: - Stats Strip

    private var statsStrip: some View {
        HStack(spacing: 0) {
            statCell(
                value: "\(hotCount)",
                label: "Hot Leads",
                icon: "flame.fill",
                iconColor: LeadTier.hot.color
            )

            Rectangle()
                .fill(Color.brandBorder.opacity(0.4))
                .frame(width: 1, height: 36)

            statCell(
                value: totalPipelineValue,
                label: "Pipeline",
                icon: "chart.line.uptrend.xyaxis",
                iconColor: .brandBlue
            )

            Rectangle()
                .fill(Color.brandBorder.opacity(0.4))
                .frame(width: 1, height: 36)

            statCell(
                value: "\(viewModel.leads.count)",
                label: "Total Leads",
                icon: "person.crop.rectangle.stack",
                iconColor: Color.primary.opacity(0.4)
            )
        }
        .padding(.vertical, 14)
        .background(Color.brandCard)
        .overlay(
            Rectangle()
                .fill(Color.brandBorder.opacity(0.3))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }

    private func statCell(value: String, label: String, icon: String, iconColor: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(iconColor)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                    .monospacedDigit()
            }
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
            .padding(.vertical, 10)
        }
        .background(Color.brandCard)
        .overlay(
            Rectangle()
                .fill(Color.brandBorder.opacity(0.3))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }

    // MARK: - Leads List

    private var leadsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(filteredLeads) { lead in
                    NavigationLink(value: lead) {
                        LeadCardRow(lead: lead)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
    }

    // MARK: - State Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.brandBlue)
            Text("Loading leads...")
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
                Text("Failed to load leads")
                    .font(.headline)
                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button {
                Task { await viewModel.loadLeads() }
            } label: {
                Text("Try Again")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.brandGreen)
                    .foregroundColor(.black)
                    .cornerRadius(20)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandBlue.opacity(0.1))
                    .frame(width: 72, height: 72)
                Image(systemName: "tray")
                    .font(.system(size: 32))
                    .foregroundColor(.brandBlue)
            }
            VStack(spacing: 6) {
                Text("No leads found")
                    .font(.headline)
                Text("Try adjusting filters or search terms")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        if !searchText.isEmpty {
            result = result.filter { lead in
                lead.company.name.localizedCaseInsensitiveContains(searchText) ||
                lead.project.description.localizedCaseInsensitiveContains(searchText) ||
                lead.project.address.city.localizedCaseInsensitiveContains(searchText)
            }
        }
        result.sort { ($0.score?.overall ?? 0) > ($1.score?.overall ?? 0) }
        return result
    }
}

// MARK: - LeadCardRow

struct LeadCardRow: View {
    let lead: Lead

    private var tierColor: Color { lead.score?.tier.color ?? .brandSlate }

    var body: some View {
        HStack(spacing: 0) {
            // Tier accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(tierColor)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 8) {
                // Company name + score badge
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(lead.company.name)
                            .font(.headline)
                            .foregroundColor(Color.primary)
                        Text(lead.project.permitType.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.brandBlue)
                    }
                    Spacer(minLength: 8)
                    if let score = lead.score {
                        ScoreBadge(score: score)
                    }
                }

                // Project description
                Text(lead.project.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                // Location + value
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundColor(.brandBlue)
                    Text("\(lead.project.address.city), \(lead.project.address.state)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    if let value = lead.project.estimatedValue {
                        Text(value.fullCurrency)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.primary)
                    }
                }
            }
            .padding(14)
        }
        .darkCard()
    }
}

#Preview {
    LeadListView()
}
