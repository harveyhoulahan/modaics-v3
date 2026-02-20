import SwiftUI

// MARK: - Modaics Typography
// Editorial serif (Playfair Display) for headlines
// System sans-serif (SF Pro) for body and UI
// Monospaced is ELIMINATED — do not use .monospaced anywhere

public extension Font {

    // MARK: - Editorial Display (Playfair Display — serif headlines only, 24pt+)
    // These create the "magazine" feeling. Use ONLY for large headlines.
    // Never use below 20pt — high-contrast serifs become illegible at small sizes.

    static func editorialDisplay(_ size: CGFloat) -> Font {
        .custom("PlayfairDisplay-Regular", size: size)
    }

    static func editorialDisplayMedium(_ size: CGFloat) -> Font {
        .custom("PlayfairDisplay-Medium", size: size)
    }

    static func editorialDisplaySemiBold(_ size: CGFloat) -> Font {
        .custom("PlayfairDisplay-SemiBold", size: size)
    }

    static var editorialLarge: Font { editorialDisplay(42) }    // Hero headlines
    static var editorialMedium: Font { editorialDisplay(32) }   // Section titles
    static var editorialSmall: Font { editorialDisplay(24) }    // Card headlines

    // MARK: - Body & UI (SF Pro — system default, clean sans-serif)
    // All functional text: navigation, labels, prices, descriptions, metadata

    static func bodyText(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static var bodyLarge: Font { bodyText(16) }
    static var bodyMedium: Font { bodyText(15) }
    static var bodySmall: Font { bodyText(13) }

    // MARK: - UI Labels (sentence case default, ALL CAPS only for brand names)
    static var uiLabel: Font { bodyText(14, weight: .medium) }
    static var uiLabelSmall: Font { bodyText(12, weight: .medium) }

    // MARK: - Captions & Metadata
    static var caption: Font { bodyText(12) }
    static var captionSmall: Font { bodyText(11) }

    // MARK: - Prices
    static var price: Font { bodyText(14, weight: .medium) }
    static var priceLarge: Font { bodyText(16, weight: .medium) }

    // MARK: - Tab Bar
    static var tabLabel: Font { bodyText(10, weight: .medium) }

    // MARK: - Brand Name (always ALL CAPS with tracking)
    static var brandName: Font { bodyText(11, weight: .medium) }
}

// MARK: - Legacy Compatibility Bridge
// These map old function names to new ones so the app compiles during migration.
// Agents working on specific views should replace these with the new names directly.
public extension Font {
    static func forestDisplay(_ size: CGFloat) -> Font { editorialDisplay(size) }
    static func forestHeadline(_ size: CGFloat) -> Font { bodyText(size, weight: .semibold) }
    static func forestBody(_ size: CGFloat) -> Font { bodyText(size) }
    static func forestCaption(_ size: CGFloat) -> Font { bodyText(size, weight: .medium) }

    static var forestDisplayLarge: Font { editorialLarge }
    static var forestDisplayMedium: Font { editorialMedium }
    static var forestDisplaySmall: Font { editorialSmall }
    static var forestHeadlineLarge: Font { bodyText(20, weight: .semibold) }
    static var forestHeadlineMedium: Font { bodyText(18, weight: .semibold) }
    static var forestHeadlineSmall: Font { bodyText(16, weight: .semibold) }
    static var forestBodyLarge: Font { bodyLarge }
    static var forestBodyMedium: Font { bodyMedium }
    static var forestBodySmall: Font { bodySmall }
    static var forestCaptionLarge: Font { bodyText(13, weight: .medium) }
    static var forestCaptionMedium: Font { bodyText(11, weight: .medium) }
    static var forestCaptionSmall: Font { bodyText(10, weight: .medium) }
    static var forestTabLabel: Font { tabLabel }

    // Legacy modaics* names
    static func modaicsDisplay(_ size: CGFloat) -> Font { editorialDisplay(size) }
    static func modaicsHeadline(_ size: CGFloat) -> Font { bodyText(size, weight: .semibold) }
    static func modaicsBody(_ size: CGFloat) -> Font { bodyText(size) }
    static func modaicsCaption(_ size: CGFloat) -> Font { bodyText(size, weight: .medium) }
}

// MARK: - Text Style Modifiers
public extension View {
    /// For brand names on cards: ALL CAPS, wide tracking, small sans-serif
    func brandNameStyle() -> some View {
        self
            .font(.brandName)
            .textCase(.uppercase)
            .tracking(1.5)
    }

    /// For section titles: sentence case, serif editorial
    func sectionTitleStyle() -> some View {
        self
            .font(.editorialSmall)
            .foregroundColor(.modaicsTextPrimary)
    }

    /// For short UI labels that ARE all-caps (nav labels, filter headers)
    func uiLabelCaps() -> some View {
        self
            .font(.uiLabelSmall)
            .textCase(.uppercase)
            .tracking(1.5)
    }

    // Legacy compatibility
    func forestCapsuleStyle() -> some View { uiLabelCaps() }
    func forestSectionTitle() -> some View { sectionTitleStyle() }
    func forestSectionSubtitle() -> some View {
        self.font(.caption).foregroundColor(.modaicsTextTertiary)
    }
}
