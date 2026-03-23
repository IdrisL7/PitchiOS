import SwiftUI

struct SignUpView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AuthViewModel?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.title.bold())

                Text("Start your free trial — 50 AI generations per month")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let vm = viewModel {
                VStack(spacing: 16) {
                    TextField("Email", text: Bindable(vm).email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    SecureField("Password (8+ characters)", text: Bindable(vm).password)
                        .textContentType(.newPassword)
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
                        if await vm.signUp() {
                            await appState.loadSession()
                        }
                    }
                } label: {
                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
                .disabled(vm.isLoading)
            }

            Spacer()
        }
        .navigationBarBackButtonHidden(false)
        .onAppear {
            if viewModel == nil {
                viewModel = AuthViewModel(authService: appState.authService)
            }
        }
    }
}
