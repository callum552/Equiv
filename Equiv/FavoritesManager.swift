//
//  FavoritesManager.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "name.callumblack.Equiv", category: "FavoritesManager")

@Observable
class FavoritesManager {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func isFavorite(_ category: UnitCategoryType) -> Bool {
        let rawValue = category.rawValue
        let descriptor = FetchDescriptor<FavoriteCategory>(
            predicate: #Predicate { $0.categoryRawValue == rawValue }
        )
        do {
            return try modelContext.fetchCount(descriptor) > 0
        } catch {
            logger.error("Failed to check favorite status for \(rawValue): \(error.localizedDescription)")
            return false
        }
    }

    func toggle(_ category: UnitCategoryType) {
        let rawValue = category.rawValue
        let descriptor = FetchDescriptor<FavoriteCategory>(
            predicate: #Predicate { $0.categoryRawValue == rawValue }
        )
        do {
            if let existing = try modelContext.fetch(descriptor).first {
                modelContext.delete(existing)
                logger.info("Removed favorite: \(rawValue)")
            } else {
                let favorite = FavoriteCategory(categoryRawValue: rawValue)
                modelContext.insert(favorite)
                logger.info("Added favorite: \(rawValue)")
            }
        } catch {
            logger.error("Failed to toggle favorite for \(rawValue): \(error.localizedDescription)")
        }
    }

    var favorites: [UnitCategoryType] {
        let descriptor = FetchDescriptor<FavoriteCategory>(
            sortBy: [SortDescriptor(\.dateAdded)]
        )
        do {
            let stored = try modelContext.fetch(descriptor)
            return stored.compactMap { $0.category }
        } catch {
            logger.error("Failed to fetch favorites: \(error.localizedDescription)")
            return []
        }
    }

    var favoriteIDs: Set<String> {
        let descriptor = FetchDescriptor<FavoriteCategory>()
        do {
            let stored = try modelContext.fetch(descriptor)
            return Set(stored.map(\.categoryRawValue))
        } catch {
            logger.error("Failed to fetch favorite IDs: \(error.localizedDescription)")
            return []
        }
    }
}
