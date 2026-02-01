//
//  ConversionHistoryEntry.swift
//  Equiv
//
//  Created by Callum Black on 31/01/2026.
//

import Foundation
import SwiftData

@Model
final class ConversionHistoryEntry {
    var categoryRawValue: String = ""
    var sourceUnitName: String = ""
    var destinationUnitName: String = ""
    var inputValue: String = ""
    var resultValue: String = ""
    var timestamp: Date = Date.now

    init(categoryRawValue: String, sourceUnitName: String,
         destinationUnitName: String, inputValue: String,
         resultValue: String, timestamp: Date = .now) {
        self.categoryRawValue = categoryRawValue
        self.sourceUnitName = sourceUnitName
        self.destinationUnitName = destinationUnitName
        self.inputValue = inputValue
        self.resultValue = resultValue
        self.timestamp = timestamp
    }

    var category: UnitCategoryType? {
        UnitCategoryType(rawValue: categoryRawValue)
    }
}
