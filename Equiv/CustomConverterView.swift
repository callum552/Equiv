//
//  CustomConverterView.swift
//  Equiv
//
//  A converter view for user-defined custom conversion groups.
//

import SwiftUI
import SwiftData

struct CustomConverterView: View {
    let groupName: String
    let entries: [CustomConversionEntry]

    @State private var inputValue = ""
    @State private var sourceIndex = 0
    @State private var destinationIndex = 1
    @State private var showCopied = false
    @FocusState private var inputFocused: Bool
    @ScaledMetric(relativeTo: .title) private var resultFontSize: CGFloat = 36

    private var unitCount: Int { entries.count }

    private var result: String {
        guard entries.count >= 2,
              sourceIndex < entries.count,
              destinationIndex < entries.count else { return "" }
        guard let value = Double(inputValue), value != 0 else { return "" }
        let baseValue = value * entries[sourceIndex].toBaseFactor
        let converted = baseValue / entries[destinationIndex].toBaseFactor
        return formatResult(converted)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                fromCard
                swapButton
                toCard
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(groupName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(String(localized: "Done")) { inputFocused = false }
            }
        }
        .overlay(alignment: .top) {
            if showCopied {
                Text(String(localized: "Copied to clipboard"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .overlay(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var fromCard: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "FROM"))
                    .font(.caption).fontWeight(.bold).foregroundStyle(.secondary)

                Picker(String(localized: "Source Unit"), selection: $sourceIndex) {
                    ForEach(0..<unitCount, id: \.self) { i in
                        Text(unitLabel(at: i)).tag(i)
                    }
                }
                .pickerStyle(.menu).tint(.primary)

                TextField("0", text: $inputValue)
                    .keyboardType(.decimalPad)
                    .font(.system(size: resultFontSize, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .focused($inputFocused)
            }
        }
    }

    private var swapButton: some View {
        Button {
            let temp = sourceIndex
            sourceIndex = destinationIndex
            destinationIndex = temp
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.title3).fontWeight(.semibold).foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.ultraThinMaterial))
                .overlay(Circle().strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
        }
        .padding(.vertical, -10)
        .zIndex(1)
    }

    private var toCard: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "TO"))
                    .font(.caption).fontWeight(.bold).foregroundStyle(.secondary)

                Picker(String(localized: "Destination Unit"), selection: $destinationIndex) {
                    ForEach(0..<unitCount, id: \.self) { i in
                        Text(unitLabel(at: i)).tag(i)
                    }
                }
                .pickerStyle(.menu).tint(.primary)

                Text(result.isEmpty ? "\u{2014}" : result)
                    .font(.system(size: resultFontSize, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(result.isEmpty ? .tertiary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture { copyResult() }
            }
        }
    }

    private func unitLabel(at index: Int) -> String {
        guard index < entries.count else { return "" }
        return "\(entries[index].unitName) (\(entries[index].unitSymbol))"
    }

    private func glassCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.regularMaterial))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 0.5))
    }

    private func copyResult() {
        guard !result.isEmpty else { return }
        UIPasteboard.general.string = result
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.easeInOut(duration: 0.25)) { showCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.25)) { showCopied = false }
        }
    }

    private func formatResult(_ value: Double) -> String {
        if value == 0 { return "0" }
        if abs(value) >= 1_000_000 || (abs(value) < 0.001 && abs(value) > 0) {
            return String(format: "%g", value)
        }
        let formatted = String(format: "%.6f", value)
        var trimmed = formatted
        while trimmed.hasSuffix("0") { trimmed.removeLast() }
        if trimmed.hasSuffix(".") { trimmed.removeLast() }
        return trimmed
    }
}

// MARK: - Custom Conversions Management View

