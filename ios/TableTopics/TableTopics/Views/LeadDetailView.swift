// LeadDetailView.swift
// Detailed lead view — dark OLED theme

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import B2BCore
import B2BUI

struct LeadDetailView: View {
    let lead: Lead

    private var tierColor: Color { lead.score?.tier.color ?? .brandBlue }

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    heroCard
                    quickStatsRow
                    companyContactCard
                    projectCard
                    contactsSection
                    if let notes = lead.notes, !notes.isEmpty {
                        notesCard(notes)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(lead.company.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let phone = lead.company.phone {
                    Button {
                        callPhone(phone)
                    } label: {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.brandGreen)
                    }
                }
            }
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient: tier accent → deep black
            LinearGradient(
                colors: [tierColor.opacity(0.45), Color.brandBackground],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .cornerRadius(18)

            // Subtle top border in tier color
            VStack {
                Rectangle()
                    .fill(tierColor.opacity(0.6))
                    .frame(height: 2)
                    .cornerRadius(18)
                Spacer()
            }
            .cornerRadius(18)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    // Tier badge
                    if let score = lead.score {
                        HStack(spacing: 5) {
                            Image(systemName: score.tier.icon)
                                .font(.caption)
                                .foregroundColor(score.tier.color)
                            Text(score.tier.shortLabel)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(score.tier.color)
                                .tracking(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(score.tier.color.opacity(0.15))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(score.tier.color.opacity(0.3), lineWidth: 0.5)
                        )
                    }

                    Spacer()

                    // Large score
                    if let score = lead.score {
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("\(Int(score.overall * 100))")
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundColor(Color.primary)
                            Text("/ 100")
                                .font(.caption)
                                .foregroundColor(Color.secondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(lead.company.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                    Label(lead.company.address.city + ", " + lead.company.address.state,
                          systemImage: "location.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(18)
        }
        .frame(height: 188)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(tierColor.opacity(0.25), lineWidth: 0.5)
        )
    }

    // MARK: - Quick Stats Row

    private var quickStatsRow: some View {
        HStack(spacing: 0) {
            if let years = lead.company.yearsInBusiness {
                quickStat(value: "\(years) yrs", label: "Experience")
                statDivider
            }

            quickStat(
                value: "\(Int(lead.company.completionRate * 100))%",
                label: "Completed",
                valueColor: .brandGreen
            )

            if let license = lead.company.licenseStatus {
                statDivider
                quickStat(
                    value: license.rawValue.capitalized,
                    label: "License",
                    valueColor: license.color
                )
            }
        }
        .padding(.vertical, 14)
        .darkCard()
    }

    private func quickStat(value: String, label: String, valueColor: Color = Color.primary) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(valueColor)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.brandBorder.opacity(0.5))
            .frame(width: 1, height: 32)
    }

    // MARK: - Company Contact Card

    private var companyContactCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Company", icon: "building.2.fill")
                .padding(.bottom, 12)

            VStack(spacing: 8) {
                if let phone = lead.company.phone {
                    contactRow(icon: "phone.fill", text: phone, color: .brandGreen) {
                        callPhone(phone)
                    }
                }
                if let email = lead.company.email {
                    contactRow(icon: "envelope.fill", text: email, color: .brandBlue) {
                        sendEmail(email)
                    }
                }
                if let completed = lead.company.completedProjects,
                   let total = lead.company.totalProjects {
                    infoRow(
                        icon: "checkmark.circle.fill",
                        text: "\(completed) of \(total) projects completed",
                        color: .brandGreen
                    )
                }
            }
        }
        .padding(16)
        .darkCard()
    }

    private func contactRow(icon: String, text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                    .frame(width: 20)
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(Color.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color.brandCardElevated)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.brandBorder.opacity(0.25), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func infoRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(12)
        .background(Color.brandCardElevated)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.brandBorder.opacity(0.25), lineWidth: 0.5)
        )
    }

    // MARK: - Project Card

    private var projectCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Project", icon: "hammer.fill")
                .padding(.bottom, 12)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(lead.project.permitType.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.brandBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.brandBlue.opacity(0.12))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.brandBlue.opacity(0.3), lineWidth: 0.5)
                        )

                    Spacer()

                    StatusBadge(status: lead.status)
                }

                Text(lead.project.description)
                    .font(.body)
                    .foregroundColor(Color.primary)

                Rectangle()
                    .fill(Color.brandBorder.opacity(0.4))
                    .frame(height: 0.5)

                if let value = lead.project.estimatedValue {
                    HStack {
                        Text("Estimated Value")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(value.fullCurrency)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.brandGreen)
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundColor(.brandBlue)
                    Text(lead.project.address.oneLine)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let permit = lead.project.permitNumber {
                    HStack(spacing: 6) {
                        Image(systemName: "number")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("Permit \(permit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .darkCard()
    }

    // MARK: - Contacts Section

    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Contacts", icon: "person.2.fill")
                .padding(.horizontal, 4)

            if lead.decisionMakers.isEmpty {
                HStack {
                    Image(systemName: "person.slash")
                        .foregroundColor(.secondary)
                    Text("No contacts found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .darkCard()
            } else {
                ForEach(lead.decisionMakers) { dm in
                    DecisionMakerCard(decisionMaker: dm)
                }
            }
        }
    }

    // MARK: - Notes Card

    private func notesCard(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Notes", icon: "note.text")
                .padding(.bottom, 12)
            Text(notes)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .darkCard()
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.brandBlue)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.primary)
        }
    }

    // MARK: - Actions

    private func callPhone(_ phone: String) {
        let cleaned = phone.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(cleaned)") {
            #if canImport(UIKit)
            UIApplication.shared.open(url)
            #endif
        }
    }

    private func sendEmail(_ email: String) {
        #if canImport(UIKit)
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

// MARK: - Decision Maker Card

struct DecisionMakerCard: View {
    let decisionMaker: DecisionMaker

    private var initials: String {
        decisionMaker.name
            .components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Initials avatar
            ZStack {
                Circle()
                    .fill(decisionMaker.quality.color.opacity(0.15))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Circle()
                            .stroke(decisionMaker.quality.color.opacity(0.3), lineWidth: 1)
                    )
                Text(initials)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(decisionMaker.quality.color)
            }

            // Info
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(decisionMaker.name)
                        .font(.headline)
                        .foregroundColor(Color.primary)

                    HStack(spacing: 3) {
                        Circle()
                            .fill(decisionMaker.quality.color)
                            .frame(width: 5, height: 5)
                        Text(decisionMaker.quality.rawValue.capitalized)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(decisionMaker.quality.color)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(decisionMaker.quality.color.opacity(0.12))
                    .cornerRadius(6)
                }

                if let title = decisionMaker.title {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let email = decisionMaker.email {
                    Button {
                        sendEmail(email)
                    } label: {
                        Label(email, systemImage: "envelope")
                            .font(.caption)
                            .foregroundColor(.brandBlue)
                            .lineLimit(1)
                    }
                    .buttonStyle(.plain)
                } else if let phone = decisionMaker.phone {
                    Label(phone, systemImage: "phone")
                        .font(.caption)
                        .foregroundColor(.brandBlue)
                }

                Text("\(Int(decisionMaker.confidence * 100))% confidence")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 4)

            // Call button
            if let phone = decisionMaker.phone {
                Button {
                    callPhone(phone)
                } label: {
                    Image(systemName: "phone.fill")
                        .font(.subheadline)
                        .frame(width: 42, height: 42)
                        .background(Color.brandGreen)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
            }
        }
        .padding(14)
        .darkCard()
    }

    private func callPhone(_ phone: String) {
        let cleaned = phone.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        #if canImport(UIKit)
        if let url = URL(string: "tel://\(cleaned)") {
            UIApplication.shared.open(url)
        }
        #endif
    }

    private func sendEmail(_ email: String) {
        #if canImport(UIKit)
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

// MARK: - Color Extensions

extension LicenseStatus {
    var color: Color {
        switch self {
        case .active:    return .brandGreen
        case .inactive:  return .gray
        case .expired:   return .orange
        case .suspended: return .red
        case .unknown:   return .gray
        }
    }
}

extension ContactQuality {
    var color: Color {
        switch self {
        case .verified: return .brandGreen
        case .inferred: return .orange
        case .partial:  return .yellow
        case .none:     return .gray
        }
    }
}

#Preview {
    NavigationStack {
        LeadDetailView(lead: MockData.sampleLeads[0])
    }
}
