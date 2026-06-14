import SwiftUI

// MARK: - ProductColor
//
// Mirrors the `product_color` Postgres enum. Each case maps to a SwiftUI
// `Color` used to render swatches in the variant selector.

enum ProductColor: String, Decodable, Hashable, CaseIterable {
    case gold
    case silver
    case bronze
    case rose
    case transparent
    case black

    var displayName: String {
        switch self {
        case .gold:        "Gold"
        case .silver:      "Silver"
        case .bronze:      "Bronze"
        case .rose:        "Rose"
        case .transparent: "Transparent"
        case .black:       "Black"
        }
    }

    /// The visual swatch color shown in selectors. `transparent` renders as a
    /// soft glass-like tone with a visible border (handled in the selector
    /// view) so it never looks empty.
    var swatch: Color {
        switch self {
        case .gold:        Color(hex: "D4A53A")
        case .silver:      Color(hex: "C0C5CB")
        case .bronze:      Color(hex: "8C6239")
        case .rose:        Color(hex: "E6B6B0")
        case .transparent: Color.white.opacity(0.08)
        case .black:       Color(hex: "1A1A1A")
        }
    }

    /// True when the swatch is so light it needs an outline to read on the
    /// app's dark background.
    var needsSwatchOutline: Bool {
        self == .transparent || self == .silver || self == .rose
    }
}
