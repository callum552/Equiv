//
//  AppIntent.swift
//  Widget
//
//  Created by Callum Black on 31/01/2026.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Configure the Equiv widget." }
}
