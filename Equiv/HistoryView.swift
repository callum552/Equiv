//
//  HistoryView.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import SwiftUI
import SwiftData
import OSLog

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ConversionHistoryEntry.timestamp, order: .reverse)
    private var entries: [ConversionHistoryEntry]

    private let logger = Logger(subsystem: "name.callumblack.Equiv", category: "HistoryView")

    var body: some View {
        Group {
            if entries.isEmpty {
                ContentUnavailableView(
                    String(localized: "No History"),
                    systemImage: "clock.arrow.circlepath",
                    description: Text(String(localized: "Your recent conversions will appear here."))
                )
                .onAppear {
                    logger.warning("HistoryView: entries is empty. Checking manually...")
                    let descriptor = FetchDescriptor<ConversionHistoryEntry>()
                    if let count = try? modelContext.fetchCount(descriptor) {
                        logger.warning("HistoryView: manual fetchCount = \(count)")
                    }
                }
            } else {
                List {
                    ForEach(entries) { entry in
                        if let category = entry.category {
                            NavigationLink(value: category) {
                                historyRow(entry: entry)
                            }
                        } else {
                            historyRow(entry: entry)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(String(localized: "Clear"), role: .destructive) {
                            clearHistory()
                        }
                    }
                }
            }
        }
        .navigationTitle(String(localized: "History"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func clearHistory() {
        for entry in entries {
            modelContext.delete(entry)
        }
    }

    private func historyRow(entry: ConversionHistoryEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.category?.displayName ?? entry.categoryRawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text("\(entry.inputValue) \(entry.sourceUnitName)")
                    .fontWeight(.medium)
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(entry.resultValue) \(entry.destinationUnitName)")
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            Text(entry.timestamp, style: .relative)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.category?.displayName ?? entry.categoryRawValue): \(entry.inputValue) \(entry.sourceUnitName) to \(entry.resultValue) \(entry.destinationUnitName)")
        .accessibilityIdentifier("history_entry")
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(for: [FavoriteCategory.self, ConversionHistoryEntry.self], inMemory: true)
}
