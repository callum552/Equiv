//
//  CustomConversionEntry.swift
//  Equiv
//
//  A user-defined unit within a named custom conversion group.
//  Multiple entries sharing the same groupName form a custom category.
//

import Foundation
import SwiftData

@Model
final class CustomConversionEntry {
    var groupName: String = ""
    var unitName: String = ""
    var unitSymbol: String = ""
    /// Conversion factor relative to other units in the same group.
    /// Conversion: result = inputValue * fromUnit.toBaseFactor / toUnit.toBaseFactor
    var toBaseFactor: Double = 1.0
    var sortOrder: Int = 0
    var dateCreated: Date = Date.now

    init(groupName: String, unitName: String, unitSymbol: String,
         toBaseFactor: Double, sortOrder: Int = 0) {
        self.groupName = groupName
        self.unitName = unitName
        self.unitSymbol = unitSymbol
        self.toBaseFactor = toBaseFactor
        self.sortOrder = sortOrder
    }
}
