import SwiftUI

// MARK: - Modaics Typography (v3 — Editorial)
// Editorial serif (Playfair Display) for headlines ≥ 20pt.
// SF Pro for all body, UI, labels, captions.
// Monospaced is ELIMINATED — never use .monospaced anywhere.
// ALL CAPS only for: brand wordmark, labelS section headers with intentional tracking.

// MARK: - Playfair weight helper
public enum PlayfairWeight {
    case regular, medium, semiBold
    public var fontName: String {
        switch self {
        case .regular:  return "PlayfairDisplay-Regular"
        case .medium:   return "PlayfairDisplay-Medium"
        case .semiBold: return "PlayfairDisplay-SemiBold"
        }
    }
}

public extension Font {

    // MARK: — Editorial serif (Playfair Display — 20pt and above only)
    static func editorial(_ size: CGFloat, _ weight: PlayfairWeight = .regular) -> Font {
        .custom(weight.fontName, size: size)
    }
    static func editorialDisplay(_ size: CGFloat) -> Font { editorial(size, .regular) }
    static func editorialDisplayMedium(_ size: CGFloat) -> Font { editorial(size, .medium) }
    static func editorialDisplaySemiBold(_ size: CGFloat) -> Font { editorial(size, .semiBold) }

    static var displayXL  : Font { editorial(42) }   // hero greeting, screen titles
    static var displayL   : Font { editorial(32) }   // section headlines
    static var displayM   : Font { editorial(24) }   // editorial card headlines
    static var displayS   : Font { editorial(20) }   // smallest serif use — never below 20

    // Legacy editorial aliases
    static var editorialLarge  : Font { displayXL }
    static var editorialMedium : Font { displayL }
    static var editorialSmall  : Font { displayM }

    // MARK: — Sans body (SF Pro — everything functional)
    static func bodyText(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static var bodyL   : Font { bodyText(16) }
    static var bodyM   : Font { bodyText(15) }
    static var bodyS   : Font { bodyText(13) }
    static var labelM  : Font { bodyText(13, weight: .medium) }
    static var labelS  : Font { bodyText(11, weight: .medium) }   // tab labels, brand wordmark caps
    static var price   : Font { bodyText(14, weight: .medium) }

    // MARK: — Legacy bridge aliases
    // These map old names → new names so unported views compile.
    // Replace at call-site when editing a view.
    static var bodyLarge   : Font { bodyL }
    static var bodyMedium  : Font { bodyM }
    static var bodySmall   : Font { bodyS }
    static var uiLabel     : Font { labelM }
    static var uiLabelSmall: Font { labelS }
    static var priceLarge  : Font { bodyText(16, weight: .medium) }
    static var caption     : Font { bodyText(12) }
    static var captionSmall: Font { bodyText(11) }
    static var tabLabel    : Font { labelS }
    static var brandName   : Font { labelS }

    // Old forest* function names
    static func forestDisplay(_ size: CGFloat) -> Font { editorial(size) }
    static func forestHeadline(_ size: CGFloat) -> Font { bodyText(size, weight: .semibold) }
    static func forestBody(_ size: CGFloat) -> Font { bodyText(size) }
    static func forestCaption(_ size: CGFloat) -> Font { bodyText(size, weight: .medium) }

    static var forestDisplayLarge  : Font { displayXL }
    static var forestDisplayMedium : Font { displayL }
    static var forestDisplaySmall  : Font { displayM }
    static var forestHeadlineLarge : Font { bodyText(20, weight: .semibold) }
    static var forestHeadlineMedium: Font { bodyText(18, weight: .semibold) }
    static var forestHeadlineSmall : Font { bodyText(16, weight: .semibold) }
    static var forestBodyLarge     : Font { bodyL }
    static var forestBodyMedium    : Font { bodyM }
    static var forestBodySmall     : Font { bodyS }
    static var forestCaptionLarge  : Font { bodyText(13, weight: .medium) }
    static var forestCaptionMedium : Font { bodyText(11, weight: .medium) }
    static var forestCaptionSmall  : Font { bodyText(10, weight: .medium) }
}
