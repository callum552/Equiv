//
//  EquivWatch_Watch_AppTests.swift
//  EquivWatch Watch AppTests
//
//  Created by Callum Black on 31/01/2026.
//

import Testing
@testable import EquivWatch_Watch_App

struct EquivWatch_Watch_AppTests {

    @Test func allCategoriesHaveIcons() async throws {
        for category in UnitCategoryType.allCases {
            #expect(!category.icon.isEmpty, "Category \(category.displayName) should have an icon")
        }
    }

    @Test func allCategoriesHaveDisplayNames() async throws {
        for category in UnitCategoryType.allCases {
            #expect(!category.displayName.isEmpty, "Category \(category.rawValue) should have a display name")
        }
    }

    @Test func allCategoriesHaveUnits() async throws {
        for category in UnitCategoryType.allCases {
            let hasUnits = category.isCustom ? !category.customUnits.isEmpty : !category.dimensions.isEmpty
            #expect(hasUnits, "Category \(category.displayName) should have units")
        }
    }
}
