//
//  WatchSessionManager.swift
//  EquivWatch Watch App
//
//  Receives exchange rates from the iPhone and persists them to UserDefaults.
//

import Foundation
import WatchConnectivity
import OSLog

private let logger = Logger(subsystem: "name.callumblack.EquivWatch", category: "WatchSessionManager")

final class WatchSessionManager: NSObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    private override init() {}

    static let ratesKey = "watch_rates_json"
    static let codesKey = "watch_codes_json"

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if let error {
            logger.error("WCSession activation error: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        if let ratesData = applicationContext["rates"] as? Data {
            UserDefaults.standard.set(ratesData, forKey: Self.ratesKey)
        }
        if let codesData = applicationContext["codes"] as? Data {
            UserDefaults.standard.set(codesData, forKey: Self.codesKey)
        }
        logger.info("Received exchange rate context from iPhone")
        // Notify any active view models that new rates arrived
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .watchRatesDidUpdate, object: nil)
        }
    }
}

extension Notification.Name {
    static let watchRatesDidUpdate = Notification.Name("watchRatesDidUpdate")
}
