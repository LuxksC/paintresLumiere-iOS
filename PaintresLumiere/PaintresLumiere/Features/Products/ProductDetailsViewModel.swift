import Foundation
import SwiftUI

// MARK: - ProductDetailsViewModel
//
// Drives the product detail screen. Receives a SKU on construction, fetches
// the variants for that SKU, and exposes selection state for color, size,
// and quantity. Selection is constrained so the user can never land on a
// combination that doesn't exist — disabled options in the selectors tell
// them "this color/size pair isn't available, pick the other axis first".

@Observable
@MainActor
final class ProductDetailsViewModel {

    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    let sku: String

    private(set) var variants: [ProductVariant] = []
    private(set) var state: LoadState = .idle
    private(set) var selectedColor: ProductColor?
    private(set) var selectedSize: String?
    var quantity: Int = 1

    weak var coordinator: (any ProductDetailsCoordinatorProtocol)?

    private let productService: ProductServiceProtocol
    private let messages: MessagesServiceProtocol

    init(
        sku: String,
        productService: ProductServiceProtocol,
        messages: MessagesServiceProtocol
    ) {
        self.sku = sku
        self.productService = productService
        self.messages = messages
    }

    // MARK: - Derived

    /// The variant matching the current color + size selection, or nil if
    /// the data hasn't loaded yet.
    var selectedVariant: ProductVariant? {
        variants.first { variant in
            variant.color == selectedColor && variant.sizeLabel == selectedSize
        }
    }

    /// Colors that exist across all variants, in a stable order (the order
    /// in which they first appear in the response).
    var availableColors: [ProductColor] {
        var seen: Set<ProductColor> = []
        return variants.compactMap { variant in
            guard !seen.contains(variant.color) else { return nil }
            seen.insert(variant.color)
            return variant.color
        }
    }

    /// Sizes that exist across all variants, in a stable order.
    var availableSizes: [String] {
        var seen: Set<String> = []
        return variants.compactMap { variant in
            let label = variant.sizeLabel
            guard !seen.contains(label) else { return nil }
            seen.insert(label)
            return label
        }
    }

    /// Colors enabled for the currently-selected size. A color is enabled
    /// if at least one variant has that color paired with the current size.
    var enabledColors: Set<ProductColor> {
        guard let selectedSize else { return Set(availableColors) }
        return Set(variants.filter { $0.sizeLabel == selectedSize }.map { $0.color })
    }

    /// Sizes enabled for the currently-selected color.
    var enabledSizes: Set<String> {
        guard let selectedColor else { return Set(availableSizes) }
        return Set(variants.filter { $0.color == selectedColor }.map { $0.sizeLabel })
    }

    var maxQuantity: Int { selectedVariant?.stockQuantity ?? 0 }

    var canPurchase: Bool {
        selectedVariant?.status.isPurchasable == true && maxQuantity > 0
    }

    var hasMultipleColors: Bool { availableColors.count > 1 }
    var hasMultipleSizes: Bool { availableSizes.count > 1 }

    // MARK: - Bindings used by selectors

    var colorBinding: Binding<ProductColor?> {
        Binding(
            get: { self.selectedColor },
            set: { newValue in
                if let newValue { self.selectColor(newValue) }
            }
        )
    }

    var sizeBinding: Binding<String?> {
        Binding(
            get: { self.selectedSize },
            set: { newValue in
                if let newValue { self.selectSize(newValue) }
            }
        )
    }

    // MARK: - Actions

    func load() async {
        if variants.isEmpty { state = .loading }
        do {
            let loadedVariants = try await productService.getProductVariants(sku: sku)
            self.variants = loadedVariants
            // Default to the first variant returned.
            if let first = loadedVariants.first {
                self.selectedColor = first.color
                self.selectedSize = first.sizeLabel
                self.quantity = first.stockQuantity > 0 ? 1 : 0
            }
            self.state = .loaded
        } catch {
            self.state = .failed(error.localizedDescription)
            messages.showNetworkError()
        }
    }

    func selectColor(_ color: ProductColor) {
        guard enabledColors.contains(color) else { return }
        selectedColor = color
        clampQuantityForCurrentVariant()
    }

    func selectSize(_ size: String) {
        guard enabledSizes.contains(size) else { return }
        selectedSize = size
        clampQuantityForCurrentVariant()
    }

    func buyNow() {
        guard canPurchase else { return }
        messages.showComingSoon()
    }

    func addToCart() {
        guard canPurchase, let variant = selectedVariant else { return }
        messages.showAddedToCart(productName: variant.name)
    }

    func dismiss() {
        coordinator?.productDetailsDidRequestDismiss()
    }

    // MARK: - Helpers

    private func clampQuantityForCurrentVariant() {
        guard let stock = selectedVariant?.stockQuantity, stock > 0 else {
            quantity = 0
            return
        }
        if quantity < 1 { quantity = 1 }
        if quantity > stock { quantity = stock }
    }
}
