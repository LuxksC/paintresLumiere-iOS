import GoogleSignIn
import UIKit

// MARK: - GoogleSignInHelper
//
// Async wrapper around GIDSignIn. Locates the active foreground window scene
// to present the sign-in sheet, removing the need to pass a UIViewController.

enum GoogleSignInHelper {

    enum SignInError: LocalizedError {
        case noPresentingViewController
        case missingIdToken

        var errorDescription: String? {
            switch self {
            case .noPresentingViewController: return "Unable to present Google Sign-In."
            case .missingIdToken:             return "Google sign-in failed. Please try again."
            }
        }
    }

    @MainActor
    static func signIn() async throws -> String {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController else {
            throw SignInError.noPresentingViewController
        }

        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let idToken = result?.user.idToken?.tokenString else {
                    continuation.resume(throwing: SignInError.missingIdToken)
                    return
                }
                continuation.resume(returning: idToken)
            }
        }
    }
}
