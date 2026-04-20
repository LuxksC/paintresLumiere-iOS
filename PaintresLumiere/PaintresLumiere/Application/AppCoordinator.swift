// Root coordinator. Owns the UIWindow and switches between the Auth and
// Main flows based on authentication state. Never exposed to screens.

import UIKit
import Swinject

final class AppCoordinator: Coordinator {
  // MARK: - Variables

  private let window: UIWindow
  private let resolver: Resolver
  private let keychain: KeychainService

  private var authCoordinator: AuthCoordinator?
  private var mainTabCoordinator: MainTabCoordinator?

  //MARK: - Constructor

  init(window: UIWindow, resolver: Resolver) {
    self.window = window
    self.resolver = resolver
    self.keychain = resolver.resolve(KeychainService.self) ?? KeychainService.shared
  }

  // MARK: - Public Methods

  func start() {
    if keychain.isAuthenticated {
        showMain(animated: false)
    } else {
        showAuth(animated: false)
    }
  }

  // MARK: - Flow transitions

  private func showAuth(animated: Bool) {
    let coordinator = AuthCoordinator(resolver: resolver)
    coordinator.delegate = self
    authCoordinator = coordinator
    mainTabCoordinator = nil
    coordinator.start()
    setRoot(coordinator.navigationController, animated: animated)
  }

  private func showMain(animated: Bool) {
    let coordinator = MainTabCoordinator(resolver: resolver)
    coordinator.delegate = self
    mainTabCoordinator = coordinator
    authCoordinator = nil
    coordinator.start()
    setRoot(coordinator.tabBarController, animated: animated)
  }

  private func setRoot(_ viewController: UIViewController, animated: Bool) {
    guard animated else {
      window.rootViewController = viewController
      return
    }
    UIView.transition(
      with: window,
      duration: 0.3,
      options: .transitionCrossDissolve,
      animations: { self.window.rootViewController = viewController }
    )
  }
}

// MARK: - AuthCoordinatorDelegate

extension AppCoordinator: AuthCoordinatorDelegate {
  func onAuthenticated() {
    showMain(animated: true)
  }
}

// MARK: - MainTabCoordinatorDelegate

extension AppCoordinator: MainTabCoordinatorDelegate {
  func onLoggedOut() {
    showAuth(animated: true)
  }
}
