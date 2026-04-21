import Foundation

// MARK: - ForgotPasswordViewModel

@Observable
@MainActor
final class ForgotPasswordViewModel {

    var email: String = ""
    var isLoading: Bool = false
    var emailError: String?
    var successMessage: String?

    weak var coordinator: (any AuthCoordinatorProtocol)?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Actions

    func sendResetLink() {
        guard !email.isEmpty else {
            emailError = "Please enter your email address."
            return
        }
        isLoading = true
        emailError = nil
        Task {
            do {
                // The backend stubs this endpoint — we show a success message regardless.
                _ = try? await authService.logout() // placeholder until /auth/reset is added
                successMessage = "If this email is registered, you will receive a reset link shortly."
                isLoading = false
            }
        }
    }

    func goBack() {
        coordinator?.forgotPasswordDidFinish()
    }
}
