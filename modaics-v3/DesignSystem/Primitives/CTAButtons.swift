import SwiftUI

// MARK: - PrimaryCTA (Design System Primitive)
// Full-width near-black background, off-white text, bodyM medium, 0pt radius.
// Pressed state: opacity 0.85.

public struct PrimaryCTA: View {
    public let label: String
    public let isLoading: Bool
    public let isEnabled: Bool
    public let action: () -> Void

    public init(
        _ label: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.label     = label
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action    = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    HStack(spacing: 8) {
                        ProgressView().tint(.canvas)
                        Text(label).font(.bodyM).fontWeight(.medium)
                    }
                } else {
                    Text(label).font(.bodyM).fontWeight(.medium)
                }
            }
            .foregroundColor(.canvas)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.inkPrimary.opacity(isEnabled ? 1 : 0.4))
            .clipShape(RoundedRectangle(cornerRadius: 2))
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(PressOpacityStyle())
    }
}

// MARK: - GhostCTA (Design System Primitive)
// Transparent with 0.5pt hairline border, inkPrimary text.
// For secondary actions.

public struct GhostCTA: View {
    public let label: String
    public let action: () -> Void

    public init(_ label: String, action: @escaping () -> Void) {
        self.label  = label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(label)
                .font(.bodyM).fontWeight(.medium)
                .foregroundColor(.inkPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.inkPrimary.opacity(0.3), lineWidth: 0.5)
                )
        }
        .buttonStyle(PressOpacityStyle())
    }
}

// MARK: - Press opacity button style (shared)
public struct PressOpacityStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.85 : 1)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        PrimaryCTA("Create listing") {}
        GhostCTA("Make offer") {}
        PrimaryCTA("Submitting...", isLoading: true) {}
        PrimaryCTA("Disabled", isEnabled: false) {}
    }
    .padding(20)
    .background(Color.canvas)
}
