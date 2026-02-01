//
//  WatchCategoryListView.swift
//  EquivWatch Watch App
//
//  Created by Callum Black on 31/01/2026.
//

import SwiftUI

struct WatchCategoryListView: View {
    private let categories = UnitCategoryType.allCases.filter { !$0.isCurrency }

    var body: some View {
        NavigationStack {
            List(categories) { category in
                NavigationLink(value: category) {
                    Label(category.displayName, systemImage: category.icon)
                }
            }
            .navigationTitle(String(localized: "Equiv"))
            .navigationDestination(for: UnitCategoryType.self) { category in
                WatchConverterView(category: category)
            }
        }
    }
}
