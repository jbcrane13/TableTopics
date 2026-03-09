// DesignSystem.swift
// Brand tokens and shared UI components — OLED Dark theme

import SwiftUI
import B2BCore

// MARK: - Brand Colors (Dark OLED Palette)

extension Color {
    // Backgrounds — layered depth
    static let brandBackground    = Color(red: 0.008, green: 0.024, blue: 0.090)  // #020617 OLED black
    static let brandCard          = Color(red: 0.059, green: 0.090, blue: 0.165)  // #0F172A card surface
    static let brandCardElevated  = Color(red: 0.118, green: 0.161, blue: 0.231)  // #1E293B elevated

    // Borders & separators
    static let brandBorder        = Color(red: 0.200, green: 0.255, blue: 0.337)  // #334155

    // Accents
    static let brandBlue          = Color(red: 0.220, green: 0.741, blue: 0.976)  // #38BDF8 sky blue
    static let brandGreen         = Color(red: 0.133, green: 0.773, blue: 0.369)  // #22C55E CTA green

    // Legacy aliases (used internally)
    static let brandNavy          = Color(red: 0.059, green: 0.090, blue: 0.165)  // #0F172A
    static let brandSlate         = Color(red: 0.282, green: 0.337, blue: 0.416)  // #475569
}

// MARK: - LeadTier UI Extensions

extension LeadTier {
    var icon: String {
        switch self {
        case .hot:  return "flame.fill"
        case .warm: return "sun.max.fill"
        case .cool: return "drop.fill"
        case .cold: return "snowflake"
        }
    }

    var shortLabel: String {
        switch self {
        case .hot:  return "HOT"
        case .warm: return "WARM"
        case .cool: return "COOL"
        case .cold: return "COLD"
        }
    }
}

// MARK: - Currency Formatting

extension Double {
    var compactCurrency: String {
        if self >= 1_000_000 { return String(format: "$%.1fM", self / 1_000_000) }
        if self >= 1_000     { return String(format: "$%.0fK", self / 1_000) }
        return "$\(Int(self))"
    }

    var fullCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "$0"
    }
}

// MARK: - Card Modifier

struct DarkCard: ViewModifier {
    var elevated: Bool = false

    func body(content: Content) -> some View {
        content
            .background(elevated ? Color.brandCardElevated : Color.brandCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.brandBorder.opacity(0.35), lineWidth: 0.5)
            )
    }
}

extension View {
    func darkCard(elevated: Bool = false) -> some View {
        modifier(DarkCard(elevated: elevated))
    }
}

// MARK: - ScoreBadge

struct ScoreBadge: View {
    let score: LeadScore

    var body: some View {
        VStack(spacing: 1) {
            Text("\(Int(score.overall * 100))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(score.tier.color)
            Text(score.tier.shortLabel)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(score.tier.color.opacity(0.8))
                .tracking(0.5)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(score.tier.color.opacity(0.18))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(score.tier.color.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - TierChip

struct TierChip: View {
    let title: String
    let count: Int
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title)
                    .fontWeight(.semibold)
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(isSelected ? Color.white.opacity(0.2) : color.opacity(0.2))
                    .foregroundColor(isSelected ? .white : color)
                    .cornerRadius(6)
            }
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color.brandCardElevated)
            .foregroundColor(isSelected ? .white : Color.primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.brandBorder.opacity(0.5), lineWidth: 0.5)
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
