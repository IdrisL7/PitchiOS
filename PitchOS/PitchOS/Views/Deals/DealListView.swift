import SwiftUI

struct DealListView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: DealListViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    if vm.deals.isEmpty && !vm.isLoading {
                        emptyState(vm)
                    } else {
                        dealList(vm)
                    }
                } else {
                    ProgressView()
                        .tint(Color.pitchAccent)
                }
            }
            .navigationTitle("Deals")
            .navigationDestination(for: Deal.self) { deal in
                DealDetailView(deal: deal)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel?.showNewDealSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.pitchAccent)
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel?.showNewDealSheet ?? false },
                set: { viewModel?.showNewDealSheet = $0 }
            )) {
                if let vm = viewModel {
                    NewDealSheet(viewModel: vm)
                }
            }
        }
        .onAppear {
            if viewModel == nil, let userId = appState.currentUserId {
                let vm = DealListViewModel(dealService: appState.dealService, userId: userId)
                viewModel = vm
                Task { await vm.loadDeals() }
            }
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private func emptyState(_ vm: DealListViewModel) -> some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "briefcase.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.pitchAccent.opacity(0.5))
            Text("No Deals Yet")
                .font(.rounded(.title2, weight: .bold))
            Text("Add your first prospect to get started.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Add Deal") { vm.showNewDealSheet = true }
                .buttonStyle(.borderedProminent)
                .tint(Color.pitchAccent)
            Spacer()
        }
        .padding()
    }

    // MARK: - Deal List

    @ViewBuilder
    private func dealList(_ vm: DealListViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: Spacing.sm) {
                ForEach(vm.deals) { deal in
                    NavigationLink(value: deal) {
                        DealRow(deal: deal)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)
            .padding(.bottom, 100) // clearance for floating tab bar
        }
        .refreshable { await vm.loadDeals() }
    }
}

// MARK: - Deal Row

struct DealRow: View {
    let deal: Deal

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Company initial badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.pitchAccent.opacity(0.3), Color.pitchPurple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text(String(deal.companyName.prefix(1)).uppercased())
                    .font(.rounded(.headline, weight: .bold))
                    .foregroundStyle(Color.pitchAccent)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(deal.companyName)
                    .font(.rounded(.callout, weight: .semibold))
                    .foregroundStyle(.primary)

                if !deal.contactName.isEmpty {
                    Text("\(deal.contactName)\(!deal.contactRole.isEmpty ? " · \(deal.contactRole)" : "")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            StageBadge(stage: deal.stage, outcome: deal.outcome)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm + 2)
        .glassCard()
    }
}

// MARK: - Preview

#Preview {
    DealListView()
        .environment(AppState.preview)
        .appBackground()
}
