import Foundation

// MARK: - ProductServiceProtocol

protocol ProductServiceProtocol: AnyObject, Sendable {
    /// Fetches the full catalog. The API already deduplicates by SKU, so each
    /// returned `Product` represents one SKU group.
    func getProducts() async throws -> [Product]

    /// Fetches the top-selling products for "Most Popular" sections.
    /// - Parameter limit: maximum number of products to return. The API caps
    ///   this at 20 and defaults to 10 when nil is passed.
    func getPopularProducts(limit: Int?) async throws -> [Product]

    /// Fetches every variant of a given SKU group — different colors / sizes
    /// of the same product.
    func getProductVariants(sku: String) async throws -> [ProductVariant]
}
