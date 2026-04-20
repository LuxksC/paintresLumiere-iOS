import Foundation

// MARK: - Coordinator Action Protocols
//
// ViewModels use these to trigger navigation without importing UIKit
// or referencing any concrete coordinator type.

protocol AuthCoordinatorProtocol: AnyObject {
    func loginDidSucceed()
    func loginDidRequestSignUp()
    func loginDidRequestForgotPassword()
    func signUpDidSucceed()
    func signUpDidRequestLogin()
    func forgotPasswordDidFinish()
}

protocol ProfileCoordinatorProtocol: AnyObject {
    func profileDidRequestLogout()
}
