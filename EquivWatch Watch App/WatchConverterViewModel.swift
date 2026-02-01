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

    var crownStep: Double {
        steps[stepIndex].value
    }

    var unitCount: Int {
        category.isCustom ? category.customUnits.count : category.dimensions.count
    }

    var formattedInput: String {
        if crownValue == Double(Int(crownValue)) {
            return String(Int(crownValue))
        }
        return String(format: "%g", crownValue)
    }

    var result: String {
        guard crownValue != 0 else { return "" }
        if category.isCustom {
            return convertCustom(value: crownValue)
        } else {
            return convertFoundation(value: crownValue)
        }
    }

    init(category: UnitCategoryType) {
        self.category = category
    }

    func swap() {
        let temp = sourceIndex
        sourceIndex = destinationIndex
        destinationIndex = temp
    }

    func unitSymbol(at index: Int) -> String {
        if category.isCustom {
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

    // MARK: - Conversion

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
