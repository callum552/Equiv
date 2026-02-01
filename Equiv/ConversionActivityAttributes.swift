//
//  ConversionActivityAttributes.swift
//  Equiv
//
//  Created by Callum Black on 31/01/2026.
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
