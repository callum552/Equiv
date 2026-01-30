//
//  ConverterView.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import SwiftUI

struct ConverterView: View {
    @Bindable var viewModel: ConverterViewModel
    var favorites = FavoritesManager.shared
    @State private var showCopied = false
    @State private var swapRotation: Double = 0
    @State private var showMultiConvert = false
    @State private var showCopyTip = !UserDefaults.standard.bool(forKey: "equiv_copy_tip_shown")
    @FocusState private var inputFocused: Bool
    @Environment(\.horizontalSizeClass) private var sizeClass

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
                    // Share
                    if !viewModel.shareText.isEmpty {
                        ShareLink(item: viewModel.shareText) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    // Favorite
                    Button {
                        withAnimation {
                            favorites.toggle(viewModel.category)
                        }
                    } label: {
                        Image(systemName: favorites.isFavorite(viewModel.category) ? "star.fill" : "star")
                            .foregroundStyle(favorites.isFavorite(viewModel.category) ? .yellow : .secondary)
                    }
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    inputFocused = false
                    viewModel.saveToHistory()
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
        .sheet(isPresented: $showMultiConvert) {
            MultiConvertView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .onDisappear {
            viewModel.saveToHistory()
        }
    }

    // MARK: - Portrait Layout

    private var portraitLayout: some View {
        VStack(spacing: 0) {
            fromCard
            swapButton
            toCard
            actionBar
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
            actionBar
        }
        .padding()
    }

    // MARK: - From Card

    private var fromCard: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("FROM")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                Picker("Source Unit", selection: $viewModel.sourceIndex) {
                    ForEach(0..<viewModel.unitCount, id: \.self) { index in
                        Text(viewModel.unitName(at: index)).tag(index)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)

                HStack(spacing: 8) {
                    TextField("0", text: $viewModel.inputValue)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .focused($inputFocused)

                    Button {
                        viewModel.toggleNegative()
                    } label: {
                        Text("+/−")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .frame(width: 40, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                }
            }
        }
    }

    // MARK: - To Card

    private var toCard: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("TO")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Scientific notation toggle
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
                }

                Picker("Destination Unit", selection: $viewModel.destinationIndex) {
                    ForEach(0..<viewModel.unitCount, id: \.self) { index in
                        Text(viewModel.unitName(at: index)).tag(index)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)

                Text(viewModel.result.isEmpty ? "—" : viewModel.result)
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(viewModel.result.isEmpty ? .tertiary : .primary)
                    .contentTransition(.numericText())
                    .animation(.default, value: viewModel.result)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        copyResult()
                    }
            }
        }
    }

    // MARK: - Swap Button

    private var swapButton: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            withAnimation(.spring(duration: 0.3)) {
                viewModel.swap()
                swapRotation += 180
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
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                showMultiConvert = true
            } label: {
                Label("Show All", systemImage: "list.bullet")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 16)
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
        withAnimation(.easeInOut(duration: 0.25)) {
            showCopied = true
        }
        // Dismiss tip permanently
        if showCopyTip {
            UserDefaults.standard.set(true, forKey: "equiv_copy_tip_shown")
            withAnimation { showCopyTip = false }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.25)) {
                showCopied = false
            }
        }
    }

    private var copiedBanner: some View {
        Text("Copied to clipboard")
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
            Text("Tap the result to copy it")
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
        ConverterView(viewModel: ConverterViewModel(category: .length))
    }
}
