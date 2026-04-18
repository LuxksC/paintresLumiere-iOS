import Foundation

// MARK: - Network Configuration
// Replace baseURL with your deployed API endpoint (serverless.yml / AWS API Gateway)

enum NetworkConfig {
    static let baseURL = URL(string: "https://glj3lixjr7.execute-api.sa-east-1.amazonaws.com")!
    static let timeoutInterval: TimeInterval = 30
}
