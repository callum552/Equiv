//
//  SpotlightIndexer.swift
//  Equiv
//
//  Created by Callum Black on 31/01/2026.
//

import CoreSpotlight

struct SpotlightIndexer {
    static let categoryDomain = "name.callumblack.Equiv.categories"
    static let historyDomain = "name.callumblack.Equiv.history"

    static func indexAllCategories() {
        let items = UnitCategoryType.allCases.map { category in
            let attributes = CSSearchableItemAttributeSet(contentType: .item)
            attributes.title = category.displayName
            attributes.contentDescription = spotlightDescription(for: category)

            return CSSearchableItem(
                uniqueIdentifier: "category-\(category.rawValue)",
                domainIdentifier: categoryDomain,
                attributeSet: attributes
            )
        }

        CSSearchableIndex.default().indexSearchableItems(items)
    }

    static func indexHistoryEntry(id: String, categoryName: String, input: String,
                                   sourceUnit: String, result: String, destUnit: String) {
        let attributes = CSSearchableItemAttributeSet(contentType: .item)
        attributes.title = "\(input) \(sourceUnit) \u{2192} \(result) \(destUnit)"
        attributes.contentDescription = categoryName

        let item = CSSearchableItem(
            uniqueIdentifier: "history-\(id)",
            domainIdentifier: historyDomain,
            attributeSet: attributes
        )

        CSSearchableIndex.default().indexSearchableItems([item])
    }

    static func removeHistoryEntry(id: String) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["history-\(id)"])
    }

    static func removeAllHistory() {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [historyDomain])
    }

    private static func spotlightDescription(for category: UnitCategoryType) -> String {
        let unitNames: String
        if category.isCurrency {
            unitNames = "USD, EUR, GBP, JPY, and more"
        } else if category.isCustom {
            unitNames = category.customUnits.prefix(4).map(\.name).joined(separator: ", ")
        } else {
            unitNames = category.dimensions.prefix(4).map(\.displayName).joined(separator: ", ")
        }
        return String(localized: "Convert \(category.displayName) units: \(unitNames)")
    }
}
