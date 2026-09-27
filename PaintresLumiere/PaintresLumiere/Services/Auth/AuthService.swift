import Foundation

final class AuthService: AuthServiceProtocol, Sendable {
    private let client: APIClientProtocol
    private let keychain: KeychainService

    init(apiClient: APIClientProtocol, keychain: KeychainService) {
        client = apiClient
        self.keychain = keychain
    }

    func login(email: String, password: String) async throws -> String {
        let response: AuthResponse = try await client.request(.login(email: email, password: password))
        keychain.accessToken = response.accessToken
        return response.accessToken
    }

    func signUp(name: String, email: String, password: String,
                phone: String?, cpf: String?, cnpj: String?) async throws -> String
    {
        let req = SignUpRequest(name: name, email: email, password: password,
                                phone: phone?.isEmpty == false ? phone : nil,
                                cpf: cpf?.isEmpty == false ? cpf : nil,
                                cnpj: cnpj?.isEmpty == false ? cnpj : nil)
        let response: AuthResponse = try await client.request(.signup(request: req))
        keychain.accessToken = response.accessToken
        return response.accessToken
    }

    func authenticateWithGoogle(idToken: String) async throws -> String {
        let response: AuthResponse = try await client.request(.authGoogle(idToken: idToken))
        keychain.accessToken = response.accessToken
        return response.accessToken
    }

    func authenticateWithApple(identityToken: String, email: String?, fullName: String?) async throws -> String {
        let response: AuthResponse = try await client.request(
            .authApple(identityToken: identityToken, email: email, fullName: fullName)
        )
        keychain.accessToken = response.accessToken
        return response.accessToken
    }

    func logout() async throws {
        _ = try? await client.request(.logout) as EmptyResponse
        keychain.clearAll()
    }

    func deleteAccount() async throws {
        _ = try await client.request(.deleteAccount) as EmptyResponse
        keychain.clearAll()
    }
}
