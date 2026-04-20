import UIKit

// MARK: - HomeCoordinator

/// Manages the Home tab navigation stack.
final class HomeCoordinator: Coordinator {

    let navigationController: UINavigationController

    init() {
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        let vc = HomeViewController()
        navigationController.setViewControllers([vc], animated: false)
        navigationController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
    }
}
