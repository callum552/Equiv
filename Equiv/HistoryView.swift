//
//  HistoryView.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import SwiftUI

struct HistoryView: View {
    var history = HistoryManager.shared

    var body: some View {
        Group {
            if history.entries.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Your recent conversions will appear here.")
                )
            } else {
                List {
                    ForEach(history.entries) { entry in
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
                        Button("Clear", role: .destructive) {
                            history.clear()
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func historyRow(entry: HistoryEntry) -> some View {
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
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
