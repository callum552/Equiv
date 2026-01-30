//
//  CategoryListView.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import SwiftUI

struct CategoryListView: View {
    @State private var searchText = ""
    var favorites = FavoritesManager.shared

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good evening"
        }
    }

    private var filteredCategories: [UnitCategoryType] {
        if searchText.isEmpty {
            return UnitCategoryType.allCases.filter { !favorites.isFavorite($0) }
        }
        return UnitCategoryType.allCases.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredFavorites: [UnitCategoryType] {
        if searchText.isEmpty {
            return favorites.favorites
        }
        return favorites.favorites.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Hero header
                    if searchText.isEmpty {
                        heroHeader
                    }

                    if !filteredFavorites.isEmpty {
                        sectionHeader("Favorites")
                        ForEach(filteredFavorites) { category in
                            categoryCard(category)
                        }
                    }

                    sectionHeader(filteredFavorites.isEmpty ? "Categories" : "All Categories")
                    ForEach(filteredCategories) { category in
                        categoryCard(category)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.systemGroupedBackground).opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Equiv")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search categories")
            .navigationDestination(for: UnitCategoryType.self) { category in
                ConverterView(viewModel: ConverterViewModel(category: category))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: "history") {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "history" {
                    HistoryView()
                        .navigationDestination(for: UnitCategoryType.self) { category in
                            ConverterView(viewModel: ConverterViewModel(category: category))
                        }
                }
            }
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Equiv")
                .font(.system(size: 34, weight: .bold, design: .rounded))

            Text("\(UnitCategoryType.allCases.count) unit categories ready to convert")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.leading, 4)
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.top, 8)
        .padding(.leading, 4)
    }

    // MARK: - Category Card

    private func categoryCard(_ category: UnitCategoryType) -> some View {
        NavigationLink(value: category) {
            HStack(spacing: 14) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(iconColor(for: category).gradient)
                    )

                Text(category.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Spacer()

                if favorites.isFavorite(category) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
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

    private func iconColor(for category: UnitCategoryType) -> Color {
        switch category {
        case .length: .blue
        case .mass: .orange
        case .temperature: .red
        case .volume: .cyan
        case .area: .green
        case .speed: .purple
        case .time: .indigo
        case .digitalStorage: .gray
        case .energy: .yellow
        case .pressure: .teal
        case .angle: .mint
        case .frequency: .pink
        case .fuelEconomy: .brown
        case .power: .orange
        case .force: .red
        case .dataTransferRate: .blue
        case .torque: .purple
        case .density: .cyan
        case .illuminance: .yellow
        }
    }
}

#Preview {
    CategoryListView()
}
