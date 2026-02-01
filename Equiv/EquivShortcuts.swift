//
//  EquivShortcuts.swift
//  Equiv
//
//  Created by Callum Black on 31/01/2026.
//

import AppIntents

struct EquivShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ConvertUnitIntent(),
            phrases: [
                "Convert units in \(.applicationName)",
                "Convert with \(.applicationName)",
                "Unit conversion in \(.applicationName)",
            ],
            shortTitle: "Convert Units",
            systemImageName: "arrow.left.arrow.right"
        )
    }
}
