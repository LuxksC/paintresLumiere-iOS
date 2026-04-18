import Foundation

// MARK: - SignUpViewModel

@Observable
@MainActor
final class SignUpViewModel {

    var name: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var phone: String = ""
    var cpf: String = ""
    var cnpj: String = ""
    var isLoading: Bool = false

    var nameError: String?
    var emailError: String?
    var passwordError: String?
    var confirmPasswordError: String?
    var generalError: String?

    weak var coordinator: (any AuthCoordinatorActions)?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    var passwordsMatch: Bool { password == confirmPassword || confirmPassword.isEmpty }

    var canSubmit: Bool {
        name.count >= 2 && email.contains("@") && password.count >= 8 &&
        (confirmPassword.isEmpty || passwordsMatch) && !isLoading
    }

    // MARK: - Actions

    func createAccount() {
        guard validate() else { return }
        isLoading = true
        clearErrors()
        Task {
            do {
                _ = try await authService.signUp(
                    name: name,
                    email: email,
                    password: password,
                    phone: phone.isEmpty ? nil : phone,
                    cpf: cpf.isEmpty ? nil : cpf,
                    cnpj: cnpj.isEmpty ? nil : cnpj
                )
                coordinator?.signUpDidSucceed()
            } catch let error as APIError {
                isLoading = false
                switch error {
                case .conflict(let message): emailError = message
                default: generalError = error.localizedDescription
                }
            } catch {
                isLoading = false
                generalError = error.localizedDescription
            }
        }
    }

    func requestSignIn() {
        coordinator?.signUpDidRequestLogin()
    }

    // MARK: - Validation

    @discardableResult
    func validate() -> Bool {
        nameError            = name.count < 2        ? "Name must be at least 2 characters."      : nil
        emailError           = !email.contains("@")  ? "Please enter a valid email address."      : nil
        passwordError        = password.count < 8    ? "Password must be at least 8 characters."  : nil
        confirmPasswordError = !passwordsMatch       ? "Passwords do not match."                   : nil
        return nameError == nil && emailError == nil && passwordError == nil && confirmPasswordError == nil
    }

    private func clearErrors() {
        nameError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        generalError = nil
    }
}
