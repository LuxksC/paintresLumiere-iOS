import Foundation

// MARK: - APIClient Protocol

protocol APIClientProtocol: AnyObject, Sendable {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

// MARK: - APIClient

final class APIClient: APIClientProtocol, Sendable {
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = NetworkConfig.timeoutInterval
        session = URLSession(configuration: config)
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let urlRequest = try endpoint.urlRequest()
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200 ... 299:
            do {
                return try JsonHelper.decode(data)
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            throw APIError.unauthorized
        case 409:
            let body = try? JsonHelper.decode(data, as: APIErrorBody.self)
            throw APIError.conflict(body?.error ?? "Conflict.")
        default:
            let body = try? JsonHelper.decode(data, as: APIErrorBody.self)
            throw APIError.httpError(statusCode: httpResponse.statusCode,
                                     message: body?.error ?? "Request failed.")
        }
    }
}

// MARK: - Error body

private struct APIErrorBody: Decodable {
    let error: String?
    let errors: [String: [String]]?
}
