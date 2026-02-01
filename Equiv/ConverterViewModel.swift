//
//  ConverterViewModel.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import Foundation

struct MultiConvertResult: Identifiable {
    let id = UUID()
    let unitName: String
    let symbol: String
    let value: String
}

@Observable
class ConverterViewModel {
    let category: UnitCategoryType

    var inputValue: String = ""
    var sourceIndex: Int = 0
    var destinationIndex: Int = 1
    var useScientificNotation: Bool = false

    // Currency support
    var currencyService: CurrencyService?

    var unitCount: Int {
        if category.isCurrency {
            return currencyService?.currencies.count ?? 0
        }
        return category.isCustom ? category.customUnits.count : category.dimensions.count
    }

    var result: String {
        guard let value = Double(inputValue) else { return "" }
        if category.isCurrency {
            return convertCurrency(value: value)
        } else if category.isCustom {
            return convertCustom(value: value)
        } else {
            return convertFoundation(value: value)
        }
    }

    var sourceUnitSymbol: String {
        unitSymbol(at: sourceIndex)
    }

    var destinationUnitSymbol: String {
        unitSymbol(at: destinationIndex)
    }

    var shareText: String {
        guard !inputValue.isEmpty, !result.isEmpty else { return "" }
        return "\(inputValue) \(sourceUnitSymbol) = \(result) \(destinationUnitSymbol) — Equiv"
    }

    var allResults: [MultiConvertResult] {
        guard let value = Double(inputValue) else { return [] }

        var results: [MultiConvertResult] = []

        if category.isCurrency {
            guard let service = currencyService else { return [] }
            let currencies = service.currencies
            guard sourceIndex < currencies.count else { return [] }

            for (index, currency) in currencies.enumerated() where index != sourceIndex {
                let converted = service.convert(value: value, fromIndex: sourceIndex, toIndex: index)
                results.append(MultiConvertResult(
                    unitName: currency.name,
                    symbol: currency.symbol,
                    value: formatResult(converted)
                ))
            }
        } else if category.isCustom {
            let units = category.customUnits
            guard sourceIndex < units.count else { return [] }
            let baseValue = value * units[sourceIndex].toBaseFactor

            for (index, unit) in units.enumerated() where index != sourceIndex {
                let converted = baseValue / unit.toBaseFactor
                results.append(MultiConvertResult(
                    unitName: unit.name,
                    symbol: unit.symbol,
                    value: formatResult(converted)
                ))
            }
        } else {
            let dims = category.dimensions
            guard sourceIndex < dims.count else { return [] }
            let source = dims[sourceIndex]
            let measurement = Measurement(value: value, unit: source)

            for (index, dim) in dims.enumerated() where index != sourceIndex {
                let converted = measurement.converted(to: dim)
                results.append(MultiConvertResult(
                    unitName: dim.displayName,
                    symbol: dim.symbol,
                    value: formatResult(converted.value)
                ))
            }
        }

        return results
    }

    init(category: UnitCategoryType) {
        self.category = category
    }

    func toggleNegative() {
        if inputValue.hasPrefix("-") {
            inputValue.removeFirst()
        } else if !inputValue.isEmpty {
            inputValue = "-" + inputValue
        } else {
            inputValue = "-"
        }
    }

    func swap() {
        let temp = sourceIndex
        sourceIndex = destinationIndex
        destinationIndex = temp
    }

    func unitName(at index: Int) -> String {
        if category.isCurrency {
            guard let currencies = currencyService?.currencies,
                  index < currencies.count else { return "" }
            return "\(currencies[index].name) (\(currencies[index].symbol))"
        } else if category.isCustom {
            let units = category.customUnits
            guard index < units.count else { return "" }
            return "\(units[index].name) (\(units[index].symbol))"
        } else {
            let dims = category.dimensions
            guard index < dims.count else { return "" }
            return "\(dims[index].displayName) (\(dims[index].symbol))"
        }
    }

    func unitSymbol(at index: Int) -> String {
        if category.isCurrency {
            guard let currencies = currencyService?.currencies,
                  index < currencies.count else { return "" }
            return currencies[index].symbol
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

    // MARK: - Foundation conversion

    private func convertFoundation(value: Double) -> String {
        let dims = category.dimensions
        guard sourceIndex < dims.count, destinationIndex < dims.count else { return "" }

        let source = dims[sourceIndex]
        let destination = dims[destinationIndex]

        let measurement = Measurement(value: value, unit: source)
        let converted = measurement.converted(to: destination)

        return formatResult(converted.value)
    }

    // MARK: - Custom factor-based conversion

    private func convertCustom(value: Double) -> String {
        let units = category.customUnits
        guard sourceIndex < units.count, destinationIndex < units.count else { return "" }

        let baseValue = value * units[sourceIndex].toBaseFactor
        let result = baseValue / units[destinationIndex].toBaseFactor

        return formatResult(result)
    }

    // MARK: - Currency conversion

    private func convertCurrency(value: Double) -> String {
        guard let service = currencyService else { return "" }
        let converted = service.convert(value: value, fromIndex: sourceIndex, toIndex: destinationIndex)
        return formatResult(converted)
    }

    // MARK: - Formatting

    func formatResult(_ value: Double) -> String {
        if value == 0 { return "0" }

        if useScientificNotation {
            return String(format: "%e", value)
        }

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
