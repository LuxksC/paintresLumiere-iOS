import Foundation

#if DEBUG

// MARK: - PreviewProductService
//
// Drives SwiftUI previews and any debug screens that need realistic product
// data without hitting the network. Loads from the mock JSON fixtures in
// Networking/Mocks/.

final class PreviewProductService: ProductServiceProtocol {

    private let listResponse: ProductsResponse<Product>
    private let variantsResponse: ProductsResponse<ProductVariant>

    init(
        listFixture: String = "products_response",
        variantsFixture: String = "product_by_sku_response"
    ) {
        self.listResponse = (try? JsonHelper.decodeFixture(listFixture))
            ?? ProductsResponse(products: [])
        self.variantsResponse = (try? JsonHelper.decodeFixture(variantsFixture))
            ?? ProductsResponse(products: [])
    }

    func getProducts() async throws -> [Product] {
        listResponse.products
    }

    func getPopularProducts(limit: Int?) async throws -> [Product] {
        let products = listResponse.products
        guard let limit else { return products }
        return Array(products.prefix(limit))
    }

    func getProductVariants(sku: String) async throws -> [ProductVariant] {
        variantsResponse.products
    }
}

#endif
