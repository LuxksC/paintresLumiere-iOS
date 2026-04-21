// Manages the authentication flow: Login → Sign Up / Forgot Password.
// Implements AuthCoordinatorProtocol so ViewModels can trigger navigation
// without knowing this coordinator exists.

import UIKit
import Swinject

protocol AuthCoordinatorDelegate: AnyObject {
  /// Called when the user completes authentication successfully.
  func onAuthenticated()
}

final class AuthCoordinator: Coordinator {
  // MARK: - Variables

  let navigationController: UINavigationController
  private let resolver: Resolver
  weak var delegate: AuthCoordinatorDelegate?

  // MARK: - Constructor

  init(resolver: Resolver) {
      self.resolver = resolver
      self.navigationController = UINavigationController()
      self.navigationController.setNavigationBarHidden(true, animated: false)
  }

  // MARK: - Public methods

  func start() {
      let viewModel = makeLoginViewModel()
      viewModel.coordinator = self
      let vc = LoginViewController(viewModel: viewModel)
      navigationController.setViewControllers([vc], animated: false)
  }

  // MARK: - Factory helpers

  private func makeLoginViewModel() -> LoginViewModel {
      resolver.resolve(LoginViewModel.self)
          ?? LoginViewModel(authService: resolveAuthService())
  }

  private func makeSignUpViewModel() -> SignUpViewModel {
      resolver.resolve(SignUpViewModel.self)
          ?? SignUpViewModel(authService: resolveAuthService())
  }

  private func makeForgotPasswordViewModel() -> ForgotPasswordViewModel {
      resolver.resolve(ForgotPasswordViewModel.self)
          ?? ForgotPasswordViewModel(authService: resolveAuthService())
  }

  private func resolveAuthService() -> AuthServiceProtocol {
      resolver.resolve(AuthServiceProtocol.self)
          ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
  }
}

// MARK: - AuthCoordinatorProtocol

extension AuthCoordinator: AuthCoordinatorProtocol {

  func loginDidSucceed() {
    delegate?.onAuthenticated()
  }

  func loginDidRequestSignUp() {
      let viewModel = makeSignUpViewModel()
      viewModel.coordinator = self
      let vc = SignUpViewController(viewModel: viewModel)
      navigationController.pushViewController(vc, animated: true)
  }

  func loginDidRequestForgotPassword() {
      let viewModel = makeForgotPasswordViewModel()
      viewModel.coordinator = self
      let vc = ForgotPasswordViewController(viewModel: viewModel)
      navigationController.pushViewController(vc, animated: true)
  }

  func signUpDidSucceed() {
    delegate?.onAuthenticated()
  }

  func signUpDidRequestLogin() {
      navigationController.popViewController(animated: true)
  }

  func forgotPasswordDidFinish() {
      navigationController.popViewController(animated: true)
  }
}
