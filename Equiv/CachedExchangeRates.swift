//
//  CachedExchangeRates.swift
//  Equiv
//
//  Created by Callum Black on 31/01/2026.
//

import Foundation
import SwiftData

@Model
final class CachedExchangeRates {
    var ratesJSON: String = ""
    var baseCurrency: String = "USD"
    var lastFetched: Date = Date.now

    init(ratesJSON: String, baseCurrency: String, lastFetched: Date = .now) {
        self.ratesJSON = ratesJSON
        self.baseCurrency = baseCurrency
        self.lastFetched = lastFetched
    }
}
