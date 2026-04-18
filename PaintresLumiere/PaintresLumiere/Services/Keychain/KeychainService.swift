import Foundation
import Security

// MARK: - Keychain Service (JWT token persistence)
//
// `shared` is kept so APIEndpoint can read the token without going through DI.
// The Swinject container is configured to register this same instance,
// ensuring a single source of truth across the app.

final class KeychainService {

    static let shared = KeychainService()

    private let service = "com.paintresLumiere.app"
    private let accessTokenKey = "accessToken"

    init() {}

    // MARK: - Access Token

    var accessToken: String? {
        get { read(key: accessTokenKey) }
        set {
            if let value = newValue {
                save(value, key: accessTokenKey)
            } else {
                delete(key: accessTokenKey)
            }
        }
    }

    var isAuthenticated: Bool { accessToken != nil }

    // MARK: - Private helpers

    private func save(_ value: String, key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key
        ]
        var attrs: [CFString: Any] = query
        attrs[kSecValueData] = data

        let status = SecItemAdd(attrs as CFDictionary, nil)
        if status == errSecDuplicateItem {
            SecItemUpdate(query as CFDictionary,
                          [kSecValueData: data] as CFDictionary)
        }
    }

    private func read(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass:        kSecClassGenericPassword,
            kSecAttrService:  service,
            kSecAttrAccount:  key,
            kSecReturnData:   true,
            kSecMatchLimit:   kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8)
        else { return nil }
        return value
    }

    private func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    func clearAll() {
        delete(key: accessTokenKey)
    }
}
