//
//  CategoryPickerIntent.swift
//  EquivWidget
//
//  Widget configuration intent for choosing which category to quick-open.
//

import AppIntents
import WidgetKit

// MARK: - Category AppEnum (widget target copy of UnitCategoryType display names)

enum WidgetCategory: String, AppEnum, CaseIterable {
    case length, mass, temperature, volume, area, speed, time,
         digitalStorage, energy, pressure, angle, frequency,
         fuelEconomy, power, force, dataTransferRate,
         torque, density, illuminance, currency,
         bloodSugar, typography, flowRate

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Category" }

    static var caseDisplayRepresentations: [WidgetCategory: DisplayRepresentation] {
        [
            .length:          "Length",
            .mass:            "Weight / Mass",
            .temperature:     "Temperature",
            .volume:          "Volume",
            .area:            "Area",
            .speed:           "Speed",
            .time:            "Time",
            .digitalStorage:  "Digital Storage",
            .energy:          "Energy",
            .pressure:        "Pressure",
            .angle:           "Angle",
            .frequency:       "Frequency",
            .fuelEconomy:     "Fuel Economy",
            .power:           "Power",
            .force:           "Force",
            .dataTransferRate:"Data Transfer Rate",
            .torque:          "Torque",
            .density:         "Density",
            .illuminance:     "Illuminance",
            .currency:        "Currency",
            .bloodSugar:      "Blood Sugar",
            .typography:      "Typography",
            .flowRate:        "Flow Rate",
        ]
    }
}

// MARK: - Configuration Intent

struct CategoryPickerIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Equiv"
    static var description: IntentDescription = "Choose a category to quick-open from the widget."

    @Parameter(title: "Quick-Open Category", default: .length)
    var category: WidgetCategory
}
