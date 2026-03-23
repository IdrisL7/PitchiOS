import SwiftUI

struct OnboardingContainerView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: OnboardingViewModel?

    var body: some View {
        NavigationStack {
            if let vm = viewModel {
                VStack(spacing: 0) {
                    // Progress bar
                    VStack(spacing: 4) {
                        ProgressView(value: Double(vm.currentStep), total: Double(OnboardingViewModel.totalSteps))
                            .tint(Color.pitchAccent)
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.sm)

                        Text("Step \(vm.currentStep) of \(OnboardingViewModel.totalSteps)")
                            .font(.rounded(.caption, weight: .medium))
                            .foregroundStyle(.secondary)
                    }

                    // Step content
                    TabView(selection: Bindable(vm).currentStep) {
                        OnboardingNameRoleView(viewModel: vm).tag(1)
                        OnboardingProductView(viewModel: vm).tag(2)
                        OnboardingBuyersView(viewModel: vm).tag(3)
                        OnboardingMethodologyView(viewModel: vm).tag(4)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: vm.currentStep)

                    // Navigation buttons
                    HStack {
                        if vm.currentStep > 1 {
                            Button("Back") { vm.back() }
                                .buttonStyle(.bordered)
                                .tint(Color.pitchAccent)
                        }

                        Spacer()

                        if vm.currentStep < OnboardingViewModel.totalSteps {
                            Button("Next") { vm.next() }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.pitchAccent)
                                .disabled(!vm.canAdvance)
                        } else {
                            Button {
                                Task {
                                    if let profile = await vm.saveProfile() {
                                        appState.profile = profile
                                    }
                                }
                            } label: {
                                if vm.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Get Started")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.pitchAccent)
                            .disabled(!vm.canAdvance || vm.isLoading)
                        }
                    }
                    .padding(Spacing.md)
                }
                .navigationTitle("Set Up Your Profile")
                .navigationBarTitleDisplayMode(.inline)
                .alert("Error", isPresented: .constant(vm.error != nil)) {
                    Button("OK") { vm.error = nil }
                } message: {
                    Text(vm.error ?? "")
                }
            } else {
                ProgressView().tint(Color.pitchAccent)
            }
        }
        .appBackground()
        .onAppear {
            if viewModel == nil, let userId = appState.currentUserId {
                viewModel = OnboardingViewModel(
                    profileService: appState.profileService,
                    userId: userId
                )
            }
        }
    }
}
