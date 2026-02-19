import SwiftUI

// MARK: - Modaics Color Palette
/// The curated color system for Modaics v3.0
/// Warm, earthy tones that feel personal and intentional
extension Color {
    
    // MARK: - Primary Colors
    
    /// Terracotta — Warm, inviting, used for primary actions
    /// Evokes handcrafted ceramics and natural clay
    static let modaicsTerracotta = Color(red: 0.82, green: 0.45, blue: 0.35)
    
    /// Deep Olive — Sophisticated secondary, grounding element
    /// Represents growth, sustainability, nature
    static let modaicsDeepOlive = Color(red: 0.35, green: 0.42, blue: 0.32)
    
    // MARK: - Background Colors
    
    /// Warm Sand — Primary background
    /// Soft, paper-like, never stark white
    static let modaicsWarmSand = Color(red: 0.98, green: 0.96, blue: 0.94)
    
    /// Soft Clay — Alternative background, cards
    static let modaicsSoftClay = Color(red: 0.95, green: 0.92, blue: 0.89)
    
    // MARK: - Text Colors
    
    /// Charcoal Clay — Primary text, never pure black
    /// Easy on the eyes, sophisticated
    static let modaicsCharcoalClay = Color(red: 0.25, green: 0.24, blue: 0.23)
    
    /// Warm Stone — Secondary text, hints
    static let modaicsWarmStone = Color(red: 0.55, green: 0.52, blue: 0.49)
    
    // MARK: - Accent Colors
    
    /// Sage — Soft green for success states
    static let modaicsSage = Color(red: 0.58, green: 0.70, blue: 0.60)
    
    /// Rust — Deeper terracotta for emphasis
    static let modaicsRust = Color(red: 0.72, green: 0.38, blue: 0.28)
    
    /// Cream — Light accent for highlights
    static let modaicsCream = Color(red: 0.99, green: 0.98, blue: 0.96)
    
    // MARK: - Semantic Colors
    
    /// Success — Positive feedback
    static let modaicsSuccess = Color(red: 0.35, green: 0.65, blue: 0.40)
    
    /// Warning — Cautionary feedback
    static let modaicsWarning = Color(red: 0.95, green: 0.70, blue: 0.25)
    
    /// Error — Critical feedback
    static let modaicsError = Color(red: 0.85, green: 0.35, blue: 0.35)
    
    // MARK: - Gradient Helpers
    
    /// Warm gradient for hero sections
    static var modaicsWarmGradient: LinearGradient {
        LinearGradient(
            colors: [modaicsWarmSand, modaicsSoftClay],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    /// Terracotta gradient for CTAs
    static var modaicsTerracottaGradient: LinearGradient {
        LinearGradient(
            colors: [modaicsTerracotta, modaicsRust],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - UIColor Extensions (for UIKit compatibility)
extension UIColor {
    static let modaicsTerracotta = UIColor(red: 0.82, green: 0.45, blue: 0.35, alpha: 1.0)
    static let modaicsDeepOlive = UIColor(red: 0.35, green: 0.42, blue: 0.32, alpha: 1.0)
    static let modaicsWarmSand = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0)
    static let modaicsCharcoalClay = UIColor(red: 0.25, green: 0.24, blue: 0.23, alpha: 1.0)
}