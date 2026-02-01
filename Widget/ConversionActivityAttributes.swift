//
//  ConversionActivityAttributes.swift
//  Widget
//
//  Shared ActivityKit attributes for Live Activities.
//  Keep in sync with Equiv/ConversionActivityAttributes.swift.
//

import ActivityKit
import Foundation

struct ConversionActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var inputValue: String
        var resultValue: String
        var sourceUnitSymbol: String
        var destinationUnitSymbol: String
    }

    var categoryName: String
}
