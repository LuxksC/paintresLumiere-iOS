import Foundation

// MARK: - ProductPricing
//
// Matches the `pricing` sub-object returned by the API.
// `discountRate` is a fraction from 0 to 1 (e.g. 0.10 means 10% off).
// `finalPrice` is precomputed server-side as `sellingPrice * (1 - discountRate)`.

struct ProductPricing: Decodable, Hashable {
    let sellingPrice: Decimal
    let discountRate: Decimal
    let finalPrice: Decimal

    var hasDiscount: Bool { discountRate > 0 }

    var discountPercentLabel: String {
        let percent = (discountRate * 100) as NSDecimalNumber
        return "-\(percent.intValue)%"
    }
}
