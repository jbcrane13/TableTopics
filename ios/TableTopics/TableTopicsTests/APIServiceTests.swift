// APIServiceTests.swift
// Unit tests for APIService

import Testing
import Foundation
@testable import TableTopics
import B2BCore

@Suite("APIService Tests", .serialized)
struct APIServiceTests {

    private let defaultKey = "k08-LvykVPjfJROkN7FXUYKEmOfsqCp8SSWvMb8VbC0"

    private func restoreDefaultKey() {
        APIService.shared.setAPIKey(defaultKey)
    }

    @Test("isConfigured returns true with default hardcoded key")
    func isConfiguredWithDefaultKey() {
        restoreDefaultKey()
        #expect(APIService.shared.isConfigured == true)
    }

    @Test("clearAPIKey makes isConfigured return false")
    func clearAPIKeyMakesUnconfigured() {
        restoreDefaultKey()
        APIService.shared.clearAPIKey()
        #expect(APIService.shared.isConfigured == false)
        restoreDefaultKey()
    }

    @Test("setAPIKey restores configured state after clearing")
    func setAPIKeyRestoresConfigured() {
        restoreDefaultKey()
        APIService.shared.clearAPIKey()
        #expect(APIService.shared.isConfigured == false)

        APIService.shared.setAPIKey("test-key-12345")
        #expect(APIService.shared.isConfigured == true)
        restoreDefaultKey()
    }

    @Test("estimatedCredits returns the limit value")
    func estimatedCreditsReturnsLimit() {
        #expect(APIService.shared.estimatedCredits(for: 15) == 15)
        #expect(APIService.shared.estimatedCredits(for: 50) == 50)
        #expect(APIService.shared.estimatedCredits(for: 1) == 1)
    }

    @Test("All APIError cases have non-empty errorDescription")
    func apiErrorDescriptions() {
        let cases: [APIError] = [
            .noAPIKey,
            .rateLimited(retryAfter: 30),
            .rateLimited(retryAfter: nil),
            .noResults,
            .networkError(URLError(.notConnectedToInternet)),
            .invalidResponse
        ]
        for error in cases {
            let description = error.errorDescription
            #expect(description != nil)
            #expect(!description!.isEmpty)
        }
    }

    @Test("searchLeads throws noAPIKey when key is cleared")
    func searchLeadsThrowsWhenNoKey() async throws {
        restoreDefaultKey()
        APIService.shared.clearAPIKey()

        await #expect(throws: APIError.self) {
            _ = try await APIService.shared.searchLeads(
                query: "restaurant",
                stateCode: "TX",
                limit: 5
            )
        }
        restoreDefaultKey()
    }
}
