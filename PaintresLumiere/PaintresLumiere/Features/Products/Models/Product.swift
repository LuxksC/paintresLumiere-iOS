import Foundation

// MARK: - Product
//
// Catalog-list representation of a product. The API deduplicates by SKU so
// each `Product` here corresponds to one SKU group — picking the variant is
// done on the detail screen via `/products/sku/{sku}`.

struct Product: Decodable, Identifiable, Hashable {
    let id: String
    let sku: String
    let name: String
    let slug: String
    let description: String?
    let images: [String]
    let stockQuantity: Int
    let status: ProductStatus
    let pricing: ProductPricing
    let specifications: ProductListSpecifications

    var primaryImageURL: URL? {
        images.first.flatMap(URL.init(string:))
    }
}
