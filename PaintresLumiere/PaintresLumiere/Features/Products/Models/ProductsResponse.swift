import Foundation

// MARK: - ProductsResponse
//
// Generic envelope matching `{ "products": [...] }`. Used for both the
// catalog list (`Product`) and the SKU detail (`ProductVariant`) endpoints.

struct ProductsResponse<Item: Decodable>: Decodable {
    let products: [Item]
}
