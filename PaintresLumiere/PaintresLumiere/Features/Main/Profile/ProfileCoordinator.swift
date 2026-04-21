// Manages the Profile tab navigation stack.
// Implements ProfileCoordinatorProtocol so ProfileViewModel can trigger logout
// without knowing this coordinator exists.

import UIKit
import Swinject

protocol ProfileCoordinatorDelegate: AnyObject {
  /// Called when the user logs out or deletes their account.
  func onLoggedOut()
}

// MARK: - ProfileCoordinator

final class ProfileCoordinator: Coordinator {

  let navigationController: UINavigationController
  private let resolver: Resolver

  weak var delegate: ProfileCoordinatorDelegate?

  init(resolver: Resolver) {
      self.resolver = resolver
      self.navigationController = UINavigationController()
      self.navigationController.setNavigationBarHidden(true, animated: false)
  }

  func start() {
      let viewModel = makeProfileViewModel()
      viewModel.coordinator = self
      let vc = ProfileViewController(viewModel: viewModel)
      navigationController.setViewControllers([vc], animated: false)
      navigationController.tabBarItem = UITabBarItem(
          title: "Profile",
          image: UIImage(systemName: "person"),
          selectedImage: UIImage(systemName: "person.fill")
      )
  }

  // MARK: - Factory helpers
  
  private func makeProfileViewModel() -> ProfileViewModel {
    resolver.resolve(ProfileViewModel.self)
    ?? ProfileViewModel(authService: resolveAuthService())
  }

  private func resolveAuthService() -> AuthServiceProtocol {
      resolver.resolve(AuthServiceProtocol.self)
          ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
  }
}

// MARK: - ProfileCoordinatorProtocol

extension ProfileCoordinator: ProfileCoordinatorProtocol {
    func profileDidRequestLogout() {
      delegate?.onLoggedOut()
    }
}
