import SwiftUI

// MARK: - Typography (Inter · Figma Design System · Dynamic Type scaled)
// Uses Font.custom(_:size:relativeTo:) so all sizes scale with accessibility settings.

enum PLFont {
    /// Display — 32pt Bold, scales with .largeTitle
    static func display() -> Font { scaled("Inter-Bold", size: 32, relativeTo: .largeTitle) }

    /// H1 — 26pt Bold, scales with .title
    static func h1() -> Font { scaled("Inter-Bold", size: 26, relativeTo: .title) }

    /// H2 — 20pt SemiBold, scales with .title2
    static func h2() -> Font { scaled("Inter-SemiBold", size: 20, relativeTo: .title2) }

    /// Body — 14pt Regular, scales with .body
    static func body() -> Font { scaled("Inter-Regular", size: 14, relativeTo: .body) }

    /// Caption — 12pt Medium, scales with .caption
    static func caption() -> Font { scaled("Inter-Medium", size: 12, relativeTo: .caption) }

    /// Label — 10pt SemiBold, scales with .caption2
    static func label() -> Font { scaled("Inter-SemiBold", size: 10, relativeTo: .caption2) }

    /// Button — 15pt SemiBold, scales with .callout
    static func button() -> Font { scaled("Inter-SemiBold", size: 15, relativeTo: .callout) }

    /// Link / nav text — 13pt Medium, scales with .subheadline
    static func link() -> Font { scaled("Inter-Medium", size: 13, relativeTo: .subheadline) }

    /// Nav link — 14pt Medium, scales with .body
    static func navLink() -> Font { scaled("Inter-Medium", size: 14, relativeTo: .body) }

    /// Tab bar label — 11pt SemiBold, scales with .caption
    static func tabLabel() -> Font { scaled("Inter-SemiBold", size: 11, relativeTo: .caption) }

    // MARK: - Private

    private static func scaled(_ name: String, size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        if UIFont(name: name, size: size) != nil {
            return .custom(name, size: size, relativeTo: style)
        }
        // Graceful fallback to system font at the same text style
        return .system(style)
    }
}
