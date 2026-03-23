import SwiftUI

// MARK: - Vertical Quick-Start Section

struct VerticalQuickStartSection: View {
    @Bindable var viewModel: SettingsViewModel
    @State private var selectedPreview: SalesVertical?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {

            VStack(alignment: .leading, spacing: 3) {
                Text("Vertical Quick-Start")
                    .font(.rounded(.footnote, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Text("Pick your niche — buyer titles, pains, and discovery questions pre-fill automatically.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: Spacing.sm), GridItem(.flexible(), spacing: Spacing.sm)],
                spacing: Spacing.sm
            ) {
                ForEach(SalesVertical.allCases) { vertical in
                    VerticalTile(
                        vertical: vertical,
                        isSelected: viewModel.profile.vertical == vertical.rawValue
                    ) {
                        selectedPreview = vertical
                    }
                }
            }
        }
        .padding(Spacing.md)
        .glassCard()
        .sheet(item: $selectedPreview) { vertical in
            VerticalPreviewSheet(vertical: vertical) {
                applyTemplate(for: vertical)
            }
        }
    }

    private func applyTemplate(for vertical: SalesVertical) {
        let template = VerticalTemplates.template(for: vertical)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            viewModel.profile.vertical      = vertical.rawValue
            viewModel.profile.buyerTitles   = template.buyerTitles
            viewModel.profile.industries    = template.industries
            viewModel.profile.methodology   = template.methodology
            if viewModel.profile.differentiators.isEmpty {
                viewModel.profile.differentiators = template.differentiators
            }
        }
    }
}

// MARK: - Vertical Tile

struct VerticalTile: View {
    let vertical: SalesVertical
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                Text(vertical.emoji)
                    .font(.system(size: 18))

                VStack(alignment: .leading, spacing: 2) {
                    Text(vertical.rawValue)
                        .font(.rounded(.caption, weight: .medium))
                        .foregroundStyle(isSelected ? Color.pitchAccent : .primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.pitchAccent)
                }
            }
            .padding(Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(isSelected ? Color.pitchAccent.opacity(0.10) : Color.primary.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                            .stroke(
                                isSelected ? Color.pitchAccent.opacity(0.4) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: isSelected ? Color.pitchAccent.opacity(0.10) : .clear, radius: 8)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - Vertical Preview Sheet

struct VerticalPreviewSheet: View {
    let vertical: SalesVertical
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    private var template: VerticalTemplate {
        VerticalTemplates.template(for: vertical)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {

                    // Header
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("\(vertical.emoji)  \(vertical.rawValue)")
                            .font(.rounded(.title2, weight: .bold))
                        Text("Here's what will be pre-filled in your ICP. Your product name, description, and any existing differentiators won't be overwritten.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    previewSection("Buyer Titles", items: template.buyerTitles)
                    previewSection("Top Pain Points", items: template.topPains)
                    previewSection("Pinned Discovery Questions", items: Array(template.discoveryQuestions.prefix(4)))

                    // ROI hook
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("ROI Hook")
                            .font(.rounded(.caption2, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.8)
                        Text(template.roiHook)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(Spacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.pitchAccent.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                    }

                    // Methodology note
                    Label("Default methodology for this vertical: \(template.methodology)", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.primary.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                }
                .padding(Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply Template") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.pitchAccent)
                }
            }
        }
    }

    @ViewBuilder
    private func previewSection(_ title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.rounded(.caption2, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: Spacing.xs) {
                        Circle()
                            .fill(Color.pitchAccent.opacity(0.5))
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)
                        Text(item)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
