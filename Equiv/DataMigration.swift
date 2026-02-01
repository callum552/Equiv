//
//  DataMigration.swift
//  Equiv
//
//  Created by Callum Black on 31/01/2026.
//

import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "name.callumblack.Equiv", category: "DataMigration")

struct DataMigration {
    private static let migrationKey = "equiv_swiftdata_migration_complete"

    static func migrateIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        logger.info("Starting data migration from UserDefaults to SwiftData")
        migrateFavorites(context: context)
        migrateHistory(context: context)

        UserDefaults.standard.set(true, forKey: migrationKey)
        logger.info("Data migration completed")
    }

    private static func migrateFavorites(context: ModelContext) {
        guard let stored = UserDefaults.standard.stringArray(forKey: "equiv_favorites") else { return }
        for rawValue in stored {
            let favorite = FavoriteCategory(categoryRawValue: rawValue)
            context.insert(favorite)
        }
        logger.info("Migrated \(stored.count) favorites")
        UserDefaults.standard.removeObject(forKey: "equiv_favorites")
    }

    private static func migrateHistory(context: ModelContext) {
        guard let data = UserDefaults.standard.data(forKey: "equiv_history") else { return }
        do {
            let entries = try JSONDecoder().decode([LegacyHistoryEntry].self, from: data)
            for entry in entries {
                let newEntry = ConversionHistoryEntry(
                    categoryRawValue: entry.categoryRawValue,
                    sourceUnitName: entry.sourceUnitName,
                    destinationUnitName: entry.destinationUnitName,
                    inputValue: entry.inputValue,
                    resultValue: entry.resultValue,
                    timestamp: entry.timestamp
                )
                context.insert(newEntry)
            }
            logger.info("Migrated \(entries.count) history entries")
        } catch {
            logger.error("Failed to decode legacy history: \(error.localizedDescription)")
        }
        UserDefaults.standard.removeObject(forKey: "equiv_history")
    }
}

// Matches the old HistoryEntry Codable struct for migration
private struct LegacyHistoryEntry: Codable {
    var id: UUID = UUID()
    let categoryRawValue: String
    let sourceUnitName: String
    let destinationUnitName: String
    let inputValue: String
    let resultValue: String
    let timestamp: Date
}
