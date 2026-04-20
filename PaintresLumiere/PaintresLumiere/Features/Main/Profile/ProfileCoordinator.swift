import UIKit
import Swinject

// MARK: - ProfileCoordinator

/// Manages the Profile tab navigation stack.
/// Implements ProfileCoordinatorProtocol so ProfileViewModel can trigger logout
/// without knowing this coordinator exists.
final class ProfileCoordinator: Coordinator {

    let navigationController: UINavigationController
    private let resolver: Resolver

    /// Called when the user logs out or deletes their account.
    var onLoggedOut: (() -> Void)?

    init(resolver: Resolver) {
        self.resolver = resolver
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        let viewModel = resolver.resolve(ProfileViewModel.self)
            ?? ProfileViewModel(authService: resolveAuthService())
        viewModel.coordinator = self
        let vc = ProfileViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
        navigationController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
    }

    private func resolveAuthService() -> AuthServiceProtocol {
        resolver.resolve(AuthServiceProtocol.self)
            ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
    }
}

// MARK: - ProfileCoordinatorProtocol

extension ProfileCoordinator: ProfileCoordinatorProtocol {

    func profileDidRequestLogout() {
        onLoggedOut?()
    }
}
