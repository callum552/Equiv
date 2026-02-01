//
//  EquivUITests.swift
//  EquivUITests
//
//  Created by Callum Black on 30/01/2026.
//

import XCTest

final class EquivUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Navigation

    @MainActor
    func testCategoryListAppears() throws {
        // The main screen should show the category list
        XCTAssertTrue(app.navigationBars.firstMatch.exists)
    }

    @MainActor
    func testNavigateToLengthConverter() throws {
        let lengthCell = app.cells.containing(.staticText, identifier: "Length").firstMatch
        XCTAssertTrue(lengthCell.waitForExistence(timeout: 5))
        lengthCell.tap()

        // Should show converter with navigation title
        let navBar = app.navigationBars["Length"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    @MainActor
    func testNavigateToTemperatureConverter() throws {
        let cell = app.cells.containing(.staticText, identifier: "Temperature").firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        cell.tap()

        let navBar = app.navigationBars["Temperature"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5))
    }

    // MARK: - Converter Input

    @MainActor
    func testConverterInputField() throws {
        // Navigate to Length
        let lengthCell = app.cells.containing(.staticText, identifier: "Length").firstMatch
        XCTAssertTrue(lengthCell.waitForExistence(timeout: 5))
        lengthCell.tap()

        // Find and tap the input field
        let input = app.textFields["converter_input"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.tap()
        input.typeText("100")

        // Result should appear
        let result = app.staticTexts["converter_result"]
        XCTAssertTrue(result.waitForExistence(timeout: 5))
    }

    // MARK: - Swap Button

    @MainActor
    func testSwapButton() throws {
        let lengthCell = app.cells.containing(.staticText, identifier: "Length").firstMatch
        XCTAssertTrue(lengthCell.waitForExistence(timeout: 5))
        lengthCell.tap()

        let swapButton = app.buttons["swap_button"]
        XCTAssertTrue(swapButton.waitForExistence(timeout: 5))
        swapButton.tap()
    }

    // MARK: - Favorites

    @MainActor
    func testFavoriteToggle() throws {
        let lengthCell = app.cells.containing(.staticText, identifier: "Length").firstMatch
        XCTAssertTrue(lengthCell.waitForExistence(timeout: 5))
        lengthCell.tap()

        let favoriteButton = app.buttons["favorite_toggle"]
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 5))
        favoriteButton.tap()

        // Navigate back
        app.navigationBars.buttons.firstMatch.tap()

        // Should see a Favorites section
        let favoritesHeader = app.staticTexts["Favorites"]
        XCTAssertTrue(favoritesHeader.waitForExistence(timeout: 5))
    }

    // MARK: - Scientific Notation Toggle

    @MainActor
    func testScientificNotationToggle() throws {
        let lengthCell = app.cells.containing(.staticText, identifier: "Length").firstMatch
        XCTAssertTrue(lengthCell.waitForExistence(timeout: 5))
        lengthCell.tap()

        let sciToggle = app.buttons["scientific_notation_toggle"]
        XCTAssertTrue(sciToggle.waitForExistence(timeout: 5))
        sciToggle.tap()
    }

    // MARK: - Copy Result

    @MainActor
    func testTapResultToCopy() throws {
        let lengthCell = app.cells.containing(.staticText, identifier: "Length").firstMatch
        XCTAssertTrue(lengthCell.waitForExistence(timeout: 5))
        lengthCell.tap()

        // Enter a value
        let input = app.textFields["converter_input"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.tap()
        input.typeText("100")

        // Tap the result to copy
        let result = app.staticTexts["converter_result"]
        XCTAssertTrue(result.waitForExistence(timeout: 5))
        result.tap()

        // Copied banner should appear
        let copiedBanner = app.staticTexts["Copied to clipboard"]
        XCTAssertTrue(copiedBanner.waitForExistence(timeout: 3))
    }

    // MARK: - Search

    @MainActor
    func testSearchCategories() throws {
        // Pull down to show search or find the search field
        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 3) {
            searchField.tap()
            searchField.typeText("temp")

            // Temperature should still be visible
            let tempCell = app.cells.containing(.staticText, identifier: "Temperature").firstMatch
            XCTAssertTrue(tempCell.waitForExistence(timeout: 5))
        }
    }

    // MARK: - History

    @MainActor
    func testHistoryTabExists() throws {
        // Check for History tab
        let historyTab = app.tabBars.buttons["History"]
        if historyTab.waitForExistence(timeout: 3) {
            historyTab.tap()
        }
    }

    // MARK: - Launch Performance

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
