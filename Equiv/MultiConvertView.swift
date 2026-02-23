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
    @State private var searchText = ""
    @State private var sortAscending: Bool? = nil // nil = default order

    private var displayedResults: [MultiConvertResult] {
        var results = viewModel.allResults

        if !searchText.isEmpty {
            results = results.filter {
                $0.unitName.localizedCaseInsensitiveContains(searchText) ||
                $0.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let ascending = sortAscending {
            results.sort {
                guard let a = Double($0.value), let b = Double($1.value) else { return false }
                return ascending ? a < b : a > b
            }
        }

        return results
    }

    private var sortIcon: String {
        switch sortAscending {
        case .none: return "arrow.up.arrow.down"
        case .some(true): return "arrow.up"
        case .some(false): return "arrow.down"
        }
    }

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
                    .accessibilityAddTraits(.isHeader)

                    ForEach(displayedResults) { result in
                        resultRow(result)
                    }

                    if displayedResults.isEmpty {
                        ContentUnavailableView(
                            String(localized: "No Results"),
                            systemImage: "magnifyingglass",
                            description: Text(String(localized: "No units match your search."))
                        )
                        .padding(.top, 40)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "All Units"))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: String(localized: "Search units"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        cycleSortOrder()
                    } label: {
                        Label(sortLabel, systemImage: sortIcon)
                            .labelStyle(.iconOnly)
                    }
                    .accessibilityLabel(sortLabel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !displayedResults.isEmpty {
                        ShareLink(item: copyAllText) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel(String(localized: "Share all results"))
                    }
                }
            }
        }
    }

    private var sortLabel: String {
        switch sortAscending {
        case .none: return String(localized: "Sort")
        case .some(true): return String(localized: "Sorted ascending")
        case .some(false): return String(localized: "Sorted descending")
        }
    }

    private func cycleSortOrder() {
        switch sortAscending {
        case .none: sortAscending = true
        case .some(true): sortAscending = false
        case .some(false): sortAscending = nil
        }
    }

    private var copyAllText: String {
        let header = "\(viewModel.inputValue) \(viewModel.sourceUnitSymbol)"
        let lines = displayedResults.map { "  \($0.value) \($0.symbol)  (\($0.unitName))" }
        return ([header] + lines).joined(separator: "\n")
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
                    Text(String(localized: "Copied"))
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.unitName), \(result.value) \(result.symbol)")
        .accessibilityHint(String(localized: "Double tap to copy"))
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("multi_result_\(result.symbol)")
        .draggable(result.value)
    }
}

#Preview {
    let vm = ConverterViewModel(category: .length)
    vm.inputValue = "100"
    return MultiConvertView(viewModel: vm)
}
