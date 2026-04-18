import SwiftUI
import UIKit

// MARK: - Color tokens (Figma Design System · 🎨)

enum PLColor {

    // Background
    static let backgroundPrimary   = Color(hex: "0C0907")
    static let backgroundSecondary = Color(hex: "15100D")
    static let backgroundElevated  = Color(hex: "221A15")
    static let backgroundHighlight = Color(hex: "33281F")

    // Brand Gold
    static let goldBright  = Color(hex: "EDC957")
    static let goldMid     = Color(hex: "CDA639")
    static let goldDeep    = Color(hex: "9B7719")
    static let goldAntique = Color(hex: "795911")

    // Text
    static let textPrimary   = Color(hex: "F5EFE1")
    static let textSecondary = Color(hex: "E1DACC")
    static let textMuted     = Color(hex: "B1AA9D")
    static let textDisabled  = Color(hex: "6F6A62")

    // Semantic
    static let error           = Color(hex: "C72C2C")
    static let errorBackground = Color(hex: "801212")
    static let success         = Color(hex: "418754")

    // Border
    static let borderSubtle = Color(hex: "33281F")
}

// MARK: - UIColor equivalents (for UIKit interop)

extension PLColor {
    enum UI {
        static let backgroundPrimary   = UIColor(hex: "0C0907")
        static let backgroundSecondary = UIColor(hex: "15100D")
        static let backgroundElevated  = UIColor(hex: "221A15")
        static let backgroundHighlight = UIColor(hex: "33281F")

        static let goldBright  = UIColor(hex: "EDC957")
        static let goldMid     = UIColor(hex: "CDA639")
        static let goldDeep    = UIColor(hex: "9B7719")
        static let goldAntique = UIColor(hex: "795911")

        static let textPrimary   = UIColor(hex: "F5EFE1")
        static let textSecondary = UIColor(hex: "E1DACC")
        static let textMuted     = UIColor(hex: "B1AA9D")
        static let textDisabled  = UIColor(hex: "6F6A62")

        static let error           = UIColor(hex: "C72C2C")
        static let errorBackground = UIColor(hex: "801212")
        static let success         = UIColor(hex: "418754")

        static let borderSubtle = UIColor(hex: "33281F")
    }
}

// MARK: - Hex initializers

extension Color {
    init(hex: String) {
        var h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        if h.hasPrefix("#") { h.removeFirst() }
        var n: UInt64 = 0
        Scanner(string: h).scanHexInt64(&n)
        let r, g, b: Double
        switch h.count {
        case 3:  r = Double((n >> 8) * 17) / 255; g = Double((n >> 4 & 0xF) * 17) / 255; b = Double((n & 0xF) * 17) / 255
        case 6:  r = Double(n >> 16) / 255;        g = Double(n >> 8 & 0xFF) / 255;        b = Double(n & 0xFF) / 255
        default: r = 1; g = 1; b = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        if h.hasPrefix("#") { h.removeFirst() }
        var n: UInt64 = 0
        Scanner(string: h).scanHexInt64(&n)
        let r, g, b: CGFloat
        switch h.count {
        case 3:  r = CGFloat((n >> 8) * 17) / 255; g = CGFloat((n >> 4 & 0xF) * 17) / 255; b = CGFloat((n & 0xF) * 17) / 255
        case 6:  r = CGFloat(n >> 16) / 255;        g = CGFloat(n >> 8 & 0xFF) / 255;        b = CGFloat(n & 0xFF) / 255
        default: r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
