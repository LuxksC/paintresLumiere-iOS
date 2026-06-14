import Foundation

// MARK: - ProductListSpecifications
//
// Matches `specifications` on the catalog list response. Carries only the
// thickness — color/dimensions are reserved for the variant detail response.

struct ProductListSpecifications: Decodable, Hashable {
    let thickness: Double?
}

// MARK: - ProductVariantSpecifications
//
// Matches `specifications` on the variant detail response.

struct ProductVariantSpecifications: Decodable, Hashable {
    let color: ProductColor
    let dimensions: ProductDimensions
}
