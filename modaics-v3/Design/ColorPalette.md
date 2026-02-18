# Modaics Color Palette

> *"Earthy sophistication meets modern minimalism"*

Our color palette draws inspiration from natural materials—terracotta pottery, sandy beaches, olive groves, and warm cream. These colors evoke a sense of calm sophistication while remaining warm and approachable.

---

## 🎨 Primary Colors

### Terracotta
**The signature color.** Warm, earthy, grounded.

| Variant | Hex | RGB | Usage |
|---------|-----|-----|-------|
| **Terracotta 900** | `#8B4513` | `139, 69, 19` | Dark accents, emphasis |
| **Terracotta 700** | `#A0522D` | `160, 82, 45` | Primary buttons, CTAs |
| **Terracotta 500** | `#CD853F` | `205, 133, 63` | Brand color, icons |
| **Terracotta 300** | `#DEB887` | `222, 184, 135` | Hover states, highlights |
| **Terracotta 100** | `#F5DEB3` | `245, 222, 179` | Backgrounds, light fills |

---

### Sand
**Neutral warmth.** Versatile, calming, sophisticated.

| Variant | Hex | RGB | Usage |
|---------|-----|-----|-------|
| **Sand 900** | `#8B7355` | `139, 115, 85` | Dark text on light backgrounds |
| **Sand 700** | `#A0826D` | `160, 130, 109` | Secondary text |
| **Sand 500** | `#C2B280` | `194, 178, 128` | Borders, dividers |
| **Sand 300** | `#D4C4A8` | `212, 196, 168` | Card backgrounds |
| **Sand 100** | `#F5F5DC` | `245, 245, 220` | Page backgrounds |
| **Sand 50** | `#FAF9F6` | `250, 249, 246` | App background, pure white alternative |

---

### Olive
**Natural balance.** Organic, fresh, grounded.

| Variant | Hex | RGB | Usage |
|---------|-----|-----|-------|
| **Olive 900** | `#556B2F` | `85, 107, 47` | Dark accents |
| **Olive 700** | `#6B8E23` | `107, 142, 35` | Success states |
| **Olive 500** | `#808000` | `128, 128, 0` | Tags, labels |
| **Olive 300** | `#9ACD32` | `154, 205, 50` | Highlights, badges |
| **Olive 100** | `#F0E68C` | `240, 230, 140` | Light backgrounds |

---

## 🎨 Secondary Colors

### Cream
**Light and airy.** Clean, fresh, spacious.

| Variant | Hex | RGB | Usage |
|---------|-----|-----|-------|
| **Cream 900** | `#D4C5B9` | `212, 197, 185` | Subtle text |
| **Cream 500** | `#F5F5DC` | `245, 245, 220` | Card backgrounds |
| **Cream 100** | `#FFFDD0` | `255, 253, 208` | Light fills |
| **Cream 50** | `#FFFEF0` | `255, 254, 240` | Pure background |

---

### Charcoal
**Grounding darkness.** Professional, readable, strong.

| Variant | Hex | RGB | Usage |
|---------|-----|-----|-------|
| **Charcoal 900** | `#1A1A1A` | `26, 26, 26` | Primary text |
| **Charcoal 700** | `#333333` | `51, 51, 51` | Headings |
| **Charcoal 500** | `#4A4A4A` | `74, 74, 74` | Secondary text |
| **Charcoal 300** | `#808080` | `128, 128, 128` | Placeholder text |
| **Charcoal 100** | `#CCCCCC` | `204, 204, 204` | Disabled states |
| **Charcoal 50** | `#F5F5F5` | `245, 245, 245` | Subtle backgrounds |

---

### Clay
**Warm neutral.** Approachable, organic, versatile.

| Variant | Hex | RGB | Usage |
|---------|-----|-----|-------|
| **Clay 900** | `#B85C38` | `184, 92, 56` | Destructive actions |
| **Clay 700** | `#D4755F` | `212, 117, 95` | Warnings |
| **Clay 500** | `#E89880` | `232, 152, 128` | Error states |
| **Clay 300** | `#F5C6B5` | `245, 198, 181` | Light warnings |
| **Clay 100** | `#FDF2EE` | `253, 242, 238` | Error backgrounds |

---

## 🎨 Functional Colors

### Success
- **Green 500**: `#6B8E23` — Success messages, confirmations
- **Green 100**: `#E8F5E9` — Success backgrounds

### Warning
- **Amber 500**: `#D4755F` — Warning messages
- **Amber 100**: `#FFF3E0` — Warning backgrounds

### Error
- **Red 500**: `#B85C38` — Error messages, destructive actions
- **Red 100**: `#FDF2EE` — Error backgrounds

### Info
- **Blue 500**: `#5B8BA0` — Informational messages
- **Blue 100**: `#E3F2FD` — Info backgrounds

---

## 🎨 Usage Guidelines

### Background Hierarchy
1. **Page Background**: Sand 50 or Cream 50
2. **Card Background**: Sand 100 or Cream 100
3. **Elevated Cards**: White with subtle shadow
4. **Input Fields**: White or Cream 50

### Text Hierarchy
1. **Primary Text**: Charcoal 900
2. **Secondary Text**: Charcoal 500
3. **Tertiary/Placeholder**: Charcoal 300
4. **Disabled**: Charcoal 100
5. **Links**: Terracotta 700 (hover: Terracotta 500)

### Interactive Elements
1. **Primary Button**: Terracotta 700 background, White text
2. **Secondary Button**: Transparent, Terracotta 700 border and text
3. **Tertiary Button**: Transparent, Charcoal 700 text
4. **Hover States**: Darken 10% or add subtle shadow
5. **Disabled**: Charcoal 100 background, Charcoal 300 text

### Accent Usage
- Use **Terracotta** for primary actions and brand moments
- Use **Olive** for success states and eco-friendly messaging
- Use **Clay** sparingly for warnings and errors
- Use **Charcoal** for text and UI structure

---

## 🎨 Accessibility

All color combinations must meet WCAG 2.1 AA standards:

| Combination | Ratio | Pass |
|-------------|-------|------|
| Charcoal 900 on Sand 50 | 15.8:1 | ✅ AAA |
| Charcoal 500 on Sand 50 | 7.2:1 | ✅ AA |
| White on Terracotta 700 | 4.8:1 | ✅ AA |
| Charcoal 900 on Terracotta 100 | 11.2:1 | ✅ AAA |

Always test your specific color combinations for accessibility.

---

## 🎨 Platform Notes

### iOS
Use system adaptive colors where appropriate, map to our palette:
```swift
// Example Swift color definitions
extension Color {
    static let modaicsTerracotta = Color(red: 0.627, green: 0.322, blue: 0.176)
    static let modaicsSand = Color(red: 0.961, green: 0.957, blue: 0.965)
    // ... etc
}
```

### Web (Future)
Use CSS custom properties:
```css
:root {
  --color-terracotta-700: #A0522D;
  --color-sand-50: #FAF9F6;
  /* ... etc */
}
```

---

*Last updated: February 2026*
