import SwiftUI

// MARK: - Modaics Typography
/// Monospaced fonts throughout — clean, technical, luxury aesthetic
public extension Font {
    
    // MARK: - Display (Large Titles)
    static func forestDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    static var forestDisplayLarge: Font { forestDisplay(36) }
    static var forestDisplayMedium: Font { forestDisplay(28) }
    static var forestDisplaySmall: Font { forestDisplay(22) }
    
    // MARK: - Headlines (Section Titles)
    static func forestHeadline(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    static var forestHeadlineLarge: Font { forestHeadline(20) }
    static var forestHeadlineMedium: Font { forestHeadline(18) }
    static var forestHeadlineSmall: Font { forestHeadline(16) }
    
    // MARK: - Body
    static func forestBody(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    static var forestBodyLarge: Font { forestBody(16) }
    static var forestBodyMedium: Font { forestBody(14) }
    static var forestBodySmall: Font { forestBody(12) }
    
    // MARK: - Captions / Labels (ALL CAPS with tracking)
    static func forestCaption(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    static var forestCaptionLarge: Font { forestCaption(13) }
    static var forestCaptionMedium: Font { forestCaption(11) }
    static var forestCaptionSmall: Font { forestCaption(10) }
    
    // MARK: - Tab Labels (All caps, spaced)
    static var forestTabLabel: Font {
        .system(size: 10, weight: .semibold, design: .monospaced)
    }
}

// MARK: - Text Modifiers
public extension View {
    func forestCapsuleStyle() -> some View {
        self
            .font(.forestCaptionMedium)
            .textCase(.uppercase)
            .tracking(1.2)
    }
    
    func forestSectionTitle() -> some View {
        self
            .font(.forestHeadlineMedium)
            .foregroundColor(.sageWhite)
    }
    
    func forestSectionSubtitle() -> some View {
        self
            .font(.forestCaptionMedium)
            .foregroundColor(.sageMuted)
    }
}