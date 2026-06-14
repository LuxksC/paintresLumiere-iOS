// Manages the logged-in tab bar experience.
// Owns three child coordinators: Home, Library, Profile.

import UIKit
import Swinject

protocol MainTabCoordinatorDelegate: AnyObject {
  /// Called when the user logs out from any tab.
  func onLoggedOut()
}

final class MainTabCoordinator: Coordinator {

  let tabBarController: UITabBarController
  private let resolver: Resolver

  weak var delegate: MainTabCoordinatorDelegate?
  
  private var homeCoordinator: HomeCoordinator?
  private var libraryCoordinator: LibraryCoordinator?
  private var profileCoordinator: ProfileCoordinator?

  init(resolver: Resolver) {
    self.resolver = resolver
    self.tabBarController = UITabBarController()
  }

  func start() {
    let home = HomeCoordinator(resolver: resolver)
    let library = LibraryCoordinator()
    let profile = ProfileCoordinator(resolver: resolver)

    profile.delegate = self
  
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

// MARK: - ProfileCoordinatorDelegate

extension MainTabCoordinator: ProfileCoordinatorDelegate {
  func onLoggedOut() {
    delegate?.onLoggedOut()
  }
}
