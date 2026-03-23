import SwiftUI

struct DealDetailView: View {
    let deal: Deal
    @Environment(AppState.self) private var appState
    @State private var viewModel: DealDetailViewModel?

    private var activeDeal: Deal { viewModel?.deal ?? deal }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                // Prospect info card
                prospectCard

                // Action grid
                actionGrid

                // Notes card (if any)
                if let notes = activeDeal.notes, !notes.isEmpty {
                    notesCard(notes)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
            .padding(.bottom, 100)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(activeDeal.companyName)
                        .font(.rounded(.callout, weight: .semibold))
                    StageBadge(stage: activeDeal.stage, outcome: activeDeal.outcome)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel?.openEdit()
                } label: {
                    Image(systemName: "pencil.circle")
                        .foregroundStyle(Color.pitchAccent)
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.showEditSheet ?? false },
            set: { viewModel?.showEditSheet = $0 }
        )) {
            if let vm = viewModel {
                DealEditSheet(viewModel: vm)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = DealDetailViewModel(
                    deal: deal,
                    dealService: appState.dealService
                )
            }
        }
    }

    // MARK: - Prospect Card

    private var prospectCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                // Company initial
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.pitchAccent.opacity(0.25), Color.pitchPurple.opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text(String(activeDeal.companyName.prefix(1)).uppercased())
                        .font(.rounded(.title2, weight: .bold))
                        .foregroundStyle(Color.pitchAccent)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(activeDeal.companyName)
                        .font(.rounded(.title3, weight: .bold))
                    if !activeDeal.contactName.isEmpty {
                        Text("\(activeDeal.contactName)\(!activeDeal.contactRole.isEmpty ? " · \(activeDeal.contactRole)" : "")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            Divider().opacity(0.3)

            HStack {
                Label("Stage", systemImage: "flag.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                StageBadge(stage: activeDeal.stage, outcome: activeDeal.outcome)
            }
        }
        .padding(Spacing.md)
        .glassCard()
    }

    // MARK: - Action Grid

    private var actionGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
            NavigationLink {
                MeetingBriefView(deal: activeDeal)
            } label: {
                ActionCard(
                    title: "Meeting Brief",
                    subtitle: "Pre-call prospect snapshot",
                    icon: "doc.badge.gearshape.fill",
                    gradient: [Color.pitchSuccess, Color(red: 0.10, green: 0.70, blue: 0.45)]
                ) {}
            }
            .buttonStyle(.plain)

            NavigationLink {
                DiscoveryQuestionsView(deal: activeDeal)
            } label: {
                ActionCard(
                    title: "Discovery Qs",
                    subtitle: "15 tailored questions",
                    icon: "questionmark.bubble.fill",
                    gradient: [Color.pitchAccent, Color.pitchPurple]
                ) {}
            }
            .buttonStyle(.plain)

            NavigationLink {
                ObjectionHandlerView(deal: activeDeal)
            } label: {
                ActionCard(
                    title: "Objection Handler",
                    subtitle: "Counter objections live",
                    icon: "bolt.fill",
                    gradient: [Color.pitchWarning, Color(red: 1.0, green: 0.5, blue: 0.1)]
                ) {}
            }
            .buttonStyle(.plain)

            NavigationLink {
                PostCallView(deal: activeDeal)
            } label: {
                ActionCard(
                    title: "Post-Call Summary",
                    subtitle: "Notes, summary & email",
                    icon: "doc.text.fill",
                    gradient: [Color.pitchPurple, Color(red: 0.75, green: 0.30, blue: 0.90)]
                ) {}
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Notes Card

    @ViewBuilder
    private func notesCard(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label("Notes", systemImage: "note.text")
                .font(.rounded(.subheadline, weight: .semibold))
                .foregroundStyle(.secondary)

            Divider().opacity(0.3)

            Text(notes)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding(Spacing.md)
        .glassCard()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DealDetailView(deal: PreviewData.deal)
    }
    .appBackground()
}
