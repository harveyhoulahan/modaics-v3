import SwiftUI

// MARK: - Modaics Industrial Colors
/// Industrial design palette
/// Dark blue backgrounds, red accents, chrome/silver details
public extension Color {
    
    // MARK: - Background Colors
    
    /// Dark navy - primary app background
    static let modaicsDarkNavy = Color(red: 0.08, green: 0.10, blue: 0.14)
    
    /// Darker blue - card/elevated surface background
    static let modaicsDarkBlue = Color(red: 0.06, green: 0.08, blue: 0.11)
    
    /// Midnight blue - deepest background
    static let modaicsMidnight = Color(red: 0.04, green: 0.06, blue: 0.09)
    
    /// Panel blue - secondary background
    static let modaicsPanelBlue = Color(red: 0.12, green: 0.15, blue: 0.19)
    
    // MARK: - Accent Colors
    
    /// Industrial red - primary accent/CTA color
    static let modaicsIndustrialRed = Color(red: 0.85, green: 0.18, blue: 0.18)
    
    /// Signal red - alert/active states
    static let modaicsSignalRed = Color(red: 0.92, green: 0.22, blue: 0.22)
    
    /// Warning amber - caution states
    static let modaicsWarningAmber = Color(red: 0.95, green: 0.65, blue: 0.15)
    
    /// Success green - positive states
    static let modaicsSuccessGreen = Color(red: 0.25, green: 0.75, blue: 0.45)
    
    // MARK: - Chrome/Silver Colors
    
    /// Chrome - bright metallic
    static let modaicsChrome = Color(red: 0.85, green: 0.87, blue: 0.89)
    
    /// Silver - inactive tab color
    static let modaicsSilver = Color(red: 0.65, green: 0.68, blue: 0.72)
    
    /// Steel gray - secondary metallic
    static let modaicsSteel = Color(red: 0.50, green: 0.53, blue: 0.57)
    
    /// Graphite - dark metallic accents
    static let modaicsGraphite = Color(red: 0.35, green: 0.38, blue: 0.42)
    
    /// Gunmetal - borders and dividers
    static let modaicsGunmetal = Color(red: 0.25, green: 0.28, blue: 0.32)
    
    // MARK: - Text Colors
    
    /// White - primary text on dark backgrounds
    static let modaicsTextWhite = Color(red: 0.98, green: 0.98, blue: 0.98)
    
    /// Light gray - secondary text
    static let modaicsTextLight = Color(red: 0.75, green: 0.78, blue: 0.82)
    
    /// Medium gray - tertiary text
    static let modaicsTextMedium = Color(red: 0.55, green: 0.58, blue: 0.62)
    
    /// Dimmed text - disabled/hint text
    static let modaicsTextDimmed = Color(red: 0.40, green: 0.43, blue: 0.47)
    
    // MARK: - Semantic Aliases
    
    /// Primary background
    static let modaicsBackgroundPrimary: Color = .modaicsDarkNavy
    
    /// Secondary background (cards, sheets)
    static let modaicsBackgroundSecondary: Color = .modaicsDarkBlue
    
    /// Tertiary background (panels)
    static let modaicsBackgroundTertiary: Color = .modaicsPanelBlue
    
    /// Primary text
    static let modaicsTextPrimary: Color = .modaicsTextWhite
    
    /// Secondary text
    static let modaicsTextSecondary: Color = .modaicsTextLight
    
    /// Tertiary/subtle text
    static let modaicsTextTertiary: Color = .modaicsTextMedium
    
    /// Primary accent (active states, CTAs)
    static let modaicsAccent: Color = .modaicsIndustrialRed
    
    /// Active color for tabs
    static let modaicsActive: Color = .modaicsIndustrialRed
    
    /// Inactive color for tabs
    static let modaicsInactive: Color = .modaicsSilver
    
    /// Success color
    static let modaicsSuccess: Color = .modaicsSuccessGreen
    
    /// Error color
    static let modaicsError: Color = .modaicsSignalRed
    
    /// Warning color
    static let modaicsWarning: Color = .modaicsWarningAmber
    
    /// Border color
    static let modaicsBorder: Color = .modaicsGunmetal
}

// MARK: - Color Gradients

public extension LinearGradient {
    
    /// Industrial red gradient for active elements
    static let modaicsIndustrialRedGradient = LinearGradient(
        colors: [Color.modaicsIndustrialRed, Color.modaicsSignalRed],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Chrome gradient for metallic accents
    static let modaicsChromeGradient = LinearGradient(
        colors: [Color.modaicsChrome, Color.modaicsSilver],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Dark background gradient
    static let modaicsDarkGradient = LinearGradient(
        colors: [Color.modaicsDarkNavy, Color.modaicsMidnight],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Panel gradient for elevated surfaces
    static let modaicsPanelGradient = LinearGradient(
        colors: [Color.modaicsPanelBlue, Color.modaicsDarkBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
