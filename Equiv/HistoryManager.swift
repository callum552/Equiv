//
//  HistoryManager.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import Foundation

struct HistoryEntry: Codable, Identifiable {
    var id = UUID()
    let categoryRawValue: String
    let sourceUnitName: String
    let destinationUnitName: String
    let inputValue: String
    let resultValue: String
    let timestamp: Date

    var category: UnitCategoryType? {
        UnitCategoryType(rawValue: categoryRawValue)
    }
}

@Observable
class HistoryManager {
    static let shared = HistoryManager()

    private let key = "equiv_history"
    private let maxEntries = 20

    var entries: [HistoryEntry] {
        didSet { save() }
    }

    private init() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) else {
            self.entries = []
            return
        }
        self.entries = decoded
    }

    func add(_ entry: HistoryEntry) {
        entries.insert(entry, at: 0)
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
    }

    func clear() {
        entries.removeAll()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
