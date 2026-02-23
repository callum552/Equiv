//
//  PhoneSessionManager.swift
//  Equiv
//
//  Sends cached exchange rates to the Watch via WCSession application context.
//

import Foundation
import WatchConnectivity
import OSLog

private let logger = Logger(subsystem: "name.callumblack.Equiv", category: "PhoneSessionManager")

final class PhoneSessionManager: NSObject, WCSessionDelegate {
    static let shared = PhoneSessionManager()
    private override init() {}

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Sends exchange rates and the ordered code list to the Watch.
    func sendRates(_ rates: [String: Double], codes: [String]) {
        guard WCSession.default.activationState == .activated else { return }
        guard WCSession.default.isWatchAppInstalled else { return }
        do {
            let ratesData = try JSONEncoder().encode(rates)
            let codesData = try JSONEncoder().encode(codes)
            try WCSession.default.updateApplicationContext([
                "rates": ratesData,
                "codes": codesData
            ])
            logger.info("Sent \(rates.count) exchange rates to Watch")
        } catch {
            logger.error("Failed to send rates to Watch: \(error.localizedDescription)")
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error {
            logger.error("WCSession activation error: \(error.localizedDescription)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
