import Swinject

// MARK: - Auth Assembly
//
// Registers ViewModels used in the Auth flow.
// Each ViewModel is transient — a fresh instance is created per screen presentation.

final class AuthAssembly: Assembly {

    func assemble(container: Container) {
        container.register(LoginViewModel.self) { r in
            let authService = r.resolve(AuthServiceProtocol.self) ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
            return LoginViewModel(authService: authService)
        }.inObjectScope(.transient)

        container.register(SignUpViewModel.self) { r in
            let authService = r.resolve(AuthServiceProtocol.self) ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
            return SignUpViewModel(authService: authService)
        }.inObjectScope(.transient)

        container.register(ForgotPasswordViewModel.self) { r in
            let authService = r.resolve(AuthServiceProtocol.self) ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
            return ForgotPasswordViewModel(authService: authService)
        }.inObjectScope(.transient)
    }
}
