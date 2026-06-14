import Foundation

// MARK: - API Endpoints (matches serverless.yml)

enum APIEndpoint {
    case login(email: String, password: String)
    case signup(request: SignUpRequest)
    case authGoogle(idToken: String)
    case authApple(identityToken: String, email: String?, fullName: String?)
    case logout
    case deleteAccount
    case getProducts
    case getPopularProducts(limit: Int?)
    case getProductBySku(sku: String)

    var path: String {
        switch self {
        case .login:                 return "/login"
        case .signup:                return "/signup"
        case .authGoogle:            return "/auth/google"
        case .authApple:             return "/auth/apple"
        case .logout:                return "/logout"
        case .deleteAccount:         return "/users/me"
        case .getProducts:           return "/products"
        case .getPopularProducts:    return "/products/popular"
        case .getProductBySku(let sku): return "/products/sku/\(sku)"
        }
    }

    var method: String {
        switch self {
        case .deleteAccount:
            return "DELETE"
        case .getProducts, .getPopularProducts, .getProductBySku:
            return "GET"
        default:
            return "POST"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .getPopularProducts(let limit?):
            return [URLQueryItem(name: "limit", value: String(limit))]
        default:
            return nil
        }
    }

    func urlRequest() throws -> URLRequest {
        let baseURL = NetworkConfig.baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidResponse
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainService.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        switch self {
        case .login(let email, let password):
            request.httpBody = try JSONEncoder().encode(["email": email, "password": password])

        case .signup(let req):
            request.httpBody = try JSONEncoder().encode(req)

        case .authGoogle(let idToken):
            request.httpBody = try JSONEncoder().encode(["idToken": idToken])

        case .authApple(let token, let email, let name):
            var body: [String: String] = ["identityToken": token]
            if let email { body["email"] = email }
            if let name  { body["fullName"] = name }
            request.httpBody = try JSONEncoder().encode(body)

        case .logout, .deleteAccount,
             .getProducts, .getPopularProducts, .getProductBySku:
            break
        }

        return request
    }
}

// MARK: - DTOs

struct SignUpRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let phone: String?
    let cpf: String?
    let cnpj: String?
}

struct AuthResponse: Decodable {
    let accessToken: String
}

struct EmptyResponse: Decodable {}
