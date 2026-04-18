import Swinject

// MARK: - Services Assembly
//
// Registers app-level services: Keychain and Auth.
// Both are scoped as container singletons — one instance for the entire app session.

final class ServicesAssembly: Assembly {

    func assemble(container: Container) {
        container.register(KeychainService.self) { _ in
            // Reuse the shared instance so that APIEndpoint (which calls
            // KeychainService.shared directly) and injected callers always
            // reference the same object.
            KeychainService.shared
        }.inObjectScope(.container)

        container.register(AuthServiceProtocol.self) { r in
            let apiClient = r.resolve(APIClientProtocol.self) ?? APIClient()
            let keychain = r.resolve(KeychainService.self) ?? KeychainService.shared
            return AuthService(apiClient: apiClient, keychain: keychain)
        }.inObjectScope(.container)
    }
}
