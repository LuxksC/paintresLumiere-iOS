import Foundation

// MARK: - API Error types

enum APIError: LocalizedError {
    case invalidURL
    case network(Error)
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case unauthorized
    case conflict(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:                    return "Invalid request URL."
        case .network(let e):                return e.localizedDescription
        case .invalidResponse:               return "Invalid server response."
        case .httpError(_, let msg):         return msg
        case .decodingError:                 return "Failed to parse server response."
        case .unauthorized:                  return "Invalid credentials."
        case .conflict(let msg):             return msg
        case .unknown:                       return "An unexpected error occurred."
        }
    }
}
