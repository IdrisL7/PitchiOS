import StoreKit
import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: SettingsViewModel?
    @State private var usageCount: Int?
    @State private var purchaseService = PurchaseService()
    @State private var showDeleteAccountConfirmation = false

    var body: some View {
        NavigationStack {
            if let vm = viewModel {
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        profileCard(vm)
                        usageCard

                        subscriptionCard(vm)

                        if vm.profile.plan == .team {
                            teamCard(vm.profile)
                        }

                        if !vm.profile.industries.isEmpty {
                            tagSection("Industries", items: vm.profile.industries)
                        }

                        if !vm.profile.differentiators.isEmpty {
                            tagSection("Differentiators", items: vm.profile.differentiators)
                        }

                        appearanceCard
                        legalCard

                        #if DEBUG
                        if !isScreenshotMode {
                            debugSimulatorCard
                        }
                        #endif

                        VStack(spacing: Spacing.sm) {
                            NavigationLink("Edit Profile") {
                                ICPEditView(viewModel: vm)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.pitchAccent.opacity(0.12))
                            .foregroundStyle(Color.pitchAccent)
                            .font(.rounded(.callout, weight: .semibold))
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))

                            Button(role: .destructive) {
                                Task {
                                    try? await vm.signOut()
                                    appState.currentUser = nil
                                    appState.profile = nil
                                }
                            } label: {
                                Text("Sign Out")
                                    .font(.rounded(.callout, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.pitchDanger.opacity(0.12))
                                    .foregroundStyle(Color.pitchDanger)
                                    .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                            }
                        }

                        accountDeletionCard(vm)

                        // Version footer
                        Text("PitchOS \(AppConfig.appVersion) (\(AppConfig.buildNumber))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.sm)
                    .padding(.bottom, 100)
                }
                .navigationTitle("Settings")
            } else {
                ProgressView().tint(Color.pitchAccent)
            }
        }
        .onAppear {
            if viewModel == nil, let profile = appState.profile {
                viewModel = SettingsViewModel(
                    profile: profile,
                    profileService: appState.profileService,
                    authService: appState.authService
                )
                Task {
                    usageCount = try? await appState.usageService.currentUsage(userId: profile.id)
                }
            }
        }
        .alert("Delete Account?", isPresented: $showDeleteAccountConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Account", role: .destructive) {
                guard let vm = viewModel else { return }
                Task {
                    if await vm.deleteAccount() {
                        appState.currentUser = nil
                        appState.profile = nil
                    }
                }
            }
        } message: {
            Text("This permanently deletes your PitchOS account, profile, deals, saved AI outputs, and usage history. This cannot be undone.")
        }
    }

    #if DEBUG
    private var isScreenshotMode: Bool {
        ProcessInfo.processInfo.arguments.contains("--screenshot-settings")
    }
    #else
    private var isScreenshotMode: Bool { false }
    #endif

    private func applyPurchasedPlan(_ plan: UserPlan, to vm: SettingsViewModel) async {
        guard vm.profile.plan != plan else { return }

        do {
            let updatedProfile = try await appState.profileService.updatePlan(userId: vm.profile.id, plan: plan)
            vm.profile = updatedProfile
            appState.profile = updatedProfile
            usageCount = try? await appState.usageService.currentUsage(userId: updatedProfile.id)
        } catch {
            purchaseService.error = "Your purchase completed, but we could not update your account. Please contact support."
        }
    }

    // MARK: - Account Deletion

    private func accountDeletionCard(_ vm: SettingsViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label("Account", systemImage: "person.crop.circle.badge.xmark")
                .font(.rounded(.footnote, weight: .semibold))
                .foregroundStyle(.secondary)

            Text("Permanently delete your account and all PitchOS data.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button(role: .destructive) {
                showDeleteAccountConfirmation = true
            } label: {
                HStack {
                    if vm.isDeletingAccount {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(Color.pitchDanger)
                    } else {
                        Image(systemName: "trash.fill")
                    }
                    Text(vm.isDeletingAccount ? "Deleting Account..." : "Delete Account")
                }
                .font(.rounded(.callout, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.pitchDanger.opacity(0.12))
                .foregroundStyle(Color.pitchDanger)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(vm.isDeletingAccount)

            if let error = vm.error {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(Color.pitchDanger)
            }
        }
        .padding(Spacing.md)
        .glassCard()
    }

    // MARK: - Subscriptions

    private func subscriptionCard(_ vm: SettingsViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Label("Subscription", systemImage: "creditcard.fill")
                    .font(.rounded(.footnote, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if vm.profile.plan.isUnlimited {
                    Label(vm.profile.plan.displayName, systemImage: vm.profile.plan.icon)
                        .font(.rounded(.caption, weight: .semibold))
                        .foregroundStyle(Color.pitchAccent)
                }
            }

            if purchaseService.isLoading {
                ProgressView().tint(Color.pitchAccent)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if purchaseService.offers.isEmpty {
                Text(purchaseService.loadMessage ?? "Subscription options are loading from the App Store.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    Task { await purchaseService.loadProducts(forceReload: true) }
                } label: {
                    Label("Reload Subscriptions", systemImage: "arrow.clockwise")
                        .font(.rounded(.caption, weight: .semibold))
                        .foregroundStyle(Color.pitchAccent)
                }
                .buttonStyle(.plain)
            } else {
                VStack(spacing: Spacing.xs) {
                    ForEach(purchaseService.offers) { offer in
                        Button {
                            Task {
                                do {
                                    if let purchasedPlan = try await purchaseService.purchase(offer) {
                                        await applyPurchasedPlan(purchasedPlan, to: vm)
                                    }
                                } catch {
                                    purchaseService.error = "We could not complete the purchase. Please try again."
                                }
                            }
                        } label: {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: offer.plan.icon)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(offer.displayName)
                                        .font(.rounded(.subheadline, weight: .semibold))
                                    Text("Unlimited AI generations")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(offer.displayPrice)
                                    .font(.rounded(.subheadline, weight: .bold))
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color.pitchAccent.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(purchaseService.isPurchasing)
                    }
                }
            }

            Button {
                Task {
                    do {
                        if let restoredPlan = try await purchaseService.restorePurchases() {
                            await applyPurchasedPlan(restoredPlan, to: vm)
                        }
                    } catch {
                        purchaseService.error = "We could not restore purchases. Please try again."
                    }
                }
            } label: {
                Text("Restore Purchases")
                    .font(.rounded(.caption, weight: .semibold))
                    .foregroundStyle(Color.pitchAccent)
            }
            .disabled(purchaseService.isPurchasing)

            if let error = purchaseService.error {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(Color.pitchDanger)
            }
        }
        .padding(Spacing.md)
        .glassCard()
        .task {
            await purchaseService.loadProducts()
            if let purchasedPlan = purchaseService.purchasedPlan {
                await applyPurchasedPlan(purchasedPlan, to: vm)
            }
        }
    }

    private var subscriptionScreenshotRows: some View {
        VStack(spacing: Spacing.xs) {
            screenshotSubscriptionRow(plan: .solo, title: "Solo Monthly", subtitle: "Unlimited AI generations for one user", price: "Monthly")
            screenshotSubscriptionRow(plan: .pro, title: "Pro Monthly", subtitle: "Advanced AI sales call tools with unlimited generations", price: "Monthly")
        }
    }

    private func screenshotSubscriptionRow(plan: UserPlan, title: String, subtitle: String, price: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: plan.icon)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.rounded(.subheadline, weight: .semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(price)
                .font(.rounded(.subheadline, weight: .bold))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.pitchAccent.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
    }

    // MARK: - Appearance Card

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label("Appearance", systemImage: "paintbrush.fill")
                .font(.rounded(.footnote, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: Spacing.xs) {
                ForEach(ColorSchemePreference.allCases, id: \.self) { pref in
                    Button {
                        appState.setColorSchemePreference(pref)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: pref.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(pref.displayName)
                                .font(.rounded(.subheadline, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            appState.colorSchemePreference == pref
                                ? Color.pitchAccent.opacity(0.18)
                                : Color.clear
                        )
                        .foregroundStyle(
                            appState.colorSchemePreference == pref
                                ? Color.pitchAccent
                                : Color.secondary
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                                .stroke(
                                    appState.colorSchemePreference == pref
                                        ? Color.pitchAccent.opacity(0.4)
                                        : Color.clear,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.2), value: appState.colorSchemePreference)
                }
            }
        }
        .padding(Spacing.md)
        .glassCard()
    }

    // MARK: - Legal Card

    private var legalCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label("Legal", systemImage: "doc.text.fill")
                .font(.rounded(.footnote, weight: .semibold))
                .foregroundStyle(.secondary)

            Link(destination: URL(string: AppConfig.termsOfUseURL)!) {
                legalRow("Terms of Use", systemImage: "doc.plaintext")
            }

            Link(destination: URL(string: AppConfig.privacyPolicyURL)!) {
                legalRow("Privacy Policy", systemImage: "lock.shield")
            }
        }
        .padding(Spacing.md)
        .glassCard()
    }

    private func legalRow(_ title: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .font(.rounded(.callout, weight: .semibold))
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.primary.opacity(0.05))
        .foregroundStyle(Color.pitchAccent)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
    }

    // MARK: - Usage Card

    private var usageCard: some View {
        let plan = appState.profile?.plan ?? .free
        let used = usageCount ?? 0
        let isUnlimited = plan.isUnlimited
        let limit = AppConfig.freeGenerationsPerMonth
        let fraction = isUnlimited ? 1.0 : min(Double(used) / Double(limit), 1.0)
        let isNearLimit = !isUnlimited && fraction >= 0.8

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Label("Monthly Generations", systemImage: "sparkles")
                    .font(.rounded(.footnote, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if usageCount == nil && !isUnlimited {
                    ProgressView().scaleEffect(0.7).tint(Color.pitchAccent)
                } else if isUnlimited {
                    HStack(spacing: 4) {
                        if plan == .team {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Color.pitchSuccess)
                        }
                        Text(plan == .team ? "Team · Unlimited" : "Unlimited")
                            .font(.rounded(.caption, weight: .semibold))
                            .foregroundStyle(plan == .team ? Color.pitchSuccess : Color.pitchAccent)
                    }
                } else {
                    Text("\(used) / \(limit)")
                        .font(.rounded(.caption, weight: .semibold))
                        .foregroundStyle(isNearLimit ? Color.pitchWarning : Color.pitchAccent)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: plan == .team
                                    ? [Color.pitchSuccess, Color(red: 0.10, green: 0.70, blue: 0.45)]
                                    : isUnlimited
                                        ? [Color.pitchAccent, Color.pitchPurple]
                                        : isNearLimit
                                            ? [Color.pitchWarning, Color.pitchDanger]
                                            : [Color.pitchAccent, Color.pitchPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * fraction, height: 6)
                        .animation(.easeOut(duration: 0.6), value: fraction)
                }
            }
            .frame(height: 6)

            if isNearLimit && usageCount != nil {
                Text(fraction >= 1.0 ? "Limit reached — upgrade to Pro." : "Approaching monthly limit.")
                    .font(.caption2)
                    .foregroundStyle(Color.pitchWarning)
            }
        }
        .padding(Spacing.md)
        .glassCard()
    }

    // MARK: - Debug Simulator Card

    #if DEBUG
    private var debugSimulatorCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label("Simulator", systemImage: "hammer.fill")
                .font(.rounded(.footnote, weight: .semibold))
                .foregroundStyle(Color.pitchWarning)

            HStack(spacing: Spacing.xs) {
                ForEach(UserPlan.allCases, id: \.self) { plan in
                    Button {
                        appState.simulatePlan(plan)
                        usageCount = nil  // Refresh usage display
                        if let id = appState.profile?.id {
                            Task { usageCount = try? await appState.usageService.currentUsage(userId: id) }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: plan.icon)
                                .font(.system(size: 11, weight: .bold))
                            Text(plan.displayName)
                                .font(.rounded(.subheadline, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            appState.profile?.plan == plan
                                ? Color.pitchWarning.opacity(0.18)
                                : Color.clear
                        )
                        .foregroundStyle(
                            appState.profile?.plan == plan
                                ? Color.pitchWarning
                                : Color.secondary
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                                .stroke(
                                    appState.profile?.plan == plan
                                        ? Color.pitchWarning.opacity(0.4)
                                        : Color.clear,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.2), value: appState.profile?.plan)
                }
            }

            Text("In-memory only — resets on next app launch")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(Spacing.md)
        .glassCard()
    }
    #endif

    // MARK: - Plan Badge

    @ViewBuilder
    private func planBadge(_ plan: UserPlan) -> some View {
        if !plan.badgeColors.isEmpty {
            Label(plan.displayName, systemImage: plan.icon)
                .font(.rounded(.caption2, weight: .bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    LinearGradient(
                        colors: plan.badgeColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
        }
    }

    // MARK: - Team Card

    private func teamCard(_ profile: Profile) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                Label(profile.teamName ?? "My Team", systemImage: "person.3.fill")
                    .font(.rounded(.subheadline, weight: .bold))
                    .foregroundStyle(Color.pitchSuccess)
                Spacer()
                if profile.teamIsAdmin {
                    Label("Admin", systemImage: "shield.checkered")
                        .font(.rounded(.caption2, weight: .semibold))
                        .foregroundStyle(Color.pitchSuccess)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.pitchSuccess.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            Divider().opacity(0.3)

            // Seats
            if let total = profile.teamSeatCount, let used = profile.teamSeatUsed {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text("Seats")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(used) / \(total) active")
                            .font(.rounded(.caption, weight: .semibold))
                            .foregroundStyle(Color.pitchSuccess)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                                .fill(Color.primary.opacity(0.08))
                                .frame(height: 5)
                            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.pitchSuccess, Color(red: 0.10, green: 0.70, blue: 0.45)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * min(Double(used) / Double(total), 1.0), height: 5)
                                .animation(.easeOut(duration: 0.6), value: used)
                        }
                    }
                    .frame(height: 5)
                }
            }

            // Simulated member roster
            VStack(spacing: Spacing.xs) {
                teamMemberRow(name: "Sarah Chen",    role: "Solutions Engineer", isYou: true)
                teamMemberRow(name: "Marcus Webb",   role: "Account Executive",  isYou: false)
                teamMemberRow(name: "Priya Sharma",  role: "Sales Engineer",     isYou: false)
                teamMemberRow(name: "Jordan Ellis",  role: "Account Executive",  isYou: false)

                HStack {
                    Spacer()
                    Text("+ \((profile.teamSeatUsed ?? 4) - 4) more members")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            // Invite button
            Button {
                // Placeholder — invite flow goes here
            } label: {
                Label("Invite Team Member", systemImage: "person.badge.plus")
                    .font(.rounded(.callout, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.pitchSuccess.opacity(0.12))
                    .foregroundStyle(Color.pitchSuccess)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.md)
        .glassCard()
    }

    private func teamMemberRow(name: String, role: String, isYou: Bool) -> some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.pitchSuccess.opacity(0.15))
                Text(String(name.prefix(1)))
                    .font(.rounded(.caption, weight: .bold))
                    .foregroundStyle(Color.pitchSuccess)
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(name)
                        .font(.rounded(.subheadline, weight: .medium))
                    if isYou {
                        Text("you")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.primary.opacity(0.06))
                            .clipShape(Capsule())
                    }
                }
                Text(role)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Circle()
                .fill(Color.pitchSuccess)
                .frame(width: 6, height: 6)
        }
    }

    // MARK: - Profile Card

    private func profileCard(_ vm: SettingsViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color.pitchAccent.opacity(0.3), Color.pitchPurple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    Text(String(vm.profile.name.prefix(1)).uppercased())
                        .font(.rounded(.title2, weight: .bold))
                        .foregroundStyle(Color.pitchAccent)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: Spacing.xs) {
                        Text(vm.profile.name)
                            .font(.rounded(.title3, weight: .bold))
                        if vm.profile.plan != .free {
                            planBadge(vm.profile.plan)
                        }
                    }
                    Text(vm.profile.role)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Divider().opacity(0.3)

            VStack(spacing: Spacing.sm) {
                profileRow("Product", value: vm.profile.product)
                profileRow("Methodology", value: vm.profile.methodology)
            }
        }
        .padding(Spacing.md)
        .glassCard()
    }

    private func profileRow(_ label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Tag Section

    private func tagSection(_ title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.rounded(.footnote, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            FlowLayout(spacing: Spacing.xs) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.rounded(.caption, weight: .medium))
                        .foregroundStyle(Color.pitchAccent)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Color.pitchAccent.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(Spacing.md)
        .glassCard()
    }
}
