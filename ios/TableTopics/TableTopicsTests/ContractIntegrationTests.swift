// ContractIntegrationTests.swift
// Contract and integration tests for TableTopics

import Testing
import Foundation
@testable import TableTopics
import B2BCore

// MARK: - Score Calculation

@Test("Score calculation produces reasonable values for all sample leads")
func testScoreCalculationProducesReasonableValues() {
    let leads = MockData.sampleLeads

    for lead in leads {
        let score = LeadScore.calculate(for: lead)
        #expect(score.overall >= 0.0, "Score for \(lead.company.name) should be >= 0")
        #expect(score.overall <= 1.0, "Score for \(lead.company.name) should be <= 1")

        let tier = score.tier
        switch score.overall {
        case 0.70...:
            #expect(tier == .hot, "\(lead.company.name) with score \(score.overall) should be hot")
        case 0.50..<0.70:
            #expect(tier == .warm, "\(lead.company.name) with score \(score.overall) should be warm")
        case 0.30..<0.50:
            #expect(tier == .cool, "\(lead.company.name) with score \(score.overall) should be cool")
        default:
            #expect(tier == .cold, "\(lead.company.name) with score \(score.overall) should be cold")
        }
    }
}

// MARK: - Tier Thresholds

struct TierThresholdCase: CustomTestStringConvertible, Sendable {
    let score: Double
    let expectedTier: LeadTier

    var testDescription: String {
        "score \(score) -> \(expectedTier.rawValue)"
    }
}

@Test("Lead score tier thresholds match specification", arguments: [
    TierThresholdCase(score: 1.0, expectedTier: .hot),
    TierThresholdCase(score: 0.70, expectedTier: .hot),
    TierThresholdCase(score: 0.69, expectedTier: .warm),
    TierThresholdCase(score: 0.50, expectedTier: .warm),
    TierThresholdCase(score: 0.49, expectedTier: .cool),
    TierThresholdCase(score: 0.30, expectedTier: .cool),
    TierThresholdCase(score: 0.29, expectedTier: .cold),
    TierThresholdCase(score: 0.0, expectedTier: .cold),
])
func testLeadScoreTierThresholds(testCase: TierThresholdCase) {
    let leadScore = LeadScore(overall: testCase.score)
    #expect(leadScore.tier == testCase.expectedTier,
            "Score \(testCase.score) should map to \(testCase.expectedTier.rawValue), got \(leadScore.tier.rawValue)")
}

// MARK: - Phone Number Cleaning

struct PhoneCleaningCase: CustomTestStringConvertible, Sendable {
    let input: String
    let expected: String

    var testDescription: String {
        "\"\(input)\" -> \"\(expected)\""
    }
}

@Test("Phone number cleaning removes non-numeric characters", arguments: [
    PhoneCleaningCase(input: "512-555-1234", expected: "5125551234"),
    PhoneCleaningCase(input: "(713) 555-2345", expected: "7135552345"),
    PhoneCleaningCase(input: "+1-409-555-4567", expected: "+14095554567"),
    PhoneCleaningCase(input: "555.123.4567", expected: "5551234567"),
])
func testPhoneNumberCleaning(testCase: PhoneCleaningCase) {
    let cleaned = testCase.input.replacingOccurrences(
        of: "[^0-9+]", with: "", options: .regularExpression
    )
    #expect(cleaned == testCase.expected)
}

// MARK: - URL Construction

@Test("URL construction for tel, mailto, and sms schemes produces valid URLs")
func testURLConstructionForContacts() {
    let telURL = URL(string: "tel://5125551234")
    #expect(telURL != nil, "tel URL should be constructible")
    #expect(telURL?.scheme == "tel", "tel URL should have tel scheme")

    let mailtoURL = URL(string: "mailto:test@test.com")
    #expect(mailtoURL != nil, "mailto URL should be constructible")
    #expect(mailtoURL?.scheme == "mailto", "mailto URL should have mailto scheme")

    let smsURL = URL(string: "sms:5125551234")
    #expect(smsURL != nil, "sms URL should be constructible")
    #expect(smsURL?.scheme == "sms", "sms URL should have sms scheme")
}

@Test("URL construction edge cases handle empty and special characters gracefully")
func testURLConstructionEdgeCases() {
    let emptyURL = URL(string: "")
    #expect(emptyURL == nil, "Empty string should not produce a valid URL")

    let telEmpty = URL(string: "tel://")
    #expect(telEmpty != nil, "tel with empty number is still a parseable URL")

    let emailWithPlus = URL(string: "mailto:user+tag@example.com")
    #expect(emailWithPlus != nil, "Email with + should produce a valid mailto URL")

    let emailWithDots = URL(string: "mailto:first.last@sub.domain.com")
    #expect(emailWithDots != nil, "Email with dots should produce a valid mailto URL")

    let smsEmpty = URL(string: "sms:")
    #expect(smsEmpty != nil, "sms with empty number is still a parseable URL")
}

// MARK: - Mock Data Validation

@Test("MockData sample leads all have valid scores and decision maker contacts")
func testMockDataLeadsHaveValidScores() {
    let leads = MockData.sampleLeads
    #expect(leads.count == 5, "MockData should contain 5 sample leads")

    for lead in leads {
        #expect(lead.score != nil, "\(lead.company.name) should have a non-nil score")

        if let score = lead.score {
            #expect(score.overall >= 0.0 && score.overall <= 1.0,
                    "\(lead.company.name) score \(score.overall) should be in 0-1 range")

            let validTiers: [LeadTier] = [.hot, .warm, .cool, .cold]
            #expect(validTiers.contains(score.tier),
                    "\(lead.company.name) should have a valid tier")
        }

        for dm in lead.decisionMakers {
            if dm.email != nil || dm.phone != nil {
                #expect(dm.hasContact == true,
                        "\(dm.name) with email or phone should have hasContact == true")
            }
        }
    }
}
