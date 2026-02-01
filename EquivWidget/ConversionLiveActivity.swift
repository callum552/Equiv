//
//  ConversionLiveActivity.swift
//  EquivWidget
//
//  Created by Callum Black on 31/01/2026.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct ConversionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ConversionActivityAttributes.self) { context in
            // Lock Screen view
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.categoryName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(context.state.inputValue)
                            .font(.title2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                        Text(context.state.sourceUnitSymbol)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Image(systemName: "equal")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Result"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(context.state.resultValue)
                            .font(.title2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundStyle(.blue)
                        Text(context.state.destinationUnitSymbol)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding()

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(context.state.inputValue)
                            .font(.title3)
                            .fontWeight(.bold)
                            .monospacedDigit()
                        Text(context.state.sourceUnitSymbol)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text(context.state.resultValue)
                            .font(.title3)
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundStyle(.blue)
                        Text(context.state.destinationUnitSymbol)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.categoryName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Text(context.state.inputValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
            } compactTrailing: {
                Text(context.state.resultValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(.blue)
            } minimal: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.caption)
            }
        }
    }
}
