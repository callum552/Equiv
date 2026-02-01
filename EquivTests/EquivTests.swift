//
//  EquivTests.swift
//  EquivTests
//
//  Created by Callum Black on 30/01/2026.
//

import Testing
@testable import Equiv

// MARK: - ConverterViewModel Tests

struct ConverterViewModelTests {

    // MARK: - Length Conversions

    @Test func metersToKilometers() {
        let vm = ConverterViewModel(category: .length)
        vm.sourceIndex = 0 // meters
        vm.destinationIndex = 1 // kilometers
        vm.inputValue = "1000"
        #expect(vm.result == "1")
    }

    @Test func milesToFeet() {
        let vm = ConverterViewModel(category: .length)
        vm.sourceIndex = 4 // miles
        vm.destinationIndex = 6 // feet
        vm.inputValue = "1"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 5280) < 1)
    }

    @Test func inchesToCentimeters() {
        let vm = ConverterViewModel(category: .length)
        vm.sourceIndex = 7 // inches
        vm.destinationIndex = 2 // centimeters
        vm.inputValue = "1"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 2.54) < 0.01)
    }

    // MARK: - Mass Conversions

    @Test func kilogramsToPounds() {
        let vm = ConverterViewModel(category: .mass)
        vm.sourceIndex = 0 // kilograms
        vm.destinationIndex = 3 // pounds
        vm.inputValue = "1"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 2.20462) < 0.01)
    }

    @Test func ouncesToGrams() {
        let vm = ConverterViewModel(category: .mass)
        vm.sourceIndex = 4 // ounces
        vm.destinationIndex = 1 // grams
        vm.inputValue = "1"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 28.3495) < 0.1)
    }

    // MARK: - Temperature Conversions

    @Test func celsiusToFahrenheit() {
        let vm = ConverterViewModel(category: .temperature)
        vm.sourceIndex = 0 // celsius
        vm.destinationIndex = 1 // fahrenheit
        vm.inputValue = "100"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 212) < 0.1)
    }

    @Test func fahrenheitToCelsius() {
        let vm = ConverterViewModel(category: .temperature)
        vm.sourceIndex = 1 // fahrenheit
        vm.destinationIndex = 0 // celsius
        vm.inputValue = "32"
        #expect(vm.result == "0")
    }

    @Test func celsiusToKelvin() {
        let vm = ConverterViewModel(category: .temperature)
        vm.sourceIndex = 0 // celsius
        vm.destinationIndex = 2 // kelvin
        vm.inputValue = "0"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 273.15) < 0.01)
    }

    // MARK: - Volume Conversions

    @Test func litersToGallons() {
        let vm = ConverterViewModel(category: .volume)
        vm.sourceIndex = 0 // liters
        vm.destinationIndex = 2 // gallons
        vm.inputValue = "1"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 0.264172) < 0.01)
    }

    // MARK: - Speed Conversions

    @Test func kphToMph() {
        let vm = ConverterViewModel(category: .speed)
        vm.sourceIndex = 1 // km/h
        vm.destinationIndex = 2 // mph
        vm.inputValue = "100"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 62.1371) < 0.1)
    }

    // MARK: - Time Conversions

    @Test func hoursToMinutes() {
        let vm = ConverterViewModel(category: .time)
        vm.sourceIndex = 2 // hours
        vm.destinationIndex = 1 // minutes
        vm.inputValue = "1"
        #expect(vm.result == "60")
    }

    @Test func minutesToSeconds() {
        let vm = ConverterViewModel(category: .time)
        vm.sourceIndex = 1 // minutes
        vm.destinationIndex = 0 // seconds
        vm.inputValue = "1"
        #expect(vm.result == "60")
    }

    // MARK: - Area Conversions

    @Test func acresToHectares() {
        let vm = ConverterViewModel(category: .area)
        vm.sourceIndex = 5 // acres
        vm.destinationIndex = 6 // hectares
        vm.inputValue = "1"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 0.404686) < 0.001)
    }

    // MARK: - Digital Storage Conversions

    @Test func gigabytesToMegabytes() {
        let vm = ConverterViewModel(category: .digitalStorage)
        vm.sourceIndex = 3 // gigabytes
        vm.destinationIndex = 2 // megabytes
        vm.inputValue = "1"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 1000) < 1)
    }

    // MARK: - Energy Conversions

    @Test func kilocaloriesToJoules() {
        let vm = ConverterViewModel(category: .energy)
        vm.sourceIndex = 3 // kilocalories
        vm.destinationIndex = 0 // joules
        vm.inputValue = "1"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 4184) < 1)
    }

    // MARK: - Pressure Conversions

    @Test func barToPsi() {
        let vm = ConverterViewModel(category: .pressure)
        vm.sourceIndex = 3 // bars
        vm.destinationIndex = 5 // psi
        vm.inputValue = "1"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 14.5038) < 0.1)
    }

    // MARK: - Custom Unit Conversions (Force)

    @Test func newtonsToKilonewtons() {
        let vm = ConverterViewModel(category: .force)
        vm.sourceIndex = 0 // Newtons
        vm.destinationIndex = 1 // Kilonewtons
        vm.inputValue = "1000"
        #expect(vm.result == "1")
    }

    @Test func newtonsToPoundForce() {
        let vm = ConverterViewModel(category: .force)
        vm.sourceIndex = 0 // Newtons
        vm.destinationIndex = 2 // lbf
        vm.inputValue = "1"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 0.224809) < 0.001)
    }

    // MARK: - Custom Unit Conversions (Data Transfer Rate)

    @Test func mbpsToKbps() {
        let vm = ConverterViewModel(category: .dataTransferRate)
        vm.sourceIndex = 2 // Mbps
        vm.destinationIndex = 1 // Kbps
        vm.inputValue = "1"
        #expect(vm.result == "1000")
    }

    // MARK: - Custom Unit Conversions (Torque)

    @Test func newtonMetresToFootPounds() {
        let vm = ConverterViewModel(category: .torque)
        vm.sourceIndex = 0 // N·m
        vm.destinationIndex = 1 // ft·lbf
        vm.inputValue = "1"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - 0.737562) < 0.01)
    }

    // MARK: - Swap

    @Test func swapUnits() {
        let vm = ConverterViewModel(category: .length)
        vm.sourceIndex = 0
        vm.destinationIndex = 4
        vm.swap()
        #expect(vm.sourceIndex == 4)
        #expect(vm.destinationIndex == 0)
    }

    // MARK: - Toggle Negative

    @Test func toggleNegativeEmpty() {
        let vm = ConverterViewModel(category: .length)
        vm.inputValue = ""
        vm.toggleNegative()
        #expect(vm.inputValue == "-")
    }

    @Test func toggleNegativePositive() {
        let vm = ConverterViewModel(category: .length)
        vm.inputValue = "5"
        vm.toggleNegative()
        #expect(vm.inputValue == "-5")
    }

    @Test func toggleNegativeAlreadyNegative() {
        let vm = ConverterViewModel(category: .length)
        vm.inputValue = "-5"
        vm.toggleNegative()
        #expect(vm.inputValue == "5")
    }

    // MARK: - Empty / Invalid Input

    @Test func emptyInputReturnsEmptyResult() {
        let vm = ConverterViewModel(category: .length)
        vm.inputValue = ""
        #expect(vm.result == "")
    }

    @Test func invalidInputReturnsEmptyResult() {
        let vm = ConverterViewModel(category: .length)
        vm.inputValue = "abc"
        #expect(vm.result == "")
    }

    // MARK: - Scientific Notation

    @Test func scientificNotation() {
        let vm = ConverterViewModel(category: .length)
        vm.useScientificNotation = true
        vm.sourceIndex = 0 // meters
        vm.destinationIndex = 3 // millimeters
        vm.inputValue = "1000"
        #expect(vm.result.contains("e"))
    }

    // MARK: - Share Text

    @Test func shareTextWithValidInput() {
        let vm = ConverterViewModel(category: .length)
        vm.sourceIndex = 0
        vm.destinationIndex = 1
        vm.inputValue = "1000"
        #expect(vm.shareText.contains("Equiv"))
        #expect(vm.shareText.contains("1000"))
    }

    @Test func shareTextEmptyInput() {
        let vm = ConverterViewModel(category: .length)
        vm.inputValue = ""
        #expect(vm.shareText == "")
    }

    // MARK: - Multi Convert Results

    @Test func allResultsExcludesSourceUnit() {
        let vm = ConverterViewModel(category: .temperature)
        vm.sourceIndex = 0
        vm.inputValue = "100"
        let results = vm.allResults
        #expect(results.count == vm.unitCount - 1)
    }

    // MARK: - Formatting

    @Test func formatZero() {
        let vm = ConverterViewModel(category: .length)
        #expect(vm.formatResult(0) == "0")
    }

    @Test func formatLargeNumber() {
        let vm = ConverterViewModel(category: .length)
        let result = vm.formatResult(1_500_000)
        #expect(result == "1.5e+06")
    }

    @Test func formatSmallDecimal() {
        let vm = ConverterViewModel(category: .length)
        let result = vm.formatResult(0.0005)
        #expect(result == "0.0005")
    }

    @Test func formatTrailingZerosRemoved() {
        let vm = ConverterViewModel(category: .length)
        let result = vm.formatResult(1.5)
        #expect(result == "1.5")
    }

    // MARK: - Unit Name / Symbol

    @Test func unitNameReturnsValidString() {
        let vm = ConverterViewModel(category: .length)
        let name = vm.unitName(at: 0)
        #expect(!name.isEmpty)
    }

    @Test func unitSymbolReturnsValidString() {
        let vm = ConverterViewModel(category: .length)
        let symbol = vm.unitSymbol(at: 0)
        #expect(!symbol.isEmpty)
    }

    @Test func unitNameOutOfBoundsReturnsEmpty() {
        let vm = ConverterViewModel(category: .length)
        let name = vm.unitName(at: 999)
        #expect(name == "")
    }
}

