//
//  EquivWidget.swift
//  EquivWidget
//
//  Created by Callum Black on 31/01/2026.
//

import WidgetKit
import SwiftUI

struct ConversionEntry: TimelineEntry {
    let date: Date
    let conversion: SharedConversion?
}

struct EquivWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ConversionEntry {
        ConversionEntry(date: .now, conversion: SharedConversion(
            categoryRawValue: "length",
            sourceUnitSymbol: "mi",
            destinationUnitSymbol: "km",
            inputValue: "1",
            resultValue: "1.60934",
            categoryDisplayName: "Length",
            timestamp: .now
        ))
    }

    func getSnapshot(in context: Context, completion: @escaping (ConversionEntry) -> Void) {
        let entry = ConversionEntry(date: .now, conversion: SharedConversion.load())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ConversionEntry>) -> Void) {
        let entry = ConversionEntry(date: .now, conversion: SharedConversion.load())
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600)))
        completion(timeline)
    }
}

struct EquivWidgetEntryView: View {
    var entry: ConversionEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let conversion = entry.conversion {
            switch family {
            case .systemSmall:
                smallWidget(conversion)
            default:
                mediumWidget(conversion)
            }
        } else {
            emptyWidget
        }
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

    private var emptyWidget: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.title)
                .foregroundStyle(.secondary)
            Text("Equiv")
                .font(.headline)
            Text(String(localized: "Convert a unit to see it here"))
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
        StaticConfiguration(kind: kind, provider: EquivWidgetProvider()) { entry in
            EquivWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Equiv")
        .description(String(localized: "Shows your latest conversion"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    EquivWidget()
} timeline: {
    ConversionEntry(date: .now, conversion: SharedConversion(
        categoryRawValue: "length",
        sourceUnitSymbol: "mi",
        destinationUnitSymbol: "km",
        inputValue: "5",
        resultValue: "8.04672",
        categoryDisplayName: "Length",
        timestamp: .now
    ))
}
