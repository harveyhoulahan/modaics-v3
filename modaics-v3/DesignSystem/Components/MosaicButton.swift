import SwiftUI

// MARK: - MosaicButton
// Terracotta accent, rounded, warm and inviting
// Aesop + Kinfolk aesthetic: intentional, minimal, beautiful

public struct MosaicButton: View {
    public enum ButtonStyle {
        case primary      // Terracotta background, cream text
        case secondary    // Cream background, terracotta text
        case subtle       // Transparent, charcoal text
        case olive        // Deep olive accent
    }
    
    public enum ButtonSize {
        case small
        case medium
        case large
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 14
            case .large: return 18
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 24
            case .large: return 32
            }
        }
        
        var font: Font {
            switch self {
            case .small: return MosaicTypography.caption
            case .medium: return MosaicTypography.label
            case .large: return MosaicTypography.bodyEmphasis
            }
        }
    }
    
    let title: String
    let style: ButtonStyle
    let size: ButtonSize
    let action: () -> Void
    
    @State private var isPressed = false
    
    public init(
        _ title: String,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundColor(foregroundColor)
                .padding(.vertical, size.verticalPadding)
                .padding(.horizontal, size.horizontalPadding)
                .background(backgroundColor)
                .cornerRadius(MosaicLayout.cornerRadius)
                .scaleEffect(isPressed ? 0.97 : 1.0)
                .opacity(isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return MosaicColors.terracotta
        case .secondary:
            return MosaicColors.cream
        case .subtle:
            return Color.clear
        case .olive:
            return MosaicColors.deepOlive
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return MosaicColors.cream
        case .secondary:
            return MosaicColors.terracotta
        case .subtle:
            return MosaicColors.charcoalClay
        case .olive:
            return MosaicColors.cream
        }
    }
}

// MARK: - Icon Button Variant

public struct MosaicIconButton: View {
    let icon: String
    let action: () -> Void
    let size: CGFloat
    
    @State private var isPressed = false
    
    public init(
        icon: String,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(MosaicColors.charcoalClay)
                .frame(width: size, height: size)
                .background(MosaicColors.cream)
                .cornerRadius(size / 4)
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .mosaicShadow(MosaicLayout.shadowSmall)
                .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - SwiftUI Preview
#Preview {
    ScrollView {
        VStack(spacing: MosaicLayout.groupSpacing) {
            Text("Mosaic Buttons")
                .font(MosaicTypography.display)
                .foregroundColor(MosaicColors.textPrimary)
            
            // Primary buttons
            VStack(spacing: MosaicLayout.itemSpacing) {
                Text("Primary (Terracotta)")
                    .font(MosaicTypography.headline)
                    .foregroundColor(MosaicColors.textPrimary)
                
                HStack(spacing: MosaicLayout.itemSpacing) {
                    MosaicButton("Small", style: .primary, size: .small) {}
                    MosaicButton("Medium", style: .primary, size: .medium) {}
                    MosaicButton("Large", style: .primary, size: .large) {}
                }
            }
            
            // Secondary buttons
            VStack(spacing: MosaicLayout.itemSpacing) {
                Text("Secondary (Cream)")
                    .font(MosaicTypography.headline)
                    .foregroundColor(MosaicColors.textPrimary)
                
                HStack(spacing: MosaicLayout.itemSpacing) {
                    MosaicButton("Small", style: .secondary, size: .small) {}
                    MosaicButton("Medium", style: .secondary, size: .medium) {}
                    MosaicButton("Large", style: .secondary, size: .large) {}
                }
            }
            
            // Subtle buttons
            VStack(spacing: MosaicLayout.itemSpacing) {
                Text("Subtle (Minimal)")
                    .font(MosaicTypography.headline)
                    .foregroundColor(MosaicColors.textPrimary)
                
                HStack(spacing: MosaicLayout.itemSpacing) {
                    MosaicButton("Cancel", style: .subtle, size: .small) {}
                    MosaicButton("Learn More", style: .subtle, size: .medium) {}
                }
            }
            
            // Olive accent
            VStack(spacing: MosaicLayout.itemSpacing) {
                Text("Olive Accent")
                    .font(MosaicTypography.headline)
                    .foregroundColor(MosaicColors.textPrimary)
                
                MosaicButton("Discover Collection", style: .olive, size: .large) {}
            }
            
            // Icon buttons
            VStack(spacing: MosaicLayout.itemSpacing) {
                Text("Icon Buttons")
                    .font(MosaicTypography.headline)
                    .foregroundColor(MosaicColors.textPrimary)
                
                HStack(spacing: MosaicLayout.itemSpacing) {
                    MosaicIconButton(icon: "heart") {}
                    MosaicIconButton(icon: "bookmark") {}
                    MosaicIconButton(icon: "share") {}
                    MosaicIconButton(icon: "arrow.right") {}
                }
            }
        }
        .padding()
    }
    .background(MosaicColors.backgroundPrimary)
}