// MARK: - UnitResolver Tests

struct UnitResolverTests {
    @Test func resolveMeters() {
        let resolved = UnitResolver.resolve("meters")
        #expect(resolved != nil)
        #expect(resolved?.category == .length)
        #expect(resolved?.index == 0)
    }

    @Test func resolveMetres() {
        let resolved = UnitResolver.resolve("metres")
        #expect(resolved != nil)
        #expect(resolved?.category == .length)
    }

    @Test func resolveKilogramsAlias() {
        let resolved = UnitResolver.resolve("kg")
        #expect(resolved != nil)
        #expect(resolved?.category == .mass)
        #expect(resolved?.index == 0)
    }

    @Test func resolveFahrenheit() {
        let resolved = UnitResolver.resolve("fahrenheit")
        #expect(resolved != nil)
        #expect(resolved?.category == .temperature)
        #expect(resolved?.index == 1)
    }

    @Test func resolveMph() {
        let resolved = UnitResolver.resolve("mph")
        #expect(resolved != nil)
        #expect(resolved?.category == .speed)
        #expect(resolved?.index == 2)
    }

    @Test func resolveUnknown() {
        let resolved = UnitResolver.resolve("unicorns")
        #expect(resolved == nil)
    }

    @Test func resolveCaseInsensitive() {
        let resolved = UnitResolver.resolve("Kilometers")
        #expect(resolved != nil)
        #expect(resolved?.category == .length)
    }

