import SwiftUI

// MARK: - Industrial Color Palette
// Dark blue + Red + Chrome aesthetic for Modaics V3

extension Color {
    // MARK: Background Colors (Dark Blue Variants)
    static let modaicsDarkBlue = Color(red: 0.06, green: 0.08, blue: 0.14)
    static let modaicsDarkBlueSecondary = Color(red: 0.08, green: 0.11, blue: 0.18)
    static let modaicsDarkBlueTertiary = Color(red: 0.10, green: 0.14, blue: 0.22)
    
    // MARK: Surface Colors (Card Backgrounds)
    static let modaicsSurface = Color(red: 0.12, green: 0.16, blue: 0.24)
    static let modaicsSurfaceElevated = Color(red: 0.16, green: 0.20, blue: 0.30)
    static let modaicsSurfacePressed = Color(red: 0.14, green: 0.18, blue: 0.26)
    
    // MARK: Accent Colors
    static let modaicsRed = Color(red: 0.90, green: 0.18, blue: 0.18)
    static let modaicsRedLight = Color(red: 1.0, green: 0.28, blue: 0.28)
    static let modaicsRedDark = Color(red: 0.70, green: 0.12, blue: 0.12)
    
    // MARK: Chrome/Silver Colors
    static let modaicsChrome1 = Color(red: 0.95, green: 0.96, blue: 0.98)
    static let modaicsChrome2 = Color(red: 0.75, green: 0.78, blue: 0.82)
    static let modaicsChrome3 = Color(red: 0.55, green: 0.58, blue: 0.62)
    static let modaicsChrome4 = Color(red: 0.40, green: 0.42, blue: 0.46)
    
    // MARK: Text Colors
    static let modaicsTextMain = Color(red: 0.98, green: 0.98, blue: 0.99)
    static let modaicsTextSecondary = Color(red: 0.75, green: 0.78, blue: 0.82)
    static let modaicsTextMuted = Color(red: 0.55, green: 0.58, blue: 0.62)
    static let modaicsTextDisabled = Color(red: 0.35, green: 0.38, blue: 0.42)
    
    // MARK: Border Colors
    static let modaicsBorder = Color(red: 0.20, green: 0.24, blue: 0.32)
    static let modaicsBorderStrong = Color(red: 0.28, green: 0.32, blue: 0.42)
    static let modaicsBorderChrome = Color(red: 0.55, green: 0.58, blue: 0.62)
    
    // MARK: Semantic Aliases (for consistency with app naming)
    static let appRed = modaicsRed
    static let appSurface = modaicsSurface
    static let appBorder = modaicsBorder
    static let appBg = modaicsDarkBlue
    static let appTextMain = modaicsTextMain
    static let appTextMuted = modaicsTextMuted
    
    // MARK: Status Colors
    static let modaicsSuccess = Color(red: 0.20, green: 0.80, blue: 0.40)
    static let modaicsWarning = Color(red: 0.95, green: 0.70, blue: 0.15)
    static let modaicsError = modaicsRed
    static let modaicsInfo = Color(red: 0.30, green: 0.65, blue: 0.95)
}

// MARK: - Color Theme Struct
struct IndustrialTheme {
    // Backgrounds
    static let backgroundPrimary = Color.modaicsDarkBlue
    static let backgroundSecondary = Color.modaicsDarkBlueSecondary
    static let backgroundTertiary = Color.modaicsDarkBlueTertiary
    
    // Surfaces
    static let surface = Color.modaicsSurface
    static let surfaceElevated = Color.modaicsSurfaceElevated
    static let surfacePressed = Color.modaicsSurfacePressed
    
    // Accents
    static let accentPrimary = Color.modaicsRed
    static let accentPrimaryLight = Color.modaicsRedLight
    static let accentPrimaryDark = Color.modaicsRedDark
    static let accentSecondary = Color.modaicsChrome2
    
    // Text
    static let textPrimary = Color.modaicsTextMain
    static let textSecondary = Color.modaicsTextSecondary
    static let textMuted = Color.modaicsTextMuted
    static let textDisabled = Color.modaicsTextDisabled
    
    // Borders
    static let borderSubtle = Color.modaicsBorder
    static let borderStandard = Color.modaicsBorderStrong
    static let borderChrome = Color.modaicsBorderChrome
    
    // Status
    static let success = Color.modaicsSuccess
    static let warning = Color.modaicsWarning
    static let error = Color.modaicsError
    static let info = Color.modaicsInfo
}

// MARK: - Gradient Presets
extension LinearGradient {
    static let industrialSurface = LinearGradient(
        colors: [Color.modaicsSurface, Color.modaicsDarkBlueSecondary],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let industrialChrome = LinearGradient(
        colors: [Color.modaicsChrome1, Color.modaicsChrome2],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let industrialRedGlow = LinearGradient(
        colors: [Color.modaicsRed.opacity(0.8), Color.modaicsRedDark.opacity(0.4)],
        startPoint: .top,
        endPoint: .bottom
    )
}
