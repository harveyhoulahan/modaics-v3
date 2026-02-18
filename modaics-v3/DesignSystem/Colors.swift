import SwiftUI

// MARK: - Modaics v3.0 Color System
// Mediterranean warmth aesthetic: Aesop + Kinfolk + Le Labo
// Rules: NO gradients, NO pure white/black, warm tones only

public struct MosaicColors {
    
    // MARK: - Primary Palette
    
    /// Terracotta - Primary accent for CTAs, highlights, brand moments
    public static let terracotta = Color(hex: "#C2703E")
    
    /// Warm Sand - Primary background, creates that sun-baked Mediterranean feel
    public static let warmSand = Color(hex: "#E8D5B7")
    
    /// Deep Olive - Secondary accent for sophistication and depth
    public static let deepOlive = Color(hex: "#5B6B4A")
    
    /// Charcoal Clay - Primary text color, warm and grounded
    public static let charcoalClay = Color(hex: "#3B3632")
    
    /// Cream - Light backgrounds, cards, elevated surfaces
    public static let cream = Color(hex: "#F5F0E8")
    
    // MARK: - Supporting Colors
    
    /// Burnt Sienna - Warm accent for emphasis, complementary to terracotta
    public static let burntSienna = Color(hex: "#A0522D")
    
    /// Sage - Natural, calming accent for secondary elements
    public static let sage = Color(hex: "#9CAF88")
    
    /// Oatmeal - Neutral background alternative, softer than cream
    public static let oatmeal = Color(hex: "#E6DCC8")
    
    /// Burgundy - Deep accent for luxury moments, sparing use
    public static let burgundy = Color(hex: "#722F37")
    
    // MARK: - Semantic Colors
    
    /// Primary background for screens
    public static let backgroundPrimary = warmSand
    
    /// Secondary background for cards and elevated surfaces
    public static let backgroundSecondary = cream
    
    /// Tertiary background for subtle differentiation
    public static let backgroundTertiary = oatmeal
    
    /// Primary text color
    public static let textPrimary = charcoalClay
    
    /// Secondary text for captions, metadata
    public static let textSecondary = charcoalClay.opacity(0.65)
    
    /// Tertiary text for hints, placeholders
    public static let textTertiary = charcoalClay.opacity(0.40)
    
    /// Accent for interactive elements
    public static let accentPrimary = terracotta
    
    /// Secondary accent for variety
    public static let accentSecondary = deepOlive
    
    /// Success states - muted sage green
    public static let success = sage
    
    /// Error states - muted terracotta
    public static let error = burntSienna
    
    /// Warning states - warm amber
    public static let warning = Color(hex: "#D4A574")
    
    // MARK: - Divider & Border
    
    /// Subtle dividers
    public static let divider = charcoalClay.opacity(0.08)
    
    /// Border for inputs and cards
    public static let border = charcoalClay.opacity(0.12)
    
    /// Focused border
    public static let borderFocused = terracotta.opacity(0.50)
    
    // MARK: - Shadow
    
    /// Subtle shadow color - warm tinted
    public static let shadow = Color(hex: "#3B3632").opacity(0.08)
}

// MARK: - Color Extension for Hex Support
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

// MARK: - SwiftUI Preview
#Preview {
    ScrollView {
        VStack(spacing: 24) {
            Text("Modaics Color Palette")
                .font(.system(.title, design: .serif))
                .foregroundColor(MosaicColors.textPrimary)
            
            ColorSection(title: "Primary", colors: [
                ("Terracotta", MosaicColors.terracotta),
                ("Warm Sand", MosaicColors.warmSand),
                ("Deep Olive", MosaicColors.deepOlive),
                ("Charcoal Clay", MosaicColors.charcoalClay),
                ("Cream", MosaicColors.cream),
            ])
            
            ColorSection(title: "Supporting", colors: [
                ("Burnt Sienna", MosaicColors.burntSienna),
                ("Sage", MosaicColors.sage),
                ("Oatmeal", MosaicColors.oatmeal),
                ("Burgundy", MosaicColors.burgundy),
            ])
            
            ColorSection(title: "Semantic", colors: [
                ("Background Primary", MosaicColors.backgroundPrimary),
                ("Background Secondary", MosaicColors.backgroundSecondary),
                ("Text Primary", MosaicColors.textPrimary),
                ("Accent Primary", MosaicColors.accentPrimary),
                ("Success", MosaicColors.success),
            ])
        }
        .padding()
    }
    .background(MosaicColors.backgroundPrimary)
}

struct ColorSection: View {
    let title: String
    let colors: [(String, Color)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(.headline, design: .serif))
                .foregroundColor(MosaicColors.textPrimary)
            
            ForEach(colors, id: \.0) { name, color in
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: 48, height: 48)
                    
                    Text(name)
                        .font(.system(.body, design: .serif))
                        .foregroundColor(MosaicColors.textPrimary)
                    
                    Spacer()
                }
            }
        }
    }
}
