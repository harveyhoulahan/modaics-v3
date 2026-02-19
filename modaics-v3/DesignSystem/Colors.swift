import SwiftUI

// MARK: - Modaics Dark Green Porsche Design System
/// Deep forest greens, gold accents, near-black backgrounds with MORE green
public extension Color {
    
    // MARK: - Backgrounds (near-black with STRONG green undertones)
    static let modaicsBackground = Color(hex: "0A140F")          // deeper green-black
    static let modaicsBackgroundSecondary = Color(hex: "0F1F17") // stronger green
    static let modaicsBackgroundTertiary = Color(hex: "152920")  // even greener
    static let modaicsElevated = Color(hex: "1C3328")            // elevated surfaces
    
    // MARK: - Surfaces (charcoal with STRONG green tint)
    static let modaicsSurface = Color(hex: "162B21")             // greener surface
    static let modaicsSurfaceHighlight = Color(hex: "1F3D2E")    // stronger green highlight
    
    // MARK: - Primary Greens (forest green - ENHANCED)
    static let modaicsPrimary = Color(hex: "0A2A1A")             // deeper forest
    static let modaicsForest = Color(hex: "0D3D26")              // stronger forest green
    static let modaicsRacingGreen = Color(hex: "145233")         // brighter racing green
    static let modaicsEmerald = Color(hex: "1E6B45")             // more vibrant emerald
    
    // MARK: - Secondary Greens (moss / olive - ENHANCED)
    static let modaicsMoss = Color(hex: "3D5C1F")                // richer moss
    static let modaicsOlive = Color(hex: "5A7A35")               // greener olive
    static let modaicsSage = Color(hex: "7A9A5A")                // more vibrant sage
    static let modaicsFern = Color(hex: "4A9A5A")                // brighter fern
    
    // MARK: - Gold Accents (luxury — same)
    static let luxeGold = Color(hex: "D9BD6B")                   // primary accent
    static let luxeGoldBright = Color(hex: "EBD185")             // highlights
    static let luxeGoldDeep = Color(hex: "B89E4A")               // pressed
    
    // MARK: - Chrome / Metallic
    static let modaicsChrome = Color(hex: "C4C4C4")
    static let modaicsAluminum = Color(hex: "A8A8A8")
    static let modaicsPlatinum = Color(hex: "E8E8E8")
    static let modaicsGunmetal = Color(hex: "6B7280")
    
    // MARK: - Text
    static let sageWhite = Color(hex: "F5F7F3")                  // slightly green-tinted white
    static let sageMuted = Color(hex: "B8C9B0")                  // green-tinted muted
    static let sageSubtle = Color(hex: "7A8B72")                 // green-tinted subtle
    
    // MARK: - Semantic (ENHANCED greens)
    static let modaicsEco = Color(hex: "3DDC84")                 // brighter eco green
    static let emerald = Color(hex: "2DD47A")                    // more vibrant emerald
    static let natureTeal = Color(hex: "2D9CDB")                 // water/teal accent
    static let modaicsWarning = Color(hex: "F59E0B")
    static let modaicsError = Color(hex: "EF4444")
    
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