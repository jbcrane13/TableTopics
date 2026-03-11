import XCTest

@MainActor
final class LeadDetailUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    /// Helper: navigates from home to the first lead's detail view.
    private func navigateToFirstLeadDetail() {
        let leadCard = app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH 'lead_card_'")).firstMatch
        XCTAssertTrue(leadCard.waitForExistence(timeout: 5), "Mock data should produce at least one lead card")
        leadCard.tap()

        let heroCard = app.otherElements["detail_card_hero"]
        XCTAssertTrue(heroCard.waitForExistence(timeout: 5), "Detail view should appear after tapping lead card")
    }

    // MARK: - 1. Detail Screen Shows

    func testDetailScreenShows() {
        navigateToFirstLeadDetail()

        let heroCard = app.otherElements["detail_card_hero"]
        XCTAssertTrue(heroCard.exists, "Detail screen should display the hero card")
    }

    // MARK: - 2. Hero Card Displays Company Info

    func testHeroCardDisplaysCompanyInfo() {
        navigateToFirstLeadDetail()

        let companyName = app.staticTexts["detail_label_company_name"]
        XCTAssertTrue(companyName.waitForExistence(timeout: 3), "Hero card should show company name")
        XCTAssertFalse(companyName.label.isEmpty, "Company name should not be empty")

        let location = app.staticTexts["detail_label_location"]
        XCTAssertTrue(location.exists, "Hero card should show location")
        XCTAssertFalse(location.label.isEmpty, "Location should not be empty")
    }

    // MARK: - 3. Score Badge Visible

    func testScoreBadgeVisible() {
        navigateToFirstLeadDetail()

        let scoreLabel = app.staticTexts["detail_label_score"]
        XCTAssertTrue(scoreLabel.waitForExistence(timeout: 3), "Score display should be visible on detail screen")
        XCTAssertFalse(scoreLabel.label.isEmpty, "Score label should contain a value")
    }

    // MARK: - 4. Quick Actions Bar Present

    func testQuickActionsBarPresent() {
        navigateToFirstLeadDetail()

        let quickActions = app.otherElements["detail_bar_quick_actions"]
        XCTAssertTrue(quickActions.waitForExistence(timeout: 3), "Quick action bar should be present")

        let callButton = app.buttons["detail_button_call"]
        let emailButton = app.buttons["detail_button_email"]
        let textButton = app.buttons["detail_button_text"]

        XCTAssertTrue(callButton.exists, "Call button should exist in quick actions")
        XCTAssertTrue(emailButton.exists, "Email button should exist in quick actions")
        XCTAssertTrue(textButton.exists, "Text button should exist in quick actions")
    }

    // MARK: - 5. Company Contact Card Shows

    func testCompanyContactCardShows() {
        navigateToFirstLeadDetail()

        let companyCard = app.otherElements["detail_card_company"].firstMatch
        XCTAssertTrue(companyCard.waitForExistence(timeout: 3), "Company card should be present on detail view")

        // Scroll down if needed to find contact rows
        let companyPhone = app.buttons["detail_button_company_phone"]
        if !companyPhone.exists {
            app.swipeUp()
        }
        XCTAssertTrue(companyPhone.waitForExistence(timeout: 3), "Company phone row should exist in company card")

        let companyEmail = app.buttons["detail_button_company_email"]
        XCTAssertTrue(companyEmail.exists, "Company email row should exist in company card")
    }

    // MARK: - 6. Project Card Shows

    func testProjectCardShows() {
        navigateToFirstLeadDetail()

        // Scroll to find project card
        let projectCard = app.otherElements["detail_card_project"].firstMatch
        if !projectCard.exists {
            app.swipeUp()
        }
        XCTAssertTrue(projectCard.waitForExistence(timeout: 3), "Project card should be present")

        let permitBadge = app.otherElements["detail_badge_permit_type"].firstMatch
        if !permitBadge.exists {
            app.swipeUp()
        }
        XCTAssertTrue(permitBadge.waitForExistence(timeout: 3), "Permit type badge should be present in project card")

        let valueRow = app.otherElements["detail_row_estimated_value"].firstMatch
        if !valueRow.exists {
            app.swipeUp()
        }
        XCTAssertTrue(valueRow.waitForExistence(timeout: 3), "Estimated value row should be present in project card")
    }

    // MARK: - 7. Decision Maker Card Shows

    func testDecisionMakerCardShows() {
        navigateToFirstLeadDetail()

        // Scroll to contacts section
        let contactsSection = app.otherElements["detail_section_contacts"].firstMatch
        if !contactsSection.exists {
            app.swipeUp()
            app.swipeUp()
        }

        let dmCard = app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH 'dm_card_'")).firstMatch
        XCTAssertTrue(dmCard.waitForExistence(timeout: 5), "At least one decision maker card should be visible")

        // DM card should contain a name
        let nameTexts = dmCard.staticTexts
        XCTAssertTrue(nameTexts.count > 0, "Decision maker card should display a name")
    }

    // MARK: - 8. Back Navigation Returns Home

    func testBackNavigationReturnsHome() {
        navigateToFirstLeadDetail()

        // Tap the navigation back button
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "Back button should exist in navigation bar")
        backButton.tap()

        let home = app.otherElements["screen_home"]
        XCTAssertTrue(home.waitForExistence(timeout: 5), "Home screen should reappear after navigating back from detail")
    }
}
