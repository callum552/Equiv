//
//  FavoriteCategory.swift
//  Equiv
//
//  Created by Callum Black on 31/01/2026.
//

import Foundation
import SwiftData

@Model
final class FavoriteCategory {
    var categoryRawValue: String = ""
    var dateAdded: Date = Date.now

    init(categoryRawValue: String, dateAdded: Date = .now) {
        self.categoryRawValue = categoryRawValue
        self.dateAdded = dateAdded
    }

    var category: UnitCategoryType? {
        UnitCategoryType(rawValue: categoryRawValue)
    }
}
