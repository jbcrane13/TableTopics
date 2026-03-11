// ModelTests.swift
// Tests for MockData, currency formatting, and LeadTier extensions

import Testing
@testable import TableTopics
import B2BCore

@Suite("Model & Extension Tests")
struct ModelTests {

    // MARK: - MockData

    @Test("sampleLeads contains exactly 5 leads")
    func sampleLeadsCount() {
        #expect(MockData.sampleLeads.count == 5)
    }

    @Test("hotLeads is not empty")
    func hotLeadsNonEmpty() {
        #expect(!MockData.hotLeads.isEmpty)
    }

    // MARK: - compactCurrency

    @Test("compactCurrency formats millions correctly")
    func compactCurrencyMillions() {
        #expect(1_500_000.0.compactCurrency == "$1.5M")
    }

    @Test("compactCurrency formats thousands correctly")
    func compactCurrencyThousands() {
        #expect(850_000.0.compactCurrency == "$850K")
    }

    @Test("compactCurrency formats small values correctly")
    func compactCurrencySmall() {
        #expect(500.0.compactCurrency == "$500")
    }

    // MARK: - fullCurrency

    @Test("fullCurrency formats with commas and dollar sign")
    func fullCurrencyFormat() {
        let formatted = 1_200_000.0.fullCurrency
        #expect(formatted.contains("$"))
        #expect(formatted.contains("1,200,000"))
    }

    // MARK: - LeadTier Extensions

    @Test("Each LeadTier has a non-empty icon string")
    func leadTierIcons() {
        let tiers: [LeadTier] = [.hot, .warm, .cool, .cold]
        for tier in tiers {
            #expect(!tier.icon.isEmpty)
        }
        #expect(LeadTier.hot.icon == "flame.fill")
        #expect(LeadTier.warm.icon == "sun.max.fill")
        #expect(LeadTier.cool.icon == "drop.fill")
        #expect(LeadTier.cold.icon == "snowflake")
    }

    @Test("LeadTier shortLabels match expected values")
    func leadTierShortLabels() {
        #expect(LeadTier.hot.shortLabel == "HOT")
        #expect(LeadTier.warm.shortLabel == "WARM")
        #expect(LeadTier.cool.shortLabel == "COOL")
        #expect(LeadTier.cold.shortLabel == "COLD")
    }
}
