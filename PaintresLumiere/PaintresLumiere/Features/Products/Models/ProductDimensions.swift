import Foundation

// MARK: - ProductDimensions
//
// Matches `specifications.dimensions` on the variant detail response. Each
// axis is independently nullable depending on the product type (e.g. a flat
// letter has no `length`). `unit` is a free-form short string sent by the
// API — typically `"mm"`.

struct ProductDimensions: Decodable, Hashable {
    let width: Double?
    let height: Double?
    let length: Double?
    let thickness: Double?
    let unit: String?

    /// Compact label used as the title of a size pill. Renders only the axes
    /// that are present in the response, joined with the multiplication sign.
    /// Example: `"200 × 80 × 3mm"`.
    var compactLabel: String {
        let axes = [width, height, length, thickness]
            .compactMap { $0 }
            .map(Self.formatNumber)
        guard !axes.isEmpty else { return "—" }
        let joined = axes.joined(separator: " × ")
        return unit.map { "\(joined)\($0)" } ?? joined
    }

    private static func formatNumber(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : value.formatted(.number.precision(.fractionLength(0...2)))
    }
}
