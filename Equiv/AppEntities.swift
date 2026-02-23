//
//  AppEntities.swift
//  Equiv
//
//  Opens a specific unit category in the app via deep link.
//

import AppIntents

struct OpenCategoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Category"
    static var description: IntentDescription = IntentDescription("Open a specific unit category in Equiv.")

    @Parameter(title: "Category", description: "The unit category to open (e.g. Currency, Length, Temperature).")
    var categoryName: String

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$categoryName)")
    }

    func perform() async throws -> some IntentResult & OpensIntent {
        let rawValue = UnitCategoryType.allCases
            .first { $0.rawValue.caseInsensitiveCompare(categoryName) == .orderedSame }?
            .rawValue ?? categoryName.lowercased()
        let url = URL(string: "equiv://category/\(rawValue)")!
        return .result(opensIntent: OpenURLIntent(url))
    }
}
