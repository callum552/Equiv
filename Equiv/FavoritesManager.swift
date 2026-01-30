//
//  FavoritesManager.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import Foundation

@Observable
class FavoritesManager {
    static let shared = FavoritesManager()

    private let key = "equiv_favorites"

    var favoriteIDs: Set<String> {
        didSet { save() }
    }

    private init() {
        let stored = UserDefaults.standard.stringArray(forKey: key) ?? []
        self.favoriteIDs = Set(stored)
    }

    func isFavorite(_ category: UnitCategoryType) -> Bool {
        favoriteIDs.contains(category.rawValue)
    }

    func toggle(_ category: UnitCategoryType) {
        if favoriteIDs.contains(category.rawValue) {
            favoriteIDs.remove(category.rawValue)
        } else {
            favoriteIDs.insert(category.rawValue)
        }
    }

    var favorites: [UnitCategoryType] {
        UnitCategoryType.allCases.filter { favoriteIDs.contains($0.rawValue) }
    }

    private func save() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: key)
    }
}
