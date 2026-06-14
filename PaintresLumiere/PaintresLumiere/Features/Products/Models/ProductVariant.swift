import Foundation

// MARK: - ProductVariant
//
// Detail representation of a single product row — one specific
// (color + dimensions) combination of a SKU group. `/products/sku/{sku}`
// returns an array of these to power the variant selectors on the detail
// screen.

struct ProductVariant: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let slug: String
    let description: String?
    let images: [String]
    let stockQuantity: Int
    let category: ProductCategory
    let barcode: String?
    let status: ProductStatus
    let pricing: ProductPricing
    let specifications: ProductVariantSpecifications

    var color: ProductColor { specifications.color }
    var dimensions: ProductDimensions { specifications.dimensions }
    var sizeLabel: String { dimensions.compactLabel }
}
