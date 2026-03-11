import XCTest

@MainActor
final class SettingsUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    /// Helper: opens the settings sheet from the home screen.
    private func openSettings() {
        let settingsButton = app.buttons["home_button_settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings gear button should exist on home screen")
        settingsButton.tap()

        let settingsScreen = app.otherElements["screen_settings"].firstMatch
        XCTAssertTrue(settingsScreen.waitForExistence(timeout: 5), "Settings sheet should appear")
    }

    // MARK: - 1. Settings Sheet Opens

    func testSettingsSheetOpens() {
        openSettings()

        let doneButton = app.buttons["settings_button_done"]
        XCTAssertTrue(doneButton.exists, "Settings sheet should contain a Done button")
    }

    // MARK: - 2. API Status Visible

    func testAPIStatusVisible() {
        openSettings()

        let apiStatus = app.otherElements["settings_row_api_status"].firstMatch
        if !apiStatus.exists {
            // Try as a button or static text fallback
            let apiStatusButton = app.buttons["settings_row_api_status"].firstMatch
            let apiStatusText = app.staticTexts["settings_row_api_status"].firstMatch
            let found = apiStatus.exists || apiStatusButton.exists || apiStatusText.exists
            XCTAssertTrue(found, "API status row should be visible in settings")
        } else {
            XCTAssertTrue(apiStatus.exists, "API status row should be visible in settings")
        }
    }

    // MARK: - 3. Configure Key Button Tappable

    func testConfigureKeyButtonTappable() {
        openSettings()

        let configureButton = app.buttons["settings_button_configure_key"]
        XCTAssertTrue(configureButton.waitForExistence(timeout: 3), "Configure key button should exist")
        configureButton.tap()

        let apiKeyField = app.secureTextFields["settings_textfield_api_key"].firstMatch
        if !apiKeyField.exists {
            // May be a regular text field depending on implementation
            let regularField = app.textFields["settings_textfield_api_key"].firstMatch
            XCTAssertTrue(
                apiKeyField.waitForExistence(timeout: 3) || regularField.waitForExistence(timeout: 3),
                "API key text field should appear after tapping configure"
            )
        } else {
            XCTAssertTrue(apiKeyField.exists, "API key secure text field should appear after tapping configure")
        }
    }

    // MARK: - 4. Demo Data Toggle Works

    func testDemoDataToggleWorks() {
        openSettings()

        let toggle = app.switches["settings_toggle_demo_data"].firstMatch
        if !toggle.exists {
            app.swipeUp()
        }
        XCTAssertTrue(toggle.waitForExistence(timeout: 3), "Demo data toggle should exist in settings")
        XCTAssertTrue(toggle.isEnabled, "Demo data toggle should be interactive")

        // Verify toggle has a value (on or off)
        let value = toggle.value as? String
        XCTAssertNotNil(value, "Toggle should report its current value")
    }

    // MARK: - 5. Area Lock Fields Exist

    func testAreaLockFieldsExist() {
        openSettings()

        // Scroll to find lock fields if needed
        let lockState = app.textFields["settings_textfield_lock_state"].firstMatch
        if !lockState.exists {
            app.swipeUp()
        }
        XCTAssertTrue(lockState.waitForExistence(timeout: 3), "Lock state text field should exist in settings")

        let lockCity = app.textFields["settings_textfield_lock_city"].firstMatch
        XCTAssertTrue(lockCity.waitForExistence(timeout: 3), "Lock city text field should exist in settings")
    }

    // MARK: - 6. Done Button Closes Sheet

    func testDoneButtonClosesSheet() {
        openSettings()

        let doneButton = app.buttons["settings_button_done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 3), "Done button should exist")
        doneButton.tap()

        // Verify settings is dismissed and home screen is visible again
        let home = app.otherElements["screen_home"]
        XCTAssertTrue(home.waitForExistence(timeout: 5), "Home screen should be visible after dismissing settings")

        // Verify settings sheet is gone
        let settingsScreen = app.otherElements["screen_settings"].firstMatch
        XCTAssertFalse(settingsScreen.exists, "Settings sheet should no longer be visible after tapping Done")
    }
}
