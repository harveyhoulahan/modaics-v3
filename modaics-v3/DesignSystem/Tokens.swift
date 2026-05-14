import SwiftUI

// MARK: - Modaics Design Tokens
// Single source of truth for all colour values.
// All other colour files (Colors.swift) now re-export these aliases only.
// DO NOT add new colours here — extend the token set sparingly.

public extension Color {

    // MARK: — Base (light canvas — primary background for 4 of 5 tabs)
    static let canvas        = Color(hex: "FAF9F6")  // warm off-white
    static let canvasSecond  = Color(hex: "F0EDE5")  // ivory — secondary surface, inputs

    // MARK: — Ink (text, icons, CTAs on light surfaces)
    static let inkPrimary    = Color(hex: "1A1A1A")  // near-black
    static let inkSecondary  = Color(hex: "4A4A45")  // warm charcoal
    static let inkMuted      = Color(hex: "9A9A9A")  // inactive / placeholder

    // MARK: — Structure
    static let hairline      = Color(hex: "D4CFC7")  // 0.5pt borders, dividers

    // MARK: — Forest (feature surface — dark hero, Profile tab, editorial blocks)
    static let forest        = Color(hex: "1B3A2D")  // deep forest — dark hero surface
    static let forestDeep    = Color(hex: "0F2419")  // elevated dark surface
    static let hunter        = Color(hex: "355E3B")  // active state on dark backgrounds
    static let sage          = Color(hex: "9CAF88")  // sustainability tag text only
    static let sageWhite     = Color(hex: "F5F3EE")  // primary text on dark
    static let sageMuted     = Color(hex: "BFC7B8")  // secondary text on dark

    // MARK: — Accent (single accent — brass only)
    static let brass         = Color(hex: "C88A65")  // aged brass — price, active underline, wordmark
    static let brassDeep     = Color(hex: "9A7B37")  // burnished bronze — small icon accents

    // MARK: — Semantic
    static let semanticError    = Color(hex: "EF4444")
    static let semanticWarning  = Color(hex: "F59E0B")
    static let semanticSuccess  = Color(hex: "3DDC84")

    // ──────────────────────────────────────────────────────────────
    // LEGACY ALIASES
    // These exist solely so files not yet migrated continue to compile.
    // New code must use the tokens above directly.
    // ──────────────────────────────────────────────────────────────

    // Old gold family → brass
    static var luxeGold: Color          { .brass }
    static var luxeGoldBright: Color    { .brass }
    static var luxeGoldDeep: Color      { .brassDeep }
    static var goldText: Color          { .brass }
    static var brassText: Color         { .brass }
    static var agedBrass: Color         { .brass }
    static var agedBrassLight: Color    { .brass }
    static var burnishedBronze: Color   { .brassDeep }

    // Old background names → canvas (FORCED LIGHT)
    static var modaicsBackground: Color           { .canvas }
    static var modaicsBackgroundSecondary: Color  { .canvasSecond }
    static var modaicsBackgroundTertiary: Color   { .canvasSecond }
    static var modaicsWarmSand: Color             { .canvas }
    static var warmOffWhite: Color                { .canvas }
    static var ivory: Color                       { .canvasSecond }
    static var cream: Color                       { .canvasSecond }

    // Old surface names → canvasSecond / forest
    static var modaicsSurface: Color          { .canvasSecond }
    static var modaicsSurfaceHighlight: Color { .hairline }
    static var modaicsElevated: Color         { .forest }

    // Old primary/forest names → forest tokens
    static var modaicsPrimary: Color          { .forest }
    static var modaicsForest: Color           { .forest }
    static var modaicsRacingGreen: Color      { .hunter }
    static var modaicsEmerald: Color          { .hunter }
    static var modaicsMoss: Color             { .sage }
    static var modaicsOlive: Color            { .sage }
    static var modaicsSage: Color             { .sage }
    static var modaicsFern: Color             { .sage }
    static var forestRich: Color              { .forest }
    static var forestMid: Color               { .hunter }
    static var forestSoft: Color              { .hunter }

    // Old text names → ink tokens
    static var nearBlack: Color       { .inkPrimary }
    static var warmCharcoal: Color    { .inkSecondary }
    static var mutedGray: Color       { .inkMuted }
    static var warmDivider: Color     { .hairline }
    static var sageSubtle: Color      { .inkMuted }
    static var modaicsTextPrimary: Color    { .inkPrimary }
    static var modaicsTextSecondary: Color  { .inkSecondary }
    static var modaicsTextTertiary: Color   { .inkMuted }

    // Terracotta direction (deprecated) → brass
    static var modaicsTerracotta: Color     { .brass }
    static var modaicsDeepOlive: Color      { .forest }
    static var modaicsCharcoalClay: Color   { .inkPrimary }

    // Old semantic
    static var modaicsEco: Color     { .semanticSuccess }
    static var emerald: Color        { .semanticSuccess }
    static var natureTeal: Color     { .semanticSuccess }
    static var modaicsWarning: Color { .semanticWarning }
    static var modaicsError: Color   { .semanticError }

    // Metallic (retain for any existing references)
    static var modaicsChrome: Color   { .inkMuted }
    static var modaicsAluminum: Color { .inkMuted }
    static var modaicsPlatinum: Color { .canvas }
    static var modaicsGunmetal: Color { .inkSecondary }

    // MARK: — Background gradient (legacy — maps to flat canvas)
    static var forestBackground: LinearGradient {
        LinearGradient(colors: [.canvas, .canvasSecond], startPoint: .top, endPoint: .bottom)
    }

    // MARK: — Shimmer (editorial, neutral warm)
    static let editorialShimmer = LinearGradient(
        colors: [.clear, Color(hex: "D4CFC7").opacity(0.4), Color(hex: "D4CFC7").opacity(0.6),
                 Color(hex: "D4CFC7").opacity(0.4), .clear],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Animation tokens
public extension Animation {
    static let editorialSpring = Animation.spring(response: 0.3, dampingFraction: 0.8)
}

// MARK: - Hex initialiser (kept here; Colors.swift will forward to this)
internal extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
