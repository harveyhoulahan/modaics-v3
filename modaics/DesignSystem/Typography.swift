import SwiftUI

// MARK: - Modaics Typography
/// Editorial spacing and typography
/// Asymmetric layouts with careful attention to hierarchy
extension Font {
    
    // MARK: - Display Fonts
    /// Large, impactful headlines
    /// Used sparingly for major section titles
    
    static func modaicsDisplayLarge(size: CGFloat = 40) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
    
    static func modaicsDisplayMedium(size: CGFloat = 32) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }
    
    static func modaicsDisplaySmall(size: CGFloat = 24) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }
    
    // MARK: - Heading Fonts
    /// Section headers, card titles
    
    static func modaicsHeadingBold(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    
    static func modaicsHeadingSemiBold(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    static func modaicsHeadingMedium(size: CGFloat = 18) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    // MARK: - Body Fonts
    /// Primary reading text
    
    static func modaicsBodySemiBold(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    static func modaicsBodyMedium(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    static func modaicsBodyRegular(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    // MARK: - Caption Fonts
    /// Supporting text, metadata
    
    static func modaicsCaptionMedium(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    static func modaicsCaptionRegular(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    // MARK: - Button Fonts
    /// Action text
    
    static func modaicsButtonLarge() -> Font {
        .system(size: 18, weight: .semibold, design: .default)
    }
    
    static func modaicsButtonMedium() -> Font {
        .system(size: 16, weight: .semibold, design: .default)
    }
    
    static func modaicsButtonSmall() -> Font {
        .system(size: 14, weight: .medium, design: .default)
    }
}

// MARK: - Text Style Modifiers
extension View {
    /// Applies standard editorial line spacing
    func editorialLineSpacing() -> some View {
        self.lineSpacing(4)
    }
    
    /// Asymmetric padding for editorial layouts
    func editorialPadding() -> some View {
        self.padding(.horizontal, 24)
    }
}