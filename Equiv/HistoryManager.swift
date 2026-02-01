//
//  HistoryManager.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "name.callumblack.Equiv", category: "HistoryManager")

@Observable
class HistoryManager {
    private var modelContext: ModelContext
    private let maxEntries = 50

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var entries: [ConversionHistoryEntry] {
        var descriptor = FetchDescriptor<ConversionHistoryEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = maxEntries
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch history entries: \(error.localizedDescription)")
            return []
        }
    }

    func add(categoryRawValue: String, sourceUnitName: String,
             destinationUnitName: String, inputValue: String, resultValue: String) {
        let entry = ConversionHistoryEntry(
            categoryRawValue: categoryRawValue,
            sourceUnitName: sourceUnitName,
            destinationUnitName: destinationUnitName,
            inputValue: inputValue,
            resultValue: resultValue
        )
        modelContext.insert(entry)
        logger.info("Inserted history entry: \(inputValue) \(sourceUnitName) → \(resultValue) \(destinationUnitName)")
    }

    func clear() {
        do {
            let descriptor = FetchDescriptor<ConversionHistoryEntry>()
            let all = try modelContext.fetch(descriptor)
            for entry in all {
                modelContext.delete(entry)
            }
            logger.info("History cleared (\(all.count) entries removed)")
        } catch {
            logger.error("Failed to clear history: \(error.localizedDescription)")
        }
    }

    private func trimOldEntries() {
        var descriptor = FetchDescriptor<ConversionHistoryEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchOffset = maxEntries
        do {
            let excess = try modelContext.fetch(descriptor)
            for entry in excess {
                modelContext.delete(entry)
            }
        } catch {
            logger.error("Failed to trim old history entries: \(error.localizedDescription)")
        }
    }
}
