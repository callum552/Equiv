//
//  AboutView.swift
//  Equiv
//
//  Created by Callum Black on 01/02/2026.
//

import SwiftUI
import SwiftData
import StoreKit

struct AboutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview
    @State private var showClearConfirmation = false

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        List {
            // App Info Section
            Section {
                VStack(spacing: 8) {
                    Image("AppIconDisplay")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Text("Equiv")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(String(localized: "Unit Converter"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("v\(appVersion)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .listRowBackground(Color.clear)
            }

            // Actions Section
            Section {
                Button {
                    requestReview()
                } label: {
                    Label(String(localized: "Rate Equiv"), systemImage: "star")
                }

                ShareLink(
                    item: URL(string: "https://apps.apple.com/app/equiv")!,
                    subject: Text("Equiv"),
                    message: Text(String(localized: "Check out Equiv – a unit converter app"))
                ) {
                    Label(String(localized: "Share Equiv"), systemImage: "square.and.arrow.up")
                }
            }

            // Data Section
            Section {
                Button(role: .destructive) {
                    showClearConfirmation = true
                } label: {
                    Label(String(localized: "Clear Conversion History"), systemImage: "trash")
                }
            } footer: {
                Text(String(localized: "This will remove all saved conversion history. Favorites will not be affected."))
            }

            // Info Section
            Section {
                LabeledContent(String(localized: "Version"), value: appVersion)
                LabeledContent(String(localized: "Categories"), value: "\(UnitCategoryType.allCases.count)")

                Link(destination: URL(string: "https://open.er-api.com")!) {
                    Label(String(localized: "Exchange Rates by Open ER API"), systemImage: "link")
                }
            } header: {
                Text(String(localized: "Info"))
            } footer: {
                Text(String(localized: "Currency exchange rates are provided for informational purposes only and may not reflect real-time market rates."))
            }

            // Legal Section
            Section {
                NavigationLink {
                    acknowledgmentsView
                } label: {
                    Label(String(localized: "Acknowledgments"), systemImage: "doc.text")
                }
            }
        }
        .navigationTitle(String(localized: "About"))
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            String(localized: "Clear History"),
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Clear History"), role: .destructive) {
                clearHistory()
            }
        } message: {
            Text(String(localized: "Are you sure you want to delete all conversion history? This cannot be undone."))
        }
    }

    private func clearHistory() {
        let descriptor = FetchDescriptor<ConversionHistoryEntry>()
        if let entries = try? modelContext.fetch(descriptor) {
            for entry in entries {
                modelContext.delete(entry)
            }
        }
    }

    private var acknowledgmentsView: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Open Exchange Rates API")
                        .font(.headline)
                    Text(String(localized: "Free exchange rate data provided by open.er-api.com."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Apple Frameworks")
                        .font(.headline)
                    Text(String(localized: "Built with SwiftUI, SwiftData, WidgetKit, ActivityKit, CoreSpotlight, and AppIntents."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(String(localized: "Acknowledgments"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
    .modelContainer(for: [ConversionHistoryEntry.self], inMemory: true)
}
