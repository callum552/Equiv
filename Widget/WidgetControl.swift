//
//  WidgetControl.swift
//  Widget
//
//  Created by Callum Black on 31/01/2026.
//

import AppIntents
import SwiftUI
import WidgetKit

struct WidgetControl: ControlWidget {
    static let kind: String = "name.callumblack.Equiv.Widget"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: OpenEquivIntent()) {
                Label("Equiv", systemImage: "arrow.left.arrow.right")
            }
        }
        .displayName("Open Equiv")
        .description("Quickly open the Equiv unit converter.")
    }
}

struct OpenEquivIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Equiv"
    static let description: IntentDescription = IntentDescription("Opens the Equiv unit converter")
    static let openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
