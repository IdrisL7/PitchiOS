import SwiftUI

// MARK: - Methodology Picker Section

struct MethodologyPickerSection: View {
    @Binding var methodology: String

    private var selectedMethodology: SalesMethodology {
        SalesMethodology(rawValue: methodology) ?? .meddic
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Sales approach")
                .font(.rounded(.footnote, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: Spacing.sm
            ) {
                ForEach(SalesMethodology.allCases) { method in
                    MethodologyTile(
                        method: method,
                        isSelected: method.rawValue == methodology
                    ) {
                        methodology = method.rawValue
                        HapticService.shared.selectionChanged()
                    }
                }
            }
        }
        .padding(Spacing.md)
        .glassCard()
    }
}

// MARK: - Methodology Tile

struct MethodologyTile: View {
    let method: SalesMethodology
    let isSelected: Bool
    let onTap: () -> Void

    @State private var showDetail = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(method.displayName)
                        .font(.rounded(.subheadline, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : .primary)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }

                Text(method.bestFor)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.85) : .secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(method.accentColor)
                } else {
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                                .strokeBorder(method.accentColor.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .onLongPressGesture { showDetail = true }
        .sheet(isPresented: $showDetail) {
            MethodologyDetailSheet(method: method, onSelect: {
                onTap()
                showDetail = false
            })
        }
    }
}

// MARK: - Methodology Detail Sheet

struct MethodologyDetailSheet: View {
    let method: SalesMethodology
    let onSelect: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {

                    // Header badge
                    HStack {
                        Text(method.displayName)
                            .font(.rounded(.title2, weight: .bold))
                            .foregroundStyle(method.accentColor)
                        Spacer()
                    }

                    // Description
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("What it is")
                            .font(.rounded(.footnote, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.8)
                        Text(method.description)
                            .font(.body)
                    }

                    // Best for
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Best for")
                            .font(.rounded(.footnote, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.8)
                        Text(method.bestFor)
                            .font(.body)
                    }

                    // How AI uses it
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("How PitchOS applies it")
                            .font(.rounded(.footnote, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.8)
                        Text(method.promptGuidance)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        onSelect()
                    } label: {
                        Label("Use \(method.displayName)", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.sm)
                            .background(method.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                    }
                }
                .padding(Spacing.lg)
            }
            .navigationTitle("Methodology")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
