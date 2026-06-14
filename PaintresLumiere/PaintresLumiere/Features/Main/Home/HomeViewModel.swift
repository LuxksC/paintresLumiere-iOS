import Foundation

// MARK: - HomeViewModel

@Observable
@MainActor
final class HomeViewModel {

    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var catalog: [Product] = []
    private(set) var popular: [Product] = []
    private(set) var state: LoadState = .idle

    weak var coordinator: (any HomeCoordinatorProtocol)?

    private let productService: ProductServiceProtocol
    private let messages: MessagesServiceProtocol

    init(productService: ProductServiceProtocol, messages: MessagesServiceProtocol) {
        self.productService = productService
        self.messages = messages
    }

    var isInitialLoading: Bool {
        state == .loading && catalog.isEmpty
    }

    var hasContent: Bool {
        !catalog.isEmpty
    }

    // MARK: - Actions

    func load() async {
        if catalog.isEmpty { state = .loading }
        do {
            async let catalogTask = productService.getProducts()
            async let popularTask = productService.getPopularProducts(limit: 5)
            let (loadedCatalog, loadedPopular) = try await (catalogTask, popularTask)
            self.catalog = loadedCatalog.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            self.popular = loadedPopular
            self.state = .loaded
        } catch {
            self.state = .failed(error.localizedDescription)
            messages.showNetworkError()
        }
    }

    func selectProduct(_ product: Product) {
        coordinator?.homeDidSelectProduct(sku: product.sku)
    }

    func tapNotifications() {
        coordinator?.homeDidTapNotifications()
    }

    func tapCart() {
        coordinator?.homeDidTapCart()
    }
}
