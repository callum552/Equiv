//
//  SharedConversion.swift
//  Widget
//
//  Shared data model for widget <-> app communication via App Group.
//  Keep in sync with Equiv/SharedConversion.swift.
//

import Foundation

struct SharedConversion: Codable {
    var categoryRawValue: String
    var sourceUnitSymbol: String
    var destinationUnitSymbol: String
    var inputValue: String
    var resultValue: String
    var categoryDisplayName: String
    var timestamp: Date

    static let appGroupID = "group.name.callumblack.Equiv"
    static let userDefaultsKey = "equiv_widget_conversion"

    static func save(_ conversion: SharedConversion) {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = try? JSONEncoder().encode(conversion) else { return }
        defaults.set(data, forKey: userDefaultsKey)
    }

    static func load() -> SharedConversion? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: userDefaultsKey),
              let conversion = try? JSONDecoder().decode(SharedConversion.self, from: data) else { return nil }
        return conversion
    }
}
