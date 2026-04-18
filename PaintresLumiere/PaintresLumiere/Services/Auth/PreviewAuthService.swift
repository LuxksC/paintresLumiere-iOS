import Foundation

// MARK: - Preview Auth Service
//
// Stub implementation of AuthServiceProtocol used exclusively in Xcode Previews.
// Never instantiated in production code.

final class PreviewAuthService: AuthServiceProtocol {
    func login(email: String, password: String) async throws -> String { "preview-token" }
    func signUp(name: String, email: String, password: String,
                phone: String?, cpf: String?, cnpj: String?) async throws -> String { "preview-token" }
    func authenticateWithGoogle(idToken: String) async throws -> String { "preview-token" }
    func authenticateWithApple(identityToken: String, email: String?, fullName: String?) async throws -> String { "preview-token" }
    func logout() async throws {}
    func deleteAccount() async throws {}
}