    @Test func resolveWithWhitespace() {
        let resolved = UnitResolver.resolve("  miles  ")
        #expect(resolved != nil)
        #expect(resolved?.category == .length)
        #expect(resolved?.index == 4)
    }
}

// MARK: - UnitCategory Tests

struct UnitCategoryTests {
    @Test func allCategoriesHaveDisplayName() {
        for category in UnitCategoryType.allCases {
            #expect(!category.displayName.isEmpty)
        }
    }

    @Test func allCategoriesHaveIcon() {
        for category in UnitCategoryType.allCases {
            #expect(!category.icon.isEmpty)
        }
    }

    @Test func currencyIsCurrencyTrue() {
        #expect(UnitCategoryType.currency.isCurrency == true)
    }

    @Test func nonCurrencyIsCurrencyFalse() {
        #expect(UnitCategoryType.length.isCurrency == false)
    }

    @Test func customCategoriesHaveCustomUnits() {
        let customCategories: [UnitCategoryType] = [.force, .dataTransferRate, .torque, .density, .illuminance]
        for category in customCategories {
            #expect(category.isCustom == true)
            #expect(!category.customUnits.isEmpty)
        }
    }

    @Test func standardCategoriesHaveDimensions() {
        let standard: [UnitCategoryType] = [.length, .mass, .temperature, .volume, .speed, .time]
        for category in standard {
            #expect(!category.dimensions.isEmpty)
            #expect(category.isCustom == false)
        }
    }

    @Test func dimensionDisplayNameNotEmpty() {
        let dims = UnitCategoryType.length.dimensions
        for dim in dims {
            #expect(!dim.displayName.isEmpty)
        }
    }
}

// MARK: - Negative Value Conversions

struct NegativeValueTests {
    @Test func negativeTemperature() {
        let vm = ConverterViewModel(category: .temperature)
        vm.sourceIndex = 0 // celsius
        vm.destinationIndex = 1 // fahrenheit
        vm.inputValue = "-40"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - (-40)) < 0.1)
    }

    @Test func negativeLength() {
        let vm = ConverterViewModel(category: .length)
        vm.sourceIndex = 0 // meters
        vm.destinationIndex = 2 // centimeters
        vm.inputValue = "-5"
        let result = Double(vm.result) ?? 0
        #expect(abs(result - (-500)) < 0.1)
    }
}
