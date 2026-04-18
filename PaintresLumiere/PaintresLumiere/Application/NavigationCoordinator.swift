import Foundation

// MARK: - Auth Navigation Routes

enum AuthRoute: Hashable {
    case signUp
    case forgotPassword
}

// MARK: - Coordinator Action Protocols
//
// Used by ViewModels to trigger navigation without coupling to UIKit or concrete coordinators.

protocol AuthCoordinatorActions: AnyObject {
    func loginDidSucceed()
    func loginDidRequestSignUp()
    func loginDidRequestForgotPassword()
    func signUpDidSucceed()
    func signUpDidRequestLogin()
    func forgotPasswordDidFinish()
}

protocol ProfileCoordinatorActions: AnyObject {
    func profileDidRequestLogout()
}

// MARK: - NavigationCoordinator
//
// Observable state manager that drives all navigation in the app.
// Replaces the UIKit coordinator hierarchy — SwiftUI views observe this
// and react to state changes via NavigationStack and TabView.

@Observable
@MainActor
final class NavigationCoordinator {

    var isAuthenticated: Bool
    var authPath: [AuthRoute] = []

    private let keychain: KeychainService

    init(keychain: KeychainService) {
        self.keychain = keychain
        self.isAuthenticated = keychain.isAuthenticated
    }
}

// MARK: - AuthCoordinatorActions

extension NavigationCoordinator: AuthCoordinatorActions {

    func loginDidSucceed() {
        isAuthenticated = true
    }

    func loginDidRequestSignUp() {
        authPath.append(.signUp)
    }

    func loginDidRequestForgotPassword() {
        authPath.append(.forgotPassword)
    }

    func signUpDidSucceed() {
        isAuthenticated = true
    }

    func signUpDidRequestLogin() {
        if !authPath.isEmpty { authPath.removeLast() }
    }

    func forgotPasswordDidFinish() {
        if !authPath.isEmpty { authPath.removeLast() }
    }
}

// MARK: - ProfileCoordinatorActions

extension NavigationCoordinator: ProfileCoordinatorActions {

    func profileDidRequestLogout() {
        isAuthenticated = false
        authPath = []
    }
}
