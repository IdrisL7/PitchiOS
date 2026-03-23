import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: AuthViewModel?
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Logo
                VStack(spacing: 8) {
                    Image(systemName: "bolt.shield.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.pitchAccent)

                    Text("PitchOS")
                        .font(.rounded(.largeTitle, weight: .bold))

                    Text("AI copilot for enterprise pre-sales")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Form
                if let vm = viewModel {
                    VStack(spacing: 16) {
                        TextField("Email", text: Bindable(vm).email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)

                        SecureField("Password", text: Bindable(vm).password)
                            .textContentType(.password)
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                    if let error = vm.error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }

                    Button {
                        Task {
                            if await vm.signIn() {
                                await appState.loadSession()
                            }
                        }
                    } label: {
                        if vm.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal)
                    .disabled(vm.isLoading)

                    Button("Create an account") {
                        showSignUp = true
                    }
                    .font(.subheadline)

                    #if DEBUG
                    Button("⚡ Dev Login") {
                        Task {
                            vm.email = "test@pitchos.dev"
                            vm.password = "PitchOS123x"
                            if await vm.signIn() {
                                await appState.loadSession()
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    #endif
                }

                Spacer()
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
        .appBackground()
        .onAppear {
            if viewModel == nil {
                viewModel = AuthViewModel(authService: appState.authService)
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AppState.preview)
}