struct CustomConversionsManageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomConversionEntry.groupName) private var entries: [CustomConversionEntry]
    @State private var showAddGroup = false
    @State private var newGroupName = ""
    @State private var editingGroup: String?
    @State private var newUnitName = ""
    @State private var newUnitSymbol = ""
    @State private var newUnitFactor = ""

    private var groups: [String] {
        Array(Set(entries.map { $0.groupName })).sorted()
    }

    var body: some View {
        List {
            Section {
                Button {
                    showAddGroup = true
                } label: {
                    Label(String(localized: "Add New Group"), systemImage: "plus.circle")
                }
            }

            ForEach(groups, id: \.self) { group in
                Section(group) {
                    let groupEntries = entries.filter { $0.groupName == group }.sorted { $0.sortOrder < $1.sortOrder }
                    ForEach(groupEntries) { entry in
                        HStack {
                            Text(entry.unitName)
                                .font(.body)
                            Spacer()
                            Text(entry.unitSymbol)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("×\(formatFactor(entry.toBaseFactor))")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .monospacedDigit()
                        }
                    }
                    .onDelete { indices in
                        deleteEntries(in: groupEntries, at: indices)
                    }

                    Button {
                        editingGroup = group
                    } label: {
                        Label(String(localized: "Add Unit"), systemImage: "plus")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "Custom Conversions"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(String(localized: "New Group"), isPresented: $showAddGroup) {
            TextField(String(localized: "Group name (e.g. Screen Sizes)"), text: $newGroupName)
            Button(String(localized: "Create")) {
                createInitialUnit(for: newGroupName)
                newGroupName = ""
            }
            .disabled(newGroupName.trimmingCharacters(in: .whitespaces).isEmpty)
            Button(String(localized: "Cancel"), role: .cancel) { newGroupName = "" }
        }
        .sheet(item: Binding(
            get: { editingGroup.map { AddUnitTarget(groupName: $0) } },
            set: { editingGroup = $0?.groupName }
        )) { target in
            addUnitSheet(for: target.groupName)
        }
    }

    private func addUnitSheet(for group: String) -> some View {
        NavigationStack {
            Form {
                Section(String(localized: "New Unit in \"\(group)\"")) {
                    TextField(String(localized: "Name (e.g. Storey)"), text: $newUnitName)
                    TextField(String(localized: "Symbol (e.g. st)"), text: $newUnitSymbol)
                    TextField(String(localized: "Factor (relative to base unit)"), text: $newUnitFactor)
                        .keyboardType(.decimalPad)
                }
                Section {
                    Text(String(localized: "The factor defines how many base units equal 1 of this unit. The first unit in the group is the base (factor = 1)."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(String(localized: "Add Unit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "Cancel")) {
                        editingGroup = nil
                        clearUnitFields()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Add")) {
                        addUnit(to: group)
                        editingGroup = nil
                    }
                    .disabled(newUnitName.isEmpty || newUnitSymbol.isEmpty || Double(newUnitFactor) == nil)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func createInitialUnit(for group: String) {
        let trimmed = group.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let entry = CustomConversionEntry(
            groupName: trimmed,
            unitName: String(localized: "Base Unit"),
            unitSymbol: "1",
            toBaseFactor: 1.0,
            sortOrder: 0
        )
        modelContext.insert(entry)
    }

    private func addUnit(to group: String) {
        guard let factor = Double(newUnitFactor), factor > 0 else { return }
        let existing = entries.filter { $0.groupName == group }
        let entry = CustomConversionEntry(
            groupName: group,
            unitName: newUnitName.trimmingCharacters(in: .whitespaces),
            unitSymbol: newUnitSymbol.trimmingCharacters(in: .whitespaces),
            toBaseFactor: factor,
            sortOrder: existing.count
        )
        modelContext.insert(entry)
        clearUnitFields()
    }

    private func clearUnitFields() {
        newUnitName = ""
        newUnitSymbol = ""
        newUnitFactor = ""
    }

    private func deleteEntries(in groupEntries: [CustomConversionEntry], at indices: IndexSet) {
        for index in indices {
            modelContext.delete(groupEntries[index])
        }
    }

    private func formatFactor(_ factor: Double) -> String {
        factor == Double(Int(factor)) ? String(Int(factor)) : String(format: "%.4g", factor)
    }
}

private struct AddUnitTarget: Identifiable {
    let groupName: String
    var id: String { groupName }
}

#Preview {
    NavigationStack {
        CustomConversionsManageView()
    }
    .modelContainer(for: [CustomConversionEntry.self], inMemory: true)
}
