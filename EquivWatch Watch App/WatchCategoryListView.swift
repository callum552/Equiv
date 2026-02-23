//
//  WatchCategoryListView.swift
//  EquivWatch Watch App
//
//  Created by Callum Black on 31/01/2026.
//

import SwiftUI

struct WatchCategoryListView: View {
    private let categories = UnitCategoryType.allCases

    @AppStorage("watch_recent_categories") private var recentRaw: String = ""

    private var recentCategories: [UnitCategoryType] {
        recentRaw
            .split(separator: ",")
            .compactMap { UnitCategoryType(rawValue: String($0)) }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            List {
                if !recentCategories.isEmpty {
                    Section(String(localized: "Recent")) {
                        ForEach(recentCategories) { category in
                            NavigationLink(value: category) {
                                Label(category.displayName, systemImage: category.icon)
                            }
                        }
                    }
                }

                Section(String(localized: "All")) {
                    ForEach(categories) { category in
                        NavigationLink(value: category) {
                            Label(category.displayName, systemImage: category.icon)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "Equiv"))
            .navigationDestination(for: UnitCategoryType.self) { category in
                WatchConverterView(category: category)
                    .onAppear { recordRecent(category) }
            }
        }
    }

    private func recordRecent(_ category: UnitCategoryType) {
        var recents = recentRaw
            .split(separator: ",")
            .map { String($0) }
            .filter { $0 != category.rawValue }
        recents.insert(category.rawValue, at: 0)
        recentRaw = recents.prefix(3).joined(separator: ",")
    }
}
