import SwiftUI

// MARK: - Colors.swift
// All canonical colour tokens now live in DesignSystem/Tokens.swift.
// This file is retained only to avoid breaking project file references.
// Do NOT add new colours here. Use Tokens.swift.

// MARK: - Text style helpers (used by legacy views)
public extension Text {
    func brandNameStyle() -> some View {
        self
            .font(.labelS)
            .tracking(1.5)
            .textCase(.uppercase)
    }
}

// MARK: - Placeholder overlay helper (used by DiscoverView search bar)
public extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
