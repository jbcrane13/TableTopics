# Test Coverage Plan

## Project: Table Topics iOS
## Date: 2026-03-10
## Focus: Comprehensive test coverage + accessibility identifiers

## Current State
- Total tests: 0 (app has empty test directories, 82 tests exist in B2BCore dependency)
- Estimated coverage: 0% of interactive elements
- Silent failure paths: 6 locations
- Mock-only features: N/A (no tests at all)
- Key gaps: Everything — no unit tests, no UI tests, no integration tests

## Prerequisites
- Add test targets to project.yml (TableTopicsTests, TableTopicsUITests)
- Regenerate Xcode project with xcodegen
- Create test helpers and mock infrastructure

## Coverage Areas

### Area 1: Test Infrastructure Setup (Priority: P0)
- **Files to create**: project.yml (add test targets), test helpers
- **Tasks**:
  1. Add TableTopicsTests unit test target to project.yml
  2. Add TableTopicsUITests UI test target to project.yml
  3. Regenerate xcodeproj with xcodegen
  4. Create TestHelpers/MockAPIService.swift
  5. Verify build succeeds with empty test targets

### Area 2: ViewModel Unit Tests (Priority: P0)
- **Files to create**: TableTopicsTests/LeadsViewModelTests.swift
- **Tests to write** (Swift Testing):
  1. Initial state has empty leads, isLoading false, no error
  2. loadLeads() with mock data populates leads array
  3. loadLeads() sets isLoading during operation
  4. search() updates searchQuery and triggers loadLeads
  5. search() respects area lock (doesn't update state/city when locked)
  6. lockArea() persists to UserDefaults
  7. unlockArea() clears UserDefaults
  8. loadAreaLock() restores from UserDefaults on init
  9. hotLeads/warmLeads/coolLeads/coldLeads computed properties filter correctly
  10. lockedArea computed property formats correctly (city+state vs state only)
  11. selectedCategory defaults to 0
  12. usStates has 50 entries
- **Test types**: Unit (with mock API service)
- **Estimated test count**: 12

### Area 3: APIService Unit Tests (Priority: P0)
- **Files to create**: TableTopicsTests/APIServiceTests.swift
- **Tests to write** (Swift Testing):
  1. isConfigured returns false when no key
  2. setAPIKey stores key and isConfigured returns true
  3. clearAPIKey removes key and isConfigured returns false
  4. searchLeads throws noAPIKey when not configured
  5. estimatedCredits returns limit value
  6. APIError has correct error descriptions
- **Test types**: Unit
- **Estimated test count**: 6

### Area 4: Model & Formatting Tests (Priority: P1)
- **Files to create**: TableTopicsTests/ModelTests.swift
- **Tests to write** (Swift Testing):
  1. MockData.sampleLeads has 5 leads
  2. MockData hot/warm/cool/cold filtered arrays are non-empty where expected
  3. Double.compactCurrency formats millions correctly
  4. Double.compactCurrency formats thousands correctly
  5. Double.compactCurrency formats small values correctly
  6. Double.fullCurrency formats with dollar sign and commas
  7. LeadTier.icon returns correct SF Symbols
  8. LeadTier.shortLabel returns HOT/WARM/COOL/COLD
- **Test types**: Unit (pure functions)
- **Estimated test count**: 8

### Area 5: UI Tests — Home Screen (Priority: P1)
- **Files to create**: TableTopicsUITests/HomeViewUITests.swift
- **Tests to write** (XCTest/XCUITest):
  1. Home screen loads and shows search header
  2. Category pills are visible and tappable
  3. Selecting category pill updates selection state
  4. State picker menu opens and allows selection
  5. Search button triggers search (leads appear)
  6. Tier filter chips filter results
  7. Lead card shows company name, location, score
  8. Lead card contact action buttons are tappable
  9. Tapping lead card navigates to detail view
  10. Settings button opens settings sheet
  11. Empty state shows "Find Your Next Lead"
  12. Stats strip shows Hot/Pipeline/Total counts
- **Test types**: UI (XCUITest)
- **Estimated test count**: 12

### Area 6: UI Tests — Detail Screen (Priority: P1)
- **Files to create**: TableTopicsUITests/LeadDetailUITests.swift
- **Tests to write** (XCTest/XCUITest):
  1. Detail screen shows hero card with company name
  2. Score badge displays correct value
  3. Quick actions bar shows Call/Email/Text buttons
  4. Company contact card shows phone and email
  5. Project card shows permit type and estimated value
  6. Decision maker cards show name and quality badge
  7. Decision maker call/text buttons are present
  8. Back navigation returns to home screen
- **Test types**: UI (XCUITest)
- **Estimated test count**: 8

### Area 7: UI Tests — Settings Sheet (Priority: P2)
- **Files to create**: TableTopicsUITests/SettingsUITests.swift
- **Tests to write** (XCTest/XCUITest):
  1. Settings sheet opens from home screen
  2. API status indicator is visible
  3. Configure API Key button is tappable
  4. Demo data toggle is functional
  5. Area lock fields accept input
  6. Done button closes settings sheet
- **Test types**: UI (XCUITest)
- **Estimated test count**: 6

### Area 8: Contract/Integration Tests (Priority: P1)
- **Files to create**: TableTopicsTests/ShovelsAPIContractTests.swift, Tests/TestFixtures/shovels-permits-response.json
- **Tests to write** (Swift Testing):
  1. Shovels permit response JSON parses correctly (contract test with fixture)
  2. Lead construction from permit data produces valid Lead objects
  3. Score calculation produces reasonable values for mock leads
  4. Phone number cleaning regex works correctly
  5. URL construction for tel/mailto/sms works with valid inputs
  6. URL construction handles edge cases (special chars, empty strings)
- **Test types**: Contract + Integration
- **Estimated test count**: 6

## Execution Strategy
- Workers: 3 parallel agents
  - Worker 1: Areas 1 (infra) → 2 (ViewModel) → 3 (APIService)
  - Worker 2: Areas 4 (Models) → 8 (Contract)
  - Worker 3: Areas 5 (Home UI) → 6 (Detail UI) → 7 (Settings UI)
- Dependencies: Area 1 must complete before all others

## Verification Criteria
- [ ] All tests build successfully
- [ ] No existing code broken
- [ ] Every interactive element has accessibility identifier
- [ ] Every ViewModel method has unit test
- [ ] Every screen has UI tests for key flows
- [ ] Contract test with fixture JSON for Shovels API
- [ ] Phone/email URL construction tested
- [ ] Changes committed and pushed
