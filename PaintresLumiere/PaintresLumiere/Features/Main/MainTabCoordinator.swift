import UIKit
import Swinject

// MARK: - MainTabCoordinator

/// Manages the logged-in tab bar experience.
/// Owns three child coordinators: Home, Library, Profile.
final class MainTabCoordinator: Coordinator {

    let tabBarController: UITabBarController
    private let resolver: Resolver

    /// Called when the user logs out from any tab.
    var onLoggedOut: (() -> Void)?

    private var homeCoordinator: HomeCoordinator?
    private var libraryCoordinator: LibraryCoordinator?
    private var profileCoordinator: ProfileCoordinator?

    init(resolver: Resolver) {
        self.resolver = resolver
        self.tabBarController = UITabBarController()
    }

    func start() {
        let home = HomeCoordinator()
        let library = LibraryCoordinator()
        let profile = ProfileCoordinator(resolver: resolver)

        profile.onLoggedOut = { [weak self] in self?.onLoggedOut?() }

        homeCoordinator    = home
        libraryCoordinator = library
        profileCoordinator = profile

        home.start()
        library.start()
        profile.start()

        tabBarController.viewControllers = [
            home.navigationController,
            library.navigationController,
            profile.navigationController,
        ]
    }
}
