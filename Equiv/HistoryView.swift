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

    private var starredEntries: [ConversionHistoryEntry] {
        entries.filter { $0.isFavorited }
    }

    private var unstarredEntries: [ConversionHistoryEntry] {
        entries.filter { !$0.isFavorited }
    }

    var body: some View {
        Group {
            if entries.isEmpty {
                ContentUnavailableView(
                    String(localized: "No History"),
                    systemImage: "clock.arrow.circlepath",
                    description: Text(String(localized: "Your recent conversions will appear here."))
                )
            } else {
                List {
                    if !starredEntries.isEmpty {
                        Section(String(localized: "Starred")) {
                            ForEach(starredEntries) { entry in
                                historyRow(entry: entry)
                            }
                        }
                    }

                    Section(starredEntries.isEmpty ? String(localized: "History") : String(localized: "Recent")) {
                        ForEach(unstarredEntries) { entry in
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
        Group {
            if let category = entry.category {
                NavigationLink(value: category) {
                    rowContent(entry: entry)
                }
            } else {
                rowContent(entry: entry)
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                entry.isFavorited.toggle()
            } label: {
                Label(
                    entry.isFavorited ? String(localized: "Unstar") : String(localized: "Star"),
                    systemImage: entry.isFavorited ? "star.slash" : "star.fill"
                )
            }
            .tint(.yellow)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(entry)
            } label: {
                Label(String(localized: "Delete"), systemImage: "trash")
            }
        }
    }

    private func rowContent(entry: ConversionHistoryEntry) -> some View {
        HStack {
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
            Spacer()
            if entry.isFavorited {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
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
