//
//  WatchConverterViewModel.swift
//  EquivWatch Watch App
//
//  Created by Callum Black on 31/01/2026.
//

import Foundation

struct CrownStep {
    let value: Double
    let label: String
}

@Observable
class WatchConverterViewModel {
    let category: UnitCategoryType

    var sourceIndex: Int = 0
    var destinationIndex: Int = 1
    var crownValue: Double = 0
    var stepIndex: Int = 2

    let steps: [CrownStep] = [
        CrownStep(value: 0.01, label: "0.01"),
        CrownStep(value: 0.1, label: "0.1"),
        CrownStep(value: 1, label: "1"),
        CrownStep(value: 10, label: "10"),
        CrownStep(value: 100, label: "100"),
    ]

    // MARK: - Currency state

    private(set) var hasCurrencyRates: Bool = false
    private var currencyRates: [String: Double] = [:]
    private var currencyCodes: [String] = []

    // MARK: - Init

    init(category: UnitCategoryType) {
        self.category = category
        if category.isCurrency {
            loadCurrencyRates()
            NotificationCenter.default.addObserver(
                forName: .watchRatesDidUpdate,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadCurrencyRates()
            }
        }
    }

    // MARK: - Currency loading

    private func loadCurrencyRates() {
        guard let ratesData = UserDefaults.standard.data(forKey: WatchSessionManager.ratesKey),
              let rates = try? JSONDecoder().decode([String: Double].self, from: ratesData) else {
            hasCurrencyRates = false
            currencyRates = [:]
            currencyCodes = []
            return
        }
        currencyRates = rates

        if let codesData = UserDefaults.standard.data(forKey: WatchSessionManager.codesKey),
           let codes = try? JSONDecoder().decode([String].self, from: codesData) {
            currencyCodes = codes.filter { rates[$0] != nil }
        } else {
            currencyCodes = rates.keys.sorted()
        }
        hasCurrencyRates = !currencyCodes.isEmpty
    }

    // MARK: - Computed properties

    var crownStep: Double {
        steps[stepIndex].value
    }

    var unitCount: Int {
        if category.isCurrency {
            return hasCurrencyRates ? currencyCodes.count : 0
        }
        return category.isCustom ? category.customUnits.count : category.dimensions.count
    }

    var sourceSymbol: String { unitSymbol(at: sourceIndex) }
    var destinationSymbol: String { unitSymbol(at: destinationIndex) }

    var formattedInput: String {
        formatValue(crownValue)
    }

    var result: String {
        guard crownValue != 0 else { return "" }
        if category.isCurrency {
            return convertCurrency(value: crownValue)
        } else if category.isCustom {
            return convertCustom(value: crownValue)
        } else {
            return convertFoundation(value: crownValue)
        }
    }

    // MARK: - Unit accessors

    func unitSymbol(at index: Int) -> String {
        if category.isCurrency {
            guard index < currencyCodes.count else { return "" }
            return currencyCodes[index]
        } else if category.isCustom {
            let units = category.customUnits
            guard index < units.count else { return "" }
            return units[index].symbol
        } else {
            let dims = category.dimensions
            guard index < dims.count else { return "" }
            return dims[index].symbol
        }
    }

    func unitName(at index: Int) -> String {
        unitSymbol(at: index)
    }

    // MARK: - Actions

    func swap() {
        let temp = sourceIndex
        sourceIndex = destinationIndex
        destinationIndex = temp
    }

    func reset() {
        crownValue = 0
    }

    func toggleNegative() {
        crownValue = -crownValue
    }

    // MARK: - Conversion

    private func convertCurrency(value: Double) -> String {
        guard hasCurrencyRates,
              sourceIndex < currencyCodes.count,
              destinationIndex < currencyCodes.count else { return "" }
        let fromCode = currencyCodes[sourceIndex]
        let toCode = currencyCodes[destinationIndex]
        guard let fromRate = currencyRates[fromCode],
              let toRate = currencyRates[toCode],
              fromRate > 0 else { return "" }
        return formatResult(value * (toRate / fromRate))
    }

    private func convertFoundation(value: Double) -> String {
        let dims = category.dimensions
        guard sourceIndex < dims.count, destinationIndex < dims.count else { return "" }
        let measurement = Measurement(value: value, unit: dims[sourceIndex])
        let converted = measurement.converted(to: dims[destinationIndex])
        return formatResult(converted.value)
    }

    private func convertCustom(value: Double) -> String {
        let units = category.customUnits
        guard sourceIndex < units.count, destinationIndex < units.count else { return "" }
        let baseValue = value * units[sourceIndex].toBaseFactor
        let result = baseValue / units[destinationIndex].toBaseFactor
        return formatResult(result)
    }

    // MARK: - Formatting

    private func formatValue(_ value: Double) -> String {
        if value == 0 { return "0" }
        if value == Double(Int(value)) {
            return String(Int(value))
        }
        return String(format: "%g", value)
    }

    private func formatResult(_ value: Double) -> String {
        if value == 0 { return "0" }
        if abs(value) >= 1_000_000 || (abs(value) < 0.001 && abs(value) > 0) {
            return String(format: "%g", value)
        }
        let formatted = String(format: "%.6f", value)
        var trimmed = formatted
        while trimmed.hasSuffix("0") { trimmed.removeLast() }
        if trimmed.hasSuffix(".") { trimmed.removeLast() }
        return trimmed
    }
}
