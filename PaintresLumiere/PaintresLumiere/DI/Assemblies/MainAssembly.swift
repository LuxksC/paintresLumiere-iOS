import Swinject

// MARK: - Main Assembly
//
// Registers ViewModels used in the main (logged-in) tab flow. ViewModels
// are transient — recreated each time their screen is presented.

final class MainAssembly: Assembly {

    func assemble(container: Container) {
        container.register(HomeViewModel.self) { r in
            let products = r.resolve(ProductServiceProtocol.self)
                ?? ProductService(apiClient: APIClient())
            let messages = r.resolve(MessagesServiceProtocol.self) ?? MessagesService()
            return HomeViewModel(productService: products, messages: messages)
        }.inObjectScope(.transient)

        container.register(ProductDetailsViewModel.self) { (r, sku: String) in
            let products = r.resolve(ProductServiceProtocol.self)
                ?? ProductService(apiClient: APIClient())
            let messages = r.resolve(MessagesServiceProtocol.self) ?? MessagesService()
            return ProductDetailsViewModel(
                sku: sku,
                productService: products,
                messages: messages
            )
        }.inObjectScope(.transient)

        container.register(ProfileViewModel.self) { r in
            let authService = r.resolve(AuthServiceProtocol.self) ?? AuthService(apiClient: APIClient(), keychain: KeychainService.shared)
            return ProfileViewModel(authService: authService)
        }.inObjectScope(.transient)
    }
}
