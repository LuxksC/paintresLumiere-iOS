import UIKit
import Swinject

// MARK: - HomeCoordinator

/// Manages the Home tab navigation stack. Pushes Product Details when a card
/// is tapped; bell and cart icons fire toast placeholders until those flows
/// exist.
final class HomeCoordinator: Coordinator {

    let navigationController: UINavigationController
    private let resolver: Resolver

    init(resolver: Resolver) {
        self.resolver = resolver
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        let viewModel = makeHomeViewModel()
        viewModel.coordinator = self
        let vc = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
        navigationController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
    }

    // MARK: - Factories

    private func makeHomeViewModel() -> HomeViewModel {
        if let vm = resolver.resolve(HomeViewModel.self) {
            return vm
        }
        return HomeViewModel(
            productService: resolveProductService(),
            messages: resolveMessages()
        )
    }

    private func makeProductDetailsViewModel(sku: String) -> ProductDetailsViewModel {
        if let vm = resolver.resolve(ProductDetailsViewModel.self, argument: sku) {
            return vm
        }
        return ProductDetailsViewModel(
            sku: sku,
            productService: resolveProductService(),
            messages: resolveMessages()
        )
    }

    private func resolveProductService() -> ProductServiceProtocol {
        resolver.resolve(ProductServiceProtocol.self)
            ?? ProductService(apiClient: APIClient())
    }

    private func resolveMessages() -> MessagesServiceProtocol {
        resolver.resolve(MessagesServiceProtocol.self) ?? MessagesService()
    }
}

// MARK: - HomeCoordinatorProtocol

extension HomeCoordinator: HomeCoordinatorProtocol {

    func homeDidSelectProduct(sku: String) {
        let viewModel = makeProductDetailsViewModel(sku: sku)
        viewModel.coordinator = self
        let vc = ProductDetailsViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func homeDidTapNotifications() {
        resolveMessages().showComingSoon()
    }

    func homeDidTapCart() {
        resolveMessages().showComingSoon()
    }
}

// MARK: - ProductDetailsCoordinatorProtocol

extension HomeCoordinator: ProductDetailsCoordinatorProtocol {

    func productDetailsDidRequestDismiss() {
        navigationController.popViewController(animated: true)
    }
}
