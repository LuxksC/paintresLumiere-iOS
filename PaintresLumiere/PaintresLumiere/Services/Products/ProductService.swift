import Foundation

// MARK: - ProductService

final class ProductService: ProductServiceProtocol {

    private let client: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.client = apiClient
    }

    func getProducts() async throws -> [Product] {
        let response: ProductsResponse<Product> = try await client.request(.getProducts)
        return response.products
    }

    func getPopularProducts(limit: Int?) async throws -> [Product] {
        let response: ProductsResponse<Product> = try await client.request(.getPopularProducts(limit: limit))
        return response.products
    }

    func getProductVariants(sku: String) async throws -> [ProductVariant] {
        let response: ProductsResponse<ProductVariant> = try await client.request(.getProductBySku(sku: sku))
        return response.products
    }
}
