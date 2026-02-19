import SwiftUI

// MARK: - Modaics Colors
/// Mediterranean-inspired color palette
/// Warm sand backgrounds, terracotta accents, deep olive details
public extension Color {
    
    // MARK: - Primary Colors
    
    /// Warm sand - primary app background
    static let modaicsWarmSand = Color(red: 0.96, green: 0.94, blue: 0.90)
    
    /// Paper - card/elevated surface background
    static let modaicsPaper = Color(red: 0.98, green: 0.97, blue: 0.95)
    
    /// Cream - alternative light background
    static let modaicsCream = Color(red: 0.99, green: 0.98, blue: 0.96)
    
    /// Oatmeal - subtle background variation
    static let modaicsOatmeal = Color(red: 0.94, green: 0.92, blue: 0.88)
    
    // MARK: - Accent Colors
    
    /// Terracotta - primary accent color
    static let modaicsTerracotta = Color(red: 0.80, green: 0.38, blue: 0.27)
    
    /// Deep olive - secondary accent
    static let modaicsDeepOlive = Color(red: 0.35, green: 0.40, blue: 0.30)
    
    /// Sage - success states, eco-friendly indicators
    static let modaicsSage = Color(red: 0.47, green: 0.58, blue: 0.47)
    
    /// Ochre - warning states
    static let modaicsOchre = Color(red: 0.80, green: 0.52, blue: 0.25)
    
    /// Rust - error states
    static let modaicsRust = Color(red: 0.71, green: 0.28, blue: 0.21)
    
    // MARK: - Text Colors
    
    /// Charcoal - primary text color
    static let modaicsCharcoal = Color(red: 0.20, green: 0.18, blue: 0.16)
    
    /// Charcoal clay - slightly warmer text variant
    static let modaicsCharcoalClay = Color(red: 0.22, green: 0.20, blue: 0.17)
    
    /// Stone - secondary/muted text
    static let modaicsStone = Color(red: 0.50, green: 0.47, blue: 0.44)
    
    // MARK: - Semantic Aliases
    
    /// Primary background
    static let modaicsBackgroundPrimary: Color = .modaicsWarmSand
    
    /// Secondary background (cards, sheets)
    static let modaicsBackgroundSecondary: Color = .modaicsPaper
    
    /// Primary text
    static let modaicsTextPrimary: Color = .modaicsCharcoal
    
    /// Secondary text
    static let modaicsTextSecondary: Color = .modaicsStone
    
    /// Tertiary/subtle text
    static let modaicsTextTertiary: Color = .modaicsCharcoal.opacity(0.5)
    
    /// Primary accent
    static let modaicsAccent: Color = .modaicsTerracotta
    
    /// Success color
    static let modaicsSuccess: Color = .modaicsSage
    
    /// Error color
    static let modaicsError: Color = .modaicsRust
    
    /// Warning color
    static let modaicsWarning: Color = .modaicsOchre
}

// MARK: - Color Gradients

public extension LinearGradient {
    
    /// Warm gradient overlay for images
    static let modaicsWarmOverlay = LinearGradient(
        colors: [
            Color.modaicsWarmSand.opacity(0),
            Color.modaicsWarmSand.opacity(0.8),
            Color.modaicsWarmSand
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Terracotta accent gradient
    static let modaicsTerracottaGradient = LinearGradient(
        colors: [Color.modaicsTerracotta, Color.modaicsTerracotta.opacity(0.8)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Subtle warm gradient for backgrounds
    static let modaicsWarmGradient = LinearGradient(
        colors: [Color.modaicsWarmSand, Color.modaicsOatmeal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
