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
        List {
            // MARK: - From Section
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

            // MARK: - Swap
            Section {
                Button {
                    WKInterfaceDevice.current().play(.click)
                    withAnimation(.spring(duration: 0.3)) {
                        viewModel.swap()
                        swapRotation += 180
                    }
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 14, weight: .semibold))
                            .rotationEffect(.degrees(swapRotation))
                        Spacer()
                    }
                }
            }

            // MARK: - To Section
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
            }
        }
        .navigationTitle(viewModel.category.displayName)
        .overlay(alignment: .top) {
            if showCopied {
                Text("Copied")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Crown Input

    private var crownInput: some View {
        HStack {
            Text(viewModel.formattedInput)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.default, value: viewModel.formattedInput)

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
        Text(viewModel.result.isEmpty ? "\u{2014}" : viewModel.result)
            .font(.system(.title3, design: .rounded, weight: .bold))
            .monospacedDigit()
            .foregroundColor(viewModel.result.isEmpty ? Color.secondary : Color.blue)
            .contentTransition(.numericText())
            .animation(.default, value: viewModel.result)
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
