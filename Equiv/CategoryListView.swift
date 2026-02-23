//
//  CategoryListView.swift
//  Equiv
//
//  Created by Callum Black on 30/01/2026.
//

import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var favorites: FavoritesManager?
    @State private var navigationPath = NavigationPath()
    @Binding var deepLinkCategory: UnitCategoryType?
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    @Environment(\.horizontalSizeClass) private var sizeClass

    // iPad split-view selection
    @State private var selectedCategory: UnitCategoryType?

    @Query(sort: \CustomConversionEntry.groupName) private var customEntries: [CustomConversionEntry]

    init(deepLinkCategory: Binding<UnitCategoryType?> = .constant(nil)) {
        self._deepLinkCategory = deepLinkCategory
    }

    private var favoritesManager: FavoritesManager {
        if let favorites { return favorites }
        let manager = FavoritesManager(modelContext: modelContext)
        DispatchQueue.main.async { self.favorites = manager }
        return manager
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return String(localized: "Good morning")
        case 12..<17: return String(localized: "Good afternoon")
        case 17..<22: return String(localized: "Good evening")
        default: return String(localized: "Good evening")
        }
    }

    private var filteredCategories: [UnitCategoryType] {
        if searchText.isEmpty {
            return UnitCategoryType.allCases.filter { !favoritesManager.isFavorite($0) }
        }
        return UnitCategoryType.allCases.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredFavorites: [UnitCategoryType] {
        if searchText.isEmpty {
            return favoritesManager.favorites
        }
        return favoritesManager.favorites.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var customGroups: [String] {
        let groups = Set(customEntries.map { $0.groupName })
        if searchText.isEmpty { return groups.sorted() }
        return groups.filter { $0.localizedCaseInsensitiveContains(searchText) }.sorted()
    }

    var body: some View {
        if sizeClass == .regular {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    // MARK: - iPhone Layout (NavigationStack)

    private var iPhoneLayout: some View {
        NavigationStack(path: $navigationPath) {
            listContent
                .navigationDestination(for: UnitCategoryType.self) { category in
                    ConverterView(category: category)
                }
                .navigationDestination(for: String.self) { value in
                    destinationView(for: value)
                }
                .navigationDestination(for: CustomGroupNav.self) { nav in
                    let units = customEntries
                        .filter { $0.groupName == nav.groupName }
                        .sorted { $0.sortOrder < $1.sortOrder }
                    CustomConverterView(groupName: nav.groupName, entries: units)
                }
        }
        .onChange(of: deepLinkCategory) { _, newValue in
            if let category = newValue {
                navigationPath.append(category)
                deepLinkCategory = nil
            }
        }
    }

    // MARK: - iPad Layout (NavigationSplitView)

    private var iPadLayout: some View {
        NavigationSplitView {
            NavigationStack {
                listContent
                    .navigationDestination(for: String.self) { value in
                        destinationView(for: value)
                    }
                    .navigationDestination(for: CustomGroupNav.self) { nav in
                        let units = customEntries
                            .filter { $0.groupName == nav.groupName }
                            .sorted { $0.sortOrder < $1.sortOrder }
                        CustomConverterView(groupName: nav.groupName, entries: units)
                    }
            }
        } detail: {
            if let category = selectedCategory {
                NavigationStack {
                    ConverterView(category: category)
                }
            } else {
                ContentUnavailableView(
                    String(localized: "Select a Category"),
                    systemImage: "arrow.left.and.right.righttriangle.left.righttriangle.right",
                    description: Text(String(localized: "Choose a unit category from the list."))
                )
            }
        }
        .onChange(of: deepLinkCategory) { _, newValue in
            if let category = newValue {
                selectedCategory = category
                deepLinkCategory = nil
            }
        }
    }

    // MARK: - Shared List Content

    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if searchText.isEmpty {
                    heroHeader
                }

                if !filteredFavorites.isEmpty {
                    sectionHeader(String(localized: "Favorites"))
                    ForEach(filteredFavorites) { category in
                        categoryCard(category)
                    }
                }

                if !customGroups.isEmpty {
                    sectionHeader(String(localized: "My Conversions"))
                    ForEach(customGroups, id: \.self) { group in
                        customGroupCard(group)
                    }
                }

                sectionHeader(
                    filteredFavorites.isEmpty ? String(localized: "Categories") : String(localized: "All Categories")
                )
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
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: String(localized: "Search categories"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(value: "about") {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel(String(localized: "About"))
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    if supportsMultipleWindows {
                        Button {
                            openWindow(id: "equiv-converter")
                        } label: {
                            Image(systemName: "plus.rectangle.on.rectangle")
                        }
                        .accessibilityLabel(String(localized: "Open new window"))
                    }
                    NavigationLink(value: "history") {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                    .accessibilityLabel(String(localized: "History"))
                }
            }
        }
    }

    @ViewBuilder
    private func destinationView(for value: String) -> some View {
        switch value {
        case "history":
            HistoryView()
        case "about":
            AboutView()
        case "custom_manage":
            CustomConversionsManageView()
        default:
            EmptyView()
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Equiv")
                .font(.system(size: 34, weight: .bold, design: .rounded))

            Text(greeting)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(UnitCategoryType.allCases.count) \(String(localized: "unit categories ready to convert"))")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.leading, 4)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("hero_header")
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
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Category Card

    private func categoryCard(_ category: UnitCategoryType) -> some View {
        Group {
            if sizeClass == .regular {
                // iPad: tap sets selectedCategory for split-view detail
                Button {
                    selectedCategory = category
                } label: {
                    cardLabel(category)
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink(value: category) {
                    cardLabel(category)
                }
                .buttonStyle(.plain)
            }
        }
        .hoverEffect(.lift)
        .accessibilityLabel(category.displayName)
        .accessibilityHint(String(localized: "Opens unit converter"))
        .accessibilityIdentifier("category_\(category.rawValue)")
    }

    private func cardLabel(_ category: UnitCategoryType) -> some View {
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

            if favoritesManager.isFavorite(category) {
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

    // MARK: - Custom Group Card

    private func customGroupCard(_ groupName: String) -> some View {
        NavigationLink(value: CustomGroupNav(groupName: groupName)) {
            HStack(spacing: 14) {
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.purple.gradient)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(groupName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    let count = customEntries.filter { $0.groupName == groupName }.count
                    Text("\(count) \(String(localized: "units"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

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
        .hoverEffect(.lift)
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
        case .currency: .green
        case .bloodSugar: .red
        case .typography: .indigo
        case .flowRate: .teal
        }
    }
}

// MARK: - Navigation Value for Custom Groups

struct CustomGroupNav: Hashable {
    let groupName: String
}

#Preview {
    CategoryListView()
        .modelContainer(for: [FavoriteCategory.self, ConversionHistoryEntry.self, CustomConversionEntry.self], inMemory: true)
}
