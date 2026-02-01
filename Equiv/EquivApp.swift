//
//  EquivApp.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import SwiftUI
import SwiftData
import CoreSpotlight
import OSLog

private let logger = Logger(subsystem: "name.callumblack.Equiv", category: "EquivApp")

@main
struct EquivApp: App {
    let modelContainer: ModelContainer
    @State private var deepLinkCategory: UnitCategoryType?

    init() {
        let schema = Schema([
            FavoriteCategory.self,
            ConversionHistoryEntry.self,
            CachedExchangeRates.self
        ])

        // Use local storage to ensure data persists reliably.
        // CloudKit sync can be re-enabled once tested on a device with iCloud.
        do {
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            modelContainer = try ModelContainer(for: schema, configurations: [config])
            logger.info("ModelContainer created (local storage)")
        } catch {
            logger.fault("Failed to create ModelContainer: \(error.localizedDescription)")
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            CategoryListView(deepLinkCategory: $deepLinkCategory)
                .onAppear {
                    DataMigration.migrateIfNeeded(context: modelContainer.mainContext)
                    SpotlightIndexer.indexAllCategories()
                }
                .onOpenURL { url in
                    // Handle widget deep links: equiv://category/length
                    guard url.scheme == "equiv",
                          url.host == "category",
                          let rawValue = url.pathComponents.dropFirst().first,
                          let category = UnitCategoryType(rawValue: rawValue) else { return }
                    deepLinkCategory = category
                }
                .onContinueUserActivity(CSSearchableItemActionType) { activity in
                    guard let identifier = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return }
                    if identifier.hasPrefix("category-") {
                        let rawValue = String(identifier.dropFirst("category-".count))
                        if let category = UnitCategoryType(rawValue: rawValue) {
                            deepLinkCategory = category
                        }
                    }
                }
        }
        .modelContainer(modelContainer)

        WindowGroup(id: "equiv-converter") {
            CategoryListView()
        }
        .modelContainer(modelContainer)
    }
}
