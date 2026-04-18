import Foundation

// MARK: - LoginViewModel

@Observable
@MainActor
final class LoginViewModel {

    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    weak var coordinator: (any AuthCoordinatorActions)?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    var canSubmit: Bool { !email.isEmpty && !password.isEmpty && !isLoading }

    // MARK: - Actions

    func login() {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                _ = try await authService.login(email: email, password: password)
                coordinator?.loginDidSucceed()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    func requestGoogleSignIn() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let idToken = try await GoogleSignInHelper.signIn()
                _ = try await authService.authenticateWithGoogle(idToken: idToken)
                coordinator?.loginDidSucceed()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    func requestSignUp() {
        coordinator?.loginDidRequestSignUp()
    }

    func requestForgotPassword() {
        coordinator?.loginDidRequestForgotPassword()
    }
}
