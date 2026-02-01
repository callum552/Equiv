//
//  ConvertUnitIntent.swift
//  Equiv
//
//  Created by Callum Black on 31/01/2026.
//

import AppIntents

struct ConvertUnitIntent: AppIntent {
    static var title: LocalizedStringResource = "Convert Units"
    static var description: IntentDescription = IntentDescription("Convert a value from one unit to another")

    @Parameter(title: "Value")
    var value: Double

    @Parameter(title: "Source Unit")
    var sourceUnit: String

    @Parameter(title: "Destination Unit")
    var destinationUnit: String

    static var parameterSummary: some ParameterSummary {
        Summary("Convert \(\.$value) \(\.$sourceUnit) to \(\.$destinationUnit)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard let source = UnitResolver.resolve(sourceUnit) else {
            return .result(
                value: "",
                dialog: "I couldn't recognize the unit '\(sourceUnit)'. Try using a common unit name like 'miles', 'kg', or 'celsius'."
            )
        }

        guard let destination = UnitResolver.resolve(destinationUnit) else {
            return .result(
                value: "",
                dialog: "I couldn't recognize the unit '\(destinationUnit)'. Try using a common unit name like 'kilometers', 'pounds', or 'fahrenheit'."
            )
        }

        guard source.category == destination.category else {
            return .result(
                value: "",
                dialog: "Cannot convert between \(source.category.displayName) and \(destination.category.displayName). Both units must be in the same category."
            )
        }

        let vm = ConverterViewModel(category: source.category)
        vm.sourceIndex = source.index
        vm.destinationIndex = destination.index
        vm.inputValue = String(value)

        let result = vm.result
        guard !result.isEmpty else {
            return .result(value: "", dialog: "Unable to perform the conversion.")
        }

        let resultText = "\(vm.inputValue) \(source.symbol) = \(result) \(destination.symbol)"
        return .result(value: resultText, dialog: "\(resultText)")
    }
}
