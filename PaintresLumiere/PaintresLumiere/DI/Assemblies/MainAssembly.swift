import Swinject

// MARK: - Main Assembly
//
// Registers ViewModels used in the main (logged-in) tab flow.
// ProfileViewModel is transient — recreated each time the tab is shown.

final class MainAssembly: Assembly {

    func assemble(container: Container) {
        container.register(ProfileViewModel.self) { r in
            let authService = r.resolve(AuthServiceProtocol.self) ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
            return ProfileViewModel(authService: authService)
        }.inObjectScope(.transient)
    }
}
