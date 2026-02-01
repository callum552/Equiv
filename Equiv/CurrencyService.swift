//
//  CurrencyService.swift
//  Equiv
//
//  Created by Callum Black on 31/01/2026.
//

import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "name.callumblack.Equiv", category: "CurrencyService")

@Observable
class CurrencyService {
    struct CurrencyUnit: Identifiable {
        let id: String // currency code
        let name: String
        let symbol: String
        let rate: Double // rate relative to base (USD)
    }

    var currencies: [CurrencyUnit] = []
    var lastUpdated: Date?
    var isLoading = false
    var error: String?
    var cooldownRemaining: Int = 0

    private var modelContext: ModelContext?
    private var lastFetchTime: Date?
    private static let cooldownInterval: TimeInterval = 60
    private var cooldownTimer: Timer?

    private static let currencyNames: [String: String] = [
        "USD": "US Dollar", "EUR": "Euro", "GBP": "British Pound",
        "JPY": "Japanese Yen", "AUD": "Australian Dollar", "CAD": "Canadian Dollar",
        "CHF": "Swiss Franc", "CNY": "Chinese Yuan", "INR": "Indian Rupee",
        "MXN": "Mexican Peso", "BRL": "Brazilian Real", "KRW": "South Korean Won",
        "SEK": "Swedish Krona", "NOK": "Norwegian Krone", "DKK": "Danish Krone",
        "NZD": "New Zealand Dollar", "SGD": "Singapore Dollar", "HKD": "Hong Kong Dollar",
        "TRY": "Turkish Lira", "ZAR": "South African Rand", "RUB": "Russian Ruble",
        "PLN": "Polish Zloty", "THB": "Thai Baht", "TWD": "Taiwan Dollar",
        "MYR": "Malaysian Ringgit", "PHP": "Philippine Peso", "IDR": "Indonesian Rupiah",
        "CZK": "Czech Koruna", "ILS": "Israeli Shekel", "AED": "UAE Dirham"
    ]

    private static let supportedCodes: [String] = [
        "USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY", "INR", "MXN",
        "BRL", "KRW", "SEK", "NOK", "DKK", "NZD", "SGD", "HKD", "TRY", "ZAR",
        "RUB", "PLN", "THB", "TWD", "MYR", "PHP", "IDR", "CZK", "ILS", "AED"
    ]

    var canRefresh: Bool {
        guard let lastFetchTime else { return true }
        return Date().timeIntervalSince(lastFetchTime) >= Self.cooldownInterval
    }

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadCachedRates()
    }

    func fetchRates() async {
        guard !isLoading else { return }
        guard canRefresh else { return }

        await MainActor.run { isLoading = true; error = nil }

        do {
            let url = URL(string: "https://open.er-api.com/v6/latest/USD")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)

            guard response.result == "success" else {
                throw URLError(.badServerResponse)
            }

            let units = Self.supportedCodes.compactMap { code -> CurrencyUnit? in
                guard let rate = response.rates[code] else { return nil }
                let name = Self.currencyNames[code] ?? code
                return CurrencyUnit(id: code, name: name, symbol: code, rate: rate)
            }

            await MainActor.run {
                self.currencies = units
                self.lastUpdated = Date()
                self.lastFetchTime = Date()
                self.isLoading = false
                self.cacheRates(rates: response.rates)
                self.startCooldownTimer()
            }
            logger.info("Exchange rates updated successfully")
        } catch {
            logger.error("Failed to fetch exchange rates: \(error.localizedDescription)")
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func convert(value: Double, fromIndex: Int, toIndex: Int) -> Double {
        guard fromIndex < currencies.count, toIndex < currencies.count else { return 0 }
        let fromRate = currencies[fromIndex].rate
        let toRate = currencies[toIndex].rate
        guard fromRate > 0 else { return 0 }
        return value * (toRate / fromRate)
    }

    // MARK: - Cooldown

    private func startCooldownTimer() {
        cooldownTimer?.invalidate()
        cooldownRemaining = Int(Self.cooldownInterval)
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            if self.cooldownRemaining > 0 {
                self.cooldownRemaining -= 1
            } else {
                timer.invalidate()
            }
        }
    }

    // MARK: - Caching

    private func loadCachedRates() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<CachedExchangeRates>(
            sortBy: [SortDescriptor(\.lastFetched, order: .reverse)]
        )
        guard let cached = try? modelContext.fetch(descriptor).first,
              let ratesData = cached.ratesJSON.data(using: .utf8),
              let rates = try? JSONDecoder().decode([String: Double].self, from: ratesData) else { return }

        currencies = Self.supportedCodes.compactMap { code -> CurrencyUnit? in
            guard let rate = rates[code] else { return nil }
            let name = Self.currencyNames[code] ?? code
            return CurrencyUnit(id: code, name: name, symbol: code, rate: rate)
        }
        lastUpdated = cached.lastFetched
        logger.info("Loaded cached exchange rates from \(cached.lastFetched)")
    }

    private func cacheRates(rates: [String: Double]) {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<CachedExchangeRates>()
        if let existing = try? modelContext.fetch(descriptor) {
            for entry in existing { modelContext.delete(entry) }
        }
        if let jsonData = try? JSONEncoder().encode(rates),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let cached = CachedExchangeRates(ratesJSON: jsonString, baseCurrency: "USD", lastFetched: Date())
            modelContext.insert(cached)
            logger.info("Cached exchange rates saved")
        }
    }
}

// MARK: - API Response

private struct ExchangeRateResponse: Codable {
    let result: String
    let rates: [String: Double]
}
