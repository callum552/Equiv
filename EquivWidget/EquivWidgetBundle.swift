//
//  EquivWidgetBundle.swift
//  EquivWidget
//
//  Created by Callum Black on 31/01/2026.
//

import WidgetKit
import SwiftUI

@main
struct EquivWidgetBundle: WidgetBundle {
    var body: some Widget {
        EquivWidget()
        ConversionLiveActivity()
    }
}
