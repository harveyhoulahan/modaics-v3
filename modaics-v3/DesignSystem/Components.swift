import SwiftUI

// MARK: - Components.swift
// Legacy button-style wrappers that forward to the new design system primitives.
// New code: use PrimaryCTA / GhostCTA from DesignSystem/Primitives/CTAButtons.swift directly.

public struct EditorialPrimaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyM).fontWeight(.medium)
            .foregroundColor(.canvas)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.inkPrimary.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

public struct EditorialSecondaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyM).fontWeight(.medium)
            .foregroundColor(.inkPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.inkPrimary.opacity(0.3), lineWidth: 0.5)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

public struct EditorialAccentButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyM).fontWeight(.medium)
            .foregroundColor(.canvas)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.forest.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

// MARK: - Card modifiers
public struct EditorialCardModifier: ViewModifier {
    var hasBorder: Bool = false
    public func body(content: Content) -> some View {
        content
            .background(Color.canvasSecond)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .overlay(
                hasBorder
                    ? RoundedRectangle(cornerRadius: 2).stroke(Color.hairline, lineWidth: 0.5)
                    : nil
            )
    }
}

public struct ModaicsCardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content.modifier(EditorialCardModifier(hasBorder: false))
    }
}

public struct ModaicsElevatedCardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content.modifier(EditorialCardModifier(hasBorder: true))
    }
}

public extension View {
    func editorialCard(border: Bool = false) -> some View {
        modifier(EditorialCardModifier(hasBorder: border))
    }
}

// MARK: - Corner radius extension (kept for legacy chat bubbles only)
public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

public struct RoundedCorner: Shape {
    public var radius: CGFloat = .infinity
    public var corners: UIRectCorner = .allCorners
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
