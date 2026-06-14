import Foundation

// MARK: - ProductCategory
//
// Mirrors the `product_category` Postgres enum.

enum ProductCategory: String, Decodable, Hashable {
    case names
    case numbers
    case images
    case letters

    var displayName: String {
        switch self {
        case .names:   "Names"
        case .numbers: "Numbers"
        case .images:  "Images"
        case .letters: "Letters"
        }
    }
}
