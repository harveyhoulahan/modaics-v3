import SwiftUI

// MARK: - Modaics Dark Green Porsche Design System
/// Deep forest greens, gold accents, near-black backgrounds
public extension Color {
    
    // MARK: - Backgrounds (near-black with green undertones)
    static let modaicsBackground = Color(hex: "0D120F")          // primary bg — deep void with subtle green
    static let modaicsBackgroundSecondary = Color(hex: "141B16") // slightly lighter
    static let modaicsBackgroundTertiary = Color(hex: "1C241F")  // cards and surfaces
    static let modaicsElevated = Color(hex: "232B26")            // modals and sheets
    
    // MARK: - Surfaces (charcoal with green tint)
    static let modaicsSurface = Color(hex: "1E2621")             // primary surface
    static let modaicsSurfaceHighlight = Color(hex: "28332C")    // hover/active states
    
    // MARK: - Primary Greens (racing green / forest)
    static let modaicsPrimary = Color(hex: "0A1F15")             // Porsche racing green — signature
    static let modaicsForest = Color(hex: "0F2E1C")              // primary actions
    static let modaicsRacingGreen = Color(hex: "1A3D28")         // brighter interactive
    static let modaicsEmerald = Color(hex: "2D5A3D")             // selected states
    
    // MARK: - Secondary Greens (moss / olive)
    static let modaicsMoss = Color(hex: "4A5D23")                // organic feel
    static let modaicsOlive = Color(hex: "6B7B3C")               // earthy sophistication
    static let modaicsSage = Color(hex: "8B9A6D")                // softer green
    static let modaicsFern = Color(hex: "5A7A4A")                // sustainability
    
    // MARK: - Gold Accents (luxury — replaces red)
    static let luxeGold = Color(hex: "D9BD6B")                   // primary accent, CTAs
    static let luxeGoldBright = Color(hex: "EBD185")             // highlights
    static let luxeGoldDeep = Color(hex: "B89E4A")               // pressed states
    
    // MARK: - Chrome / Metallic
    static let modaicsChrome = Color(hex: "C4C4C4")              // chrome silver
    static let modaicsAluminum = Color(hex: "A8A8A8")            // brushed aluminum
    static let modaicsPlatinum = Color(hex: "E8E8E8")            // bright metallic
    static let modaicsGunmetal = Color(hex: "6B7280")            // dark metallic
    
    // MARK: - Text
    static let sageWhite = Color(hex: "F5F3EE")                  // primary text — warm white
    static let sageMuted = Color(hex: "BFC7B8")                  // secondary text
    static let sageSubtle = Color(hex: "8C9585")                 // tertiary / placeholders
    
    // MARK: - Semantic
    static let modaicsEco = Color(hex: "4ADE80")                 // sustainability success
    static let emerald = Color(hex: "33B873")                    // eco-positive actions
    static let modaicsWarning = Color(hex: "F59E0B")             // caution
    static let modaicsError = Color(hex: "EF4444")               // destructive only
    
    // MARK: - Background Gradient
    static var forestBackground: LinearGradient {
        LinearGradient(
            colors: [.modaicsBackground, .modaicsBackgroundSecondary],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}