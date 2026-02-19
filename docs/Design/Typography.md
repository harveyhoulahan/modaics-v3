# Modaics Typography

> *"Editorial elegance meets digital readability"*

Our typography system combines the warmth of serif headings with the clarity of sans-serif body text—creating a sophisticated editorial feel that's still highly readable on digital devices.

---

## 🔤 Font Families

### Primary: Lora (Serif)
**Usage**: Headings, display text, brand moments

Lora is a modern serif typeface with calligraphic roots. Its warm, organic letterforms evoke the feeling of a fashion editorial while maintaining excellent screen readability.

| Attribute | Value |
|-----------|-------|
| **Designer** | Cyreal |
| **Classification** | Transitional serif |
| **Mood** | Warm, editorial, sophisticated |
| **Best for** | Headlines, titles, quotes |

**Weights Available**:
- Regular (400)
- Medium (500)
- SemiBold (600)
- Bold (700)

**iOS Import**:
```swift
// Via Google Fonts or embedded
.custom("Lora", size: 28, weight: .semibold)
```

---

### Secondary: Nunito (Sans-serif)
**Usage**: Body text, UI elements, captions

Nunito is a well-balanced sans-serif with rounded terminals. It offers excellent readability at small sizes and pairs beautifully with Lora's more expressive forms.

| Attribute | Value |
|-----------|-------|
| **Designer** | Vernon Adams |
| **Classification** | Humanist sans-serif |
| **Mood** | Friendly, clean, approachable |
| **Best for** | Body copy, buttons, labels |

**Weights Available**:
- Light (300)
- Regular (400)
- Medium (500)
- SemiBold (600)
- Bold (700)
- ExtraBold (800)

**iOS Import**:
```swift
// Via Google Fonts or embedded
.custom("Nunito", size: 16, weight: .regular)
```

---

## 📏 Type Scale

### Display Sizes
| Style | Font | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|------|--------|-------------|----------------|-------|
| **Hero** | Lora | 48pt | Bold | 1.1 | -0.5 | Splash screen, major headlines |
| **Display** | Lora | 36pt | SemiBold | 1.2 | -0.3 | Section headers, onboarding |
| **Title 1** | Lora | 28pt | SemiBold | 1.3 | -0.2 | Screen titles |
| **Title 2** | Lora | 24pt | Medium | 1.3 | -0.1 | Card titles, modals |
| **Title 3** | Lora | 20pt | Medium | 1.4 | 0 | Subsection headers |

### Body Sizes
| Style | Font | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|------|--------|-------------|----------------|-------|
| **Body Large** | Nunito | 18pt | Regular | 1.6 | 0 | Lead paragraphs, important body |
| **Body** | Nunito | 16pt | Regular | 1.6 | 0 | Standard body text |
| **Body Small** | Nunito | 14pt | Regular | 1.5 | 0.1 | Secondary content |
| **Caption** | Nunito | 12pt | Medium | 1.4 | 0.2 | Labels, timestamps |
| **Overline** | Nunito | 11pt | SemiBold | 1.2 | 0.5 | Category tags, all caps |

### UI Text
| Style | Font | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|------|--------|-------------|----------------|-------|
| **Button Large** | Nunito | 18pt | SemiBold | 1.0 | 0.5 | Primary CTAs |
| **Button** | Nunito | 16pt | SemiBold | 1.0 | 0.3 | Standard buttons |
| **Button Small** | Nunito | 14pt | SemiBold | 1.0 | 0.2 | Icon buttons, chips |
| **Nav Label** | Nunito | 12pt | Medium | 1.0 | 0.2 | Tab bar, nav items |
| **Input** | Nunito | 16pt | Regular | 1.4 | 0 | Form fields |
| **Input Label** | Nunito | 14pt | Medium | 1.2 | 0.1 | Field labels |

---

## 🎯 Typography Patterns

### Headline + Body Pairing
```
Title 1 (Lora 28pt SemiBold)
───────────────────────────
Body Large (Nunito 18pt Regular)
Comfortable reading width with generous 
line height for extended content.
```

### Card Layout
```
Title 3 (Lora 20pt Medium)
Caption (Nunito 12pt Medium) · Metadata
─────────────────────────────────────────
Body Small (Nunito 14pt Regular)
Brief description or supporting content
that spans multiple lines if needed.
```

### Button Styles
```
[BUTTON LARGE]  Nunito 18pt SemiBold, All caps
[Button]        Nunito 16pt SemiBold, Title case
[Small]         Nunito 14pt SemiBold, Title case
```

