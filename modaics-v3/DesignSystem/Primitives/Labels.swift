import SwiftUI

// MARK: - SectionLabel (Design System Primitive)
// Small caps optional, labelS, tracking +1.5, inkPrimary or sageMuted on dark.
// e.g. "Trending now", "Picked for you"

public struct SectionLabel: View {
    public let text: String
    public let onDark: Bool

    public init(_ text: String, onDark: Bool = false) {
        self.text   = text
        self.onDark = onDark
    }

    public var body: some View {
        Text(text)
            .font(.labelS)
            .tracking(1.5)
            .textCase(.uppercase)
            .foregroundColor(onDark ? .sageMuted : .inkPrimary)
    }
}

// MARK: - UnderlineFilter (Design System Primitive)
// Text label. Near-black + 1pt underline when selected; muted when not.
// No pill backgrounds.

public struct UnderlineFilter: View {
    public let label: String
    public let isSelected: Bool
    public let useBrass: Bool
    public let action: () -> Void

    public init(
        _ label: String,
        isSelected: Bool,
        useBrass: Bool = true,
        action: @escaping () -> Void
    ) {
        self.label      = label
        self.isSelected = isSelected
        self.useBrass   = useBrass
        self.action     = action
    }

    private var activeColor: Color { useBrass ? .brass : .inkPrimary }

    public var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.labelM)
                    .foregroundColor(isSelected ? activeColor : .inkMuted)

                Rectangle()
                    .fill(isSelected ? activeColor : Color.clear)
                    .frame(height: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(minWidth: 44, minHeight: 44)
    }
}

// MARK: - Preview
#Preview {
    VStack(alignment: .leading, spacing: 24) {
        SectionLabel("Trending now")
        SectionLabel("Your collection", onDark: true)
            .padding(12)
            .background(Color.forest)

        HStack(spacing: 24) {
            UnderlineFilter("Clothing", isSelected: true) {}
            UnderlineFilter("Events", isSelected: false) {}
            UnderlineFilter("Workshops", isSelected: false) {}
        }
    }
    .padding(20)
    .background(Color.canvas)
}
