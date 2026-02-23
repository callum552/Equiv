//
//  EquivWidget.swift
//  EquivWidget
//
//  Created by Callum Black on 31/01/2026.
//

import WidgetKit
import SwiftUI
import AppIntents

struct ConversionEntry: TimelineEntry {
    let date: Date
    let conversion: SharedConversion?
    let targetCategory: WidgetCategory
}

struct EquivWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = ConversionEntry
    typealias Intent = CategoryPickerIntent

    func placeholder(in context: Context) -> ConversionEntry {
        ConversionEntry(
            date: .now,
            conversion: SharedConversion(
                categoryRawValue: "length",
                sourceUnitSymbol: "mi",
                destinationUnitSymbol: "km",
                inputValue: "1",
                resultValue: "1.60934",
                categoryDisplayName: "Length",
                timestamp: .now
            ),
            targetCategory: .length
        )
    }

    func snapshot(for configuration: CategoryPickerIntent, in context: Context) async -> ConversionEntry {
        let stored = SharedConversion.load()
        let matchingConversion = stored?.categoryRawValue == configuration.category.rawValue ? stored : nil
        return ConversionEntry(date: .now, conversion: matchingConversion, targetCategory: configuration.category)
    }

    func timeline(for configuration: CategoryPickerIntent, in context: Context) async -> Timeline<ConversionEntry> {
        let stored = SharedConversion.load()
        let matchingConversion = stored?.categoryRawValue == configuration.category.rawValue ? stored : nil
        let entry = ConversionEntry(date: .now, conversion: matchingConversion, targetCategory: configuration.category)
        return Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600)))
    }

    func recommendations() -> [AppIntentRecommendation<CategoryPickerIntent>] {
        [.length, .mass, .temperature, .volume, .speed, .currency].map { category in
            var intent = CategoryPickerIntent()
            intent.category = category
            return AppIntentRecommendation(intent: intent, description: category.displayName)
        }
    }
}

extension WidgetCategory {
    var displayName: String {
        switch self {
        case .length:          return "Length"
        case .mass:            return "Weight / Mass"
        case .temperature:     return "Temperature"
        case .volume:          return "Volume"
        case .area:            return "Area"
        case .speed:           return "Speed"
        case .time:            return "Time"
        case .digitalStorage:  return "Digital Storage"
        case .energy:          return "Energy"
        case .pressure:        return "Pressure"
        case .angle:           return "Angle"
        case .frequency:       return "Frequency"
        case .fuelEconomy:     return "Fuel Economy"
        case .power:           return "Power"
        case .force:           return "Force"
        case .dataTransferRate: return "Data Transfer Rate"
        case .torque:          return "Torque"
        case .density:         return "Density"
        case .illuminance:     return "Illuminance"
        case .currency:        return "Currency"
        case .bloodSugar:      return "Blood Sugar"
        case .typography:      return "Typography"
        case .flowRate:        return "Flow Rate"
        }
    }
}

struct EquivWidgetEntryView: View {
    var entry: ConversionEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if let conversion = entry.conversion {
                switch family {
                case .systemSmall:
                    smallWidget(conversion)
                default:
                    mediumWidget(conversion)
                }
            } else {
                emptyWidget(for: entry.targetCategory)
            }
        }
        .widgetURL(URL(string: "equiv://category/\(entry.targetCategory.rawValue)"))
    }

    private func smallWidget(_ conversion: SharedConversion) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(conversion.categoryDisplayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(conversion.inputValue)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()

            Text(conversion.sourceUnitSymbol)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Text(conversion.resultValue)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(.blue)

            Text(conversion.destinationUnitSymbol)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private func mediumWidget(_ conversion: SharedConversion) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(conversion.categoryDisplayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(conversion.inputValue)
                        .font(.title)
                        .fontWeight(.bold)
                        .monospacedDigit()
                    Text(conversion.sourceUnitSymbol)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Image(systemName: "arrow.right")
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Result"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(conversion.resultValue)
                        .font(.title)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(.blue)
                    Text(conversion.destinationUnitSymbol)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    private func emptyWidget(for category: WidgetCategory) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.title)
                .foregroundStyle(.secondary)
            Text(category.displayName)
                .font(.headline)
            Text(String(localized: "Tap to open"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct EquivWidget: Widget {
    let kind: String = "EquivWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: CategoryPickerIntent.self, provider: EquivWidgetProvider()) { entry in
            EquivWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Equiv")
        .description(String(localized: "Shows your latest conversion. Tap to open a category."))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    EquivWidget()
} timeline: {
    ConversionEntry(
        date: .now,
        conversion: SharedConversion(
            categoryRawValue: "length",
            sourceUnitSymbol: "mi",
            destinationUnitSymbol: "km",
            inputValue: "5",
            resultValue: "8.04672",
            categoryDisplayName: "Length",
            timestamp: .now
        ),
        targetCategory: .length
    )
}
