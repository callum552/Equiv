//
//  EquivWatch_Watch_AppUITests.swift
//  EquivWatch Watch AppUITests
//
//  Created by Callum Black on 31/01/2026.
//

import XCTest

final class EquivWatch_Watch_AppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchesAndShowsCategories() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Equiv"].waitForExistence(timeout: 5),
                       "App should show the Equiv navigation title")
    }

    @MainActor
    func testNavigateToCategory() throws {
        let app = XCUIApplication()
        app.launch()

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5),
                       "Category list should have at least one cell")
        firstCell.tap()

        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 5),
                       "Should navigate to converter view with a back button")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
