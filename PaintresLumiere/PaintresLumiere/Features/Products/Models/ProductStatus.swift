import Foundation

// MARK: - ProductStatus
//
// Mirrors the `product_status` Postgres enum. `inactive` is filtered out by
// the API before the client ever sees it, but is kept here for completeness.

enum ProductStatus: String, Decodable, Hashable {
    case active
    case inactive
    case outOfStock = "out_of_stock"

    var isPurchasable: Bool { self == .active }

    var displayName: String {
        switch self {
        case .active:     "In stock"
        case .inactive:   "Unavailable"
        case .outOfStock: "Out of stock"
        }
    }
}