### Editorial Quote
```
"Style is a way to say who you 
are without having to speak."

    — Display (Lora 24pt Medium)
      Caption (Nunito 12pt Medium) for attribution
```

---

## 📱 Platform Guidelines

### iOS (SwiftUI)

Create a typography extension:

```swift
import SwiftUI

extension Font {
    // Display
    static let modaicsHero = Font.custom("Lora-Bold", size: 48)
    static let modaicsDisplay = Font.custom("Lora-SemiBold", size: 36)
    static let modaicsTitle1 = Font.custom("Lora-SemiBold", size: 28)
    static let modaicsTitle2 = Font.custom("Lora-Medium", size: 24)
    static let modaicsTitle3 = Font.custom("Lora-Medium", size: 20)
    
    // Body
    static let modaicsBodyLarge = Font.custom("Nunito-Regular", size: 18)
    static let modaicsBody = Font.custom("Nunito-Regular", size: 16)
    static let modaicsBodySmall = Font.custom("Nunito-Regular", size: 14)
    static let modaicsCaption = Font.custom("Nunito-Medium", size: 12)
    static let modaicsOverline = Font.custom("Nunito-SemiBold", size: 11)
    
    // UI
    static let modaicsButtonLarge = Font.custom("Nunito-SemiBold", size: 18)
    static let modaicsButton = Font.custom("Nunito-SemiBold", size: 16)
    static let modaicsButtonSmall = Font.custom("Nunito-SemiBold", size: 14)
    static let modaicsNavLabel = Font.custom("Nunito-Medium", size: 12)
    static let modaicsInput = Font.custom("Nunito-Regular", size: 16)
    static let modaicsInputLabel = Font.custom("Nunito-Medium", size: 14)
}
```

### Dynamic Type Support

Support iOS Dynamic Type for accessibility:

```swift
struct ScaledFont: ViewModifier {
    var name: String
    var size: CGFloat
    var weight: Font.Weight
    
    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(name, size: scaledSize, relativeTo: .body))
    }
}
```

---

## ♿ Accessibility

### Minimum Sizes
- **Body text**: Never smaller than 14pt
- **Captions/labels**: Never smaller than 11pt
- **Buttons**: Minimum 16pt for primary actions

### Line Height
- **Body text**: Minimum 1.5 line height (1.6 preferred)
- **Headlines**: Minimum 1.2 line height

### Contrast
- Text must meet WCAG AA standards (4.5:1 for normal text, 3:1 for large text)
- See [ColorPalette.md](./ColorPalette.md) for approved color combinations

### Dynamic Type
- Support at least 2x scaling (up to AX5 preferred)
- Test all text sizes in Accessibility Inspector
- Ensure layouts don't break at large sizes

---

## 🌍 Localization Notes

- German text may expand 20-30%—ensure sufficient space
- Avoid tight leading for languages with diacritics
- Support right-to-left (RTL) layouts for Arabic/Hebrew
- Use system font as fallback for non-Latin scripts

---

## 📦 Font Loading

### iOS Setup

1. Add font files to Xcode project
2. Include in target's "Copy Bundle Resources"
3. Add to `Info.plist`:
```xml
<key>UIAppFonts</key>
<array>
    <string>Lora-Regular.ttf</string>
    <string>Lora-Medium.ttf</string>
    <string>Lora-SemiBold.ttf</string>
    <string>Lora-Bold.ttf</string>
    <string>Nunito-Light.ttf</string>
    <string>Nunito-Regular.ttf</string>
    <string>Nunito-Medium.ttf</string>
    <string>Nunito-SemiBold.ttf</string>
    <string>Nunito-Bold.ttf</string>
    <string>Nunito-ExtraBold.ttf</string>
</array>
```

### Web (Future)

```css
@import url('https://fonts.googleapis.com/css2?family=Lora:wght@400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&display=swap');
```

---

## 🎨 Typography Do's and Don'ts

### ✅ Do
- Use Lora for headlines and display text
- Use Nunito for all body and UI text
- Maintain consistent hierarchy across screens
- Allow generous line height for readability
- Test at various Dynamic Type sizes

### ❌ Don't
- Use more than 2 font families
- Use Lora for body text or small sizes
- Use all caps for body text (UI only)
- Go below minimum font sizes
- Stretch or compress fonts

---

*Last updated: February 2026*
