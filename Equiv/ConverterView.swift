//
//  ConverterView.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import SwiftUI
import SwiftData
import WidgetKit
import OSLog

struct ConverterView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: ConverterViewModel
    @State private var favorites: FavoritesManager?
    @State private var liveActivityManager = LiveActivityManager()
    @State private var showCopied = false
    @State private var swapRotation: Double = 0
    @State private var showCopyTip = !UserDefaults.standard.bool(forKey: "equiv_copy_tip_shown")
    @State private var didSaveHistory = false
    @FocusState private var inputFocused: Bool
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @ScaledMetric(relativeTo: .title) private var resultFontSize: CGFloat = 36

    init(category: UnitCategoryType) {
        self.viewModel = ConverterViewModel(category: category)
    }

    private var favoritesManager: FavoritesManager {
        if let favorites { return favorites }
        let manager = FavoritesManager(modelContext: modelContext)
        DispatchQueue.main.async { self.favorites = manager }
        return manager
    }

    var body: some View {
        ScrollView {
            if sizeClass == .regular {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(viewModel.category.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    if !viewModel.shareText.isEmpty {
                        ShareLink(item: viewModel.shareText) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    Button {
                        withAnimation {
                            favoritesManager.toggle(viewModel.category)
                        }
                    } label: {
                        Image(systemName: favoritesManager.isFavorite(viewModel.category) ? "star.fill" : "star")
                            .foregroundStyle(favoritesManager.isFavorite(viewModel.category) ? .yellow : .secondary)
                    }
                    .accessibilityLabel(favoritesManager.isFavorite(viewModel.category) ? String(localized: "Remove from favorites") : String(localized: "Add to favorites"))
                    .accessibilityIdentifier("favorite_toggle")
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(String(localized: "Done")) {
                    inputFocused = false
                    saveToHistory()
                }
            }
        }
        .overlay(alignment: .top) {
            if showCopied {
                copiedBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay(alignment: .bottom) {
            if showCopyTip {
                copyTipBanner
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            startLiveActivity()
        }
        .onDisappear {
            saveToHistory()
            liveActivityManager.endActivity()
        }
        .onChange(of: viewModel.result) { _, newValue in
            if !newValue.isEmpty {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                AccessibilityNotification.Announcement("\(newValue) \(viewModel.destinationUnitSymbol)").post()
                liveActivityManager.updateActivity(
                    input: viewModel.inputValue,
                    result: newValue,
                    sourceSymbol: viewModel.sourceUnitSymbol,
                    destSymbol: viewModel.destinationUnitSymbol
                )
            }
        }
        .task {
            if viewModel.category.isCurrency {
                let service = CurrencyService(modelContext: modelContext)
                viewModel.currencyService = service
                await service.fetchRates()
            }
        }
    }

    // MARK: - Currency Info Bar

    private var currencyInfoBar: some View {
        VStack(spacing: 8) {
            if let service = viewModel.currencyService {
                // Error state with prominent retry
                if service.error != nil && service.currencies.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        Text(String(localized: "Unable to load exchange rates"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(String(localized: "Check your internet connection and try again."))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button {
                            Task { await service.fetchRates() }
                        } label: {
                            Label(String(localized: "Retry"), systemImage: "arrow.clockwise")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(service.isLoading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                } else {
                    // Normal info bar
                    HStack(spacing: 8) {
                        if service.isLoading {
                            ProgressView()
                                .controlSize(.small)
                            Text(String(localized: "Updating rates..."))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if let lastUpdated = service.lastUpdated {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(lastUpdated, style: .relative) \(String(localized: "ago"))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if service.error != nil && !service.currencies.isEmpty {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text(String(localized: "Using cached rates"))
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        Spacer()
                        if service.cooldownRemaining > 0 {
                            Text("\(service.cooldownRemaining)s")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .monospacedDigit()
                        }
                        Button {
                            Task { await service.fetchRates() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                                .foregroundStyle(service.canRefresh ? .secondary : .tertiary)
                        }
                        .disabled(!service.canRefresh || service.isLoading)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }

    // MARK: - Portrait Layout

    private var portraitLayout: some View {
        VStack(spacing: 0) {
            fromCard
            swapButton
            toCard
            if viewModel.category.isCurrency {
                currencyInfoBar
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Landscape Layout

    private var landscapeLayout: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                fromCard
                swapButton
                toCard
            }
            if viewModel.category.isCurrency {
                currencyInfoBar
            }
        }
        .padding()
    }

    // MARK: - From Card

    private var fromCard: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "FROM"))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                Picker(String(localized: "Source Unit"), selection: $viewModel.sourceIndex) {
                    ForEach(0..<viewModel.unitCount, id: \.self) { index in
                        Text(viewModel.unitName(at: index)).tag(index)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)

                HStack(spacing: 8) {
                    TextField("0", text: $viewModel.inputValue)
                        .keyboardType(.decimalPad)
                        .font(.system(size: resultFontSize, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .focused($inputFocused)
                        .accessibilityLabel(String(localized: "Value to convert"))
                        .accessibilityValue(viewModel.inputValue.isEmpty ? "0" : viewModel.inputValue)
                        .accessibilityInputLabels([String(localized: "Convert"), String(localized: "Source value"), String(localized: "Input")])
                        .accessibilityIdentifier("converter_input")

                    Button {
                        viewModel.toggleNegative()
                    } label: {
                        Text("+/\u{2212}")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .frame(width: 40, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    .accessibilityLabel(String(localized: "Toggle negative"))
                    .accessibilityHint(String(localized: "Makes the value negative or positive"))
                }
            }
        }
        .dropDestination(for: String.self) { items, _ in
            if let first = items.first {
                let cleaned = first.trimmingCharacters(in: .whitespacesAndNewlines)
                if Double(cleaned) != nil {
                    viewModel.inputValue = cleaned
                    return true
                }
            }
            return false
        }
    }

    // MARK: - To Card

    private var toCard: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(String(localized: "TO"))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        viewModel.useScientificNotation.toggle()
                    } label: {
                        Text("E")
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundStyle(viewModel.useScientificNotation ? .primary : .tertiary)
                            .frame(width: 28, height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .opacity(viewModel.useScientificNotation ? 1 : 0)
                            )
                    }
                    .accessibilityLabel(String(localized: "Scientific notation"))
                    .accessibilityValue(viewModel.useScientificNotation ? String(localized: "On") : String(localized: "Off"))
                    .accessibilityAddTraits(viewModel.useScientificNotation ? .isSelected : [])
                    .accessibilityIdentifier("scientific_notation_toggle")
                }

                Picker(String(localized: "Destination Unit"), selection: $viewModel.destinationIndex) {
                    ForEach(0..<viewModel.unitCount, id: \.self) { index in
                        Text(viewModel.unitName(at: index)).tag(index)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)

                Text(viewModel.result.isEmpty ? "\u{2014}" : viewModel.result)
                    .font(.system(size: resultFontSize, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(viewModel.result.isEmpty ? .tertiary : .primary)
                    .contentTransition(reduceMotion ? .identity : .numericText())
                    .animation(reduceMotion ? .none : .default, value: viewModel.result)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        copyResult()
                    }
                    .accessibilityLabel(String(localized: "Conversion result"))
                    .accessibilityValue(viewModel.result.isEmpty ? String(localized: "No result") : "\(viewModel.result) \(viewModel.destinationUnitSymbol)")
                    .accessibilityHint(String(localized: "Double tap to copy"))
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("converter_result")
                    .draggable(viewModel.result.isEmpty ? "" : viewModel.result)
            }
        }
    }

    // MARK: - Swap Button

    private var swapButton: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            if reduceMotion {
                viewModel.swap()
            } else {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.swap()
                    swapRotation += 180
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .rotationEffect(.degrees(swapRotation))
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    Circle()
                        .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
                )
        }
        .padding(.vertical, sizeClass == .regular ? 0 : -10)
        .zIndex(1)
        .hoverEffect(.lift)
        .accessibilityLabel(String(localized: "Swap source and destination units"))
        .accessibilityIdentifier("swap_button")
    }

    // MARK: - Glass Card

    private func glassCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
            )
    }

    // MARK: - Copy

    private func copyResult() {
        guard !viewModel.result.isEmpty else { return }
        UIPasteboard.general.string = viewModel.result
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        if reduceMotion {
            showCopied = true
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                showCopied = true
            }
        }
        if showCopyTip {
            UserDefaults.standard.set(true, forKey: "equiv_copy_tip_shown")
            if reduceMotion { showCopyTip = false } else { withAnimation { showCopyTip = false } }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if reduceMotion {
                showCopied = false
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showCopied = false
                }
            }
        }
    }

    // MARK: - Save to History

    private func saveToHistory() {
        guard !didSaveHistory else { return }
        let resultText = viewModel.result
        guard !viewModel.inputValue.isEmpty, !resultText.isEmpty else { return }
        didSaveHistory = true
        let manager = HistoryManager(modelContext: modelContext)
        manager.add(
            categoryRawValue: viewModel.category.rawValue,
            sourceUnitName: viewModel.sourceUnitSymbol,
            destinationUnitName: viewModel.destinationUnitSymbol,
            inputValue: viewModel.inputValue,
            resultValue: resultText
        )

        // Update widget data
        let shared = SharedConversion(
            categoryRawValue: viewModel.category.rawValue,
            sourceUnitSymbol: viewModel.sourceUnitSymbol,
            destinationUnitSymbol: viewModel.destinationUnitSymbol,
            inputValue: viewModel.inputValue,
            resultValue: resultText,
            categoryDisplayName: viewModel.category.displayName,
            timestamp: .now
        )
        SharedConversion.save(shared)
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Live Activity

    private func startLiveActivity() {
        let input = viewModel.inputValue.isEmpty ? "0" : viewModel.inputValue
        let result = viewModel.result.isEmpty ? "\u{2014}" : viewModel.result
        liveActivityManager.startActivity(
            categoryName: viewModel.category.displayName,
            input: input,
            result: result,
            sourceSymbol: viewModel.sourceUnitSymbol,
            destSymbol: viewModel.destinationUnitSymbol
        )
    }

    private var copiedBanner: some View {
        Text(String(localized: "Copied to clipboard"))
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                Capsule()
                    .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
            )
            .padding(.top, 8)
    }

    // MARK: - Onboarding Tip

    private var copyTipBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "hand.tap")
                .font(.subheadline)
            Text(String(localized: "Tap the result to copy it"))
                .font(.subheadline)
        }
        .fontWeight(.medium)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule()
                .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
        )
        .padding(.bottom, 20)
        .onTapGesture {
            UserDefaults.standard.set(true, forKey: "equiv_copy_tip_shown")
            withAnimation { showCopyTip = false }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                UserDefaults.standard.set(true, forKey: "equiv_copy_tip_shown")
                withAnimation { showCopyTip = false }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConverterView(category: .length)
    }
    .modelContainer(for: [FavoriteCategory.self, ConversionHistoryEntry.self], inMemory: true)
}
