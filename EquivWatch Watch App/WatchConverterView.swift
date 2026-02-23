//
//  WatchConverterView.swift
//  EquivWatch Watch App
//
//  Created by Callum Black on 31/01/2026.
//

import SwiftUI
import WatchKit

struct WatchConverterView: View {
    @State private var viewModel: WatchConverterViewModel
    @State private var swapRotation: Double = 0
    @State private var showCopied = false

    init(category: UnitCategoryType) {
        _viewModel = State(initialValue: WatchConverterViewModel(category: category))
    }

    var body: some View {
        if viewModel.category.isCurrency && !viewModel.hasCurrencyRates {
            ContentUnavailableView(
                String(localized: "No Rates"),
                systemImage: "wifi.slash",
                description: Text(String(localized: "Open Equiv on your iPhone to sync exchange rates."))
            )
            .navigationTitle(viewModel.category.displayName)
        } else {
            mainContent
        }
    }

    private var mainContent: some View {
        List {
            // MARK: - From
            Section {
                Picker(String(localized: "Unit"), selection: $viewModel.sourceIndex) {
                    ForEach(0..<viewModel.unitCount, id: \.self) { index in
                        Text(viewModel.unitName(at: index)).tag(index)
                    }
                }

                crownInput
            } header: {
                Text("FROM")
            }

            // MARK: - Controls
            Section {
                HStack(spacing: 0) {
                    // Swap
                    Button {
                        WKInterfaceDevice.current().play(.click)
                        withAnimation(.spring(duration: 0.3)) {
                            viewModel.swap()
                            swapRotation += 180
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 14, weight: .semibold))
                            .rotationEffect(.degrees(swapRotation))
                            .frame(maxWidth: .infinity)
                    }

                    Divider()

                    // Negative toggle
                    Button {
                        WKInterfaceDevice.current().play(.click)
                        viewModel.toggleNegative()
                    } label: {
                        Text("+/−")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                    }

                    Divider()

                    // Reset
                    Button {
                        WKInterfaceDevice.current().play(.click)
                        withAnimation {
                            viewModel.reset()
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }

            // MARK: - To
            Section {
                Picker(String(localized: "Unit"), selection: $viewModel.destinationIndex) {
                    ForEach(0..<viewModel.unitCount, id: \.self) { index in
                        Text(viewModel.unitName(at: index)).tag(index)
                    }
                }

                resultRow
            } header: {
                Text("TO")
            }

            // MARK: - Step Size
            Section {
                Picker(String(localized: "Crown Step"), selection: $viewModel.stepIndex) {
                    ForEach(0..<viewModel.steps.count, id: \.self) { index in
                        Text(viewModel.steps[index].label).tag(index)
                    }
                }
            } header: {
                Text("STEP")
            }
        }
        .navigationTitle(viewModel.category.displayName)
        .overlay(alignment: .top) {
            if showCopied {
                Text(String(localized: "Copied"))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Crown Input

    private var crownInput: some View {
        HStack(spacing: 4) {
            Text(viewModel.formattedInput)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: viewModel.formattedInput)

            Text(viewModel.sourceSymbol)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Image(systemName: "digitalcrown.horizontal.arrow.clockwise")
                .font(.caption2)
                .foregroundColor(Color.accentColor)
        }
        .focusable()
        .digitalCrownRotation(
            $viewModel.crownValue,
            from: -99999,
            through: 99999,
            by: viewModel.crownStep,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
    }

    // MARK: - Result Row

    private var resultRow: some View {
        HStack(spacing: 4) {
            Text(viewModel.result.isEmpty ? "—" : viewModel.result)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .monospacedDigit()
                .foregroundColor(viewModel.result.isEmpty ? Color.secondary : Color.blue)
                .contentTransition(.numericText())
                .animation(.default, value: viewModel.result)

            if !viewModel.result.isEmpty {
                Text(viewModel.destinationSymbol)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            copyResult()
        }
    }

    // MARK: - Copy Result

    private func copyResult() {
        guard !viewModel.result.isEmpty else { return }
        WKInterfaceDevice.current().play(.success)
        withAnimation(.easeInOut(duration: 0.2)) {
            showCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showCopied = false
            }
        }
    }
}
