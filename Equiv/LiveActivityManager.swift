//
//  LiveActivityManager.swift
//  Equiv
//
//  Created by Callum Black on 31/01/2026.
//

import ActivityKit
import Foundation

@Observable
class LiveActivityManager {
    private var currentActivity: Activity<ConversionActivityAttributes>?

    func startActivity(categoryName: String, input: String, result: String,
                       sourceSymbol: String, destSymbol: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = ConversionActivityAttributes(categoryName: categoryName)
        let state = ConversionActivityAttributes.ContentState(
            inputValue: input,
            resultValue: result,
            sourceUnitSymbol: sourceSymbol,
            destinationUnitSymbol: destSymbol
        )

        let content = ActivityContent(state: state, staleDate: nil)

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            // Live Activity not available
        }
    }

    func updateActivity(input: String, result: String, sourceSymbol: String, destSymbol: String) {
        guard let activity = currentActivity else { return }

        let state = ConversionActivityAttributes.ContentState(
            inputValue: input,
            resultValue: result,
            sourceUnitSymbol: sourceSymbol,
            destinationUnitSymbol: destSymbol
        )

        let content = ActivityContent(state: state, staleDate: nil)

        Task {
            await activity.update(content)
        }
    }

    func endActivity() {
        guard let activity = currentActivity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
