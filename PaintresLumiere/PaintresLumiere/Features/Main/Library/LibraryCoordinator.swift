import UIKit

// MARK: - LibraryCoordinator

/// Manages the Library tab navigation stack.
final class LibraryCoordinator: Coordinator {

    let navigationController: UINavigationController

    init() {
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        let vc = LibraryViewController()
        navigationController.setViewControllers([vc], animated: false)
        navigationController.tabBarItem = UITabBarItem(
            title: "Library",
            image: UIImage(systemName: "books.vertical"),
            selectedImage: UIImage(systemName: "books.vertical.fill")
        )
    }
}
