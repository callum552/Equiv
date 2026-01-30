//
//  MultiConvertView.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import SwiftUI

struct MultiConvertView: View {
    var viewModel: ConverterViewModel
    @State private var copiedSymbol: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    // Source value header
                    HStack {
                        Text("\(viewModel.inputValue) \(viewModel.sourceUnitSymbol)")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)

                    ForEach(viewModel.allResults) { result in
                        resultRow(result)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("All Units")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {}
                        .hidden()
                }
            }
        }
    }

    private func resultRow(_ result: MultiConvertResult) -> some View {
        Button {
            UIPasteboard.general.string = result.value
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            copiedSymbol = result.symbol
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if copiedSymbol == result.symbol {
                    copiedSymbol = nil
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.unitName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(result.value)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }
                Spacer()
                if copiedSymbol == result.symbol {
                    Text("Copied")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                } else {
                    Text(result.symbol)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let vm = ConverterViewModel(category: .length)
    vm.inputValue = "100"
    return MultiConvertView(viewModel: vm)
}
