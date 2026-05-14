import SwiftUI

// MARK: - EditorialCard (Design System Primitive)
// Full-bleed image with serif headline overlay or below.
// Two variants: dark forest (feature) and light (sustainability / article).
// Used for "Moda's Edit", brand spotlights, sustainability features.

public enum EditorialCardVariant {
    case dark   // forest background — headline in sageWhite
    case light  // canvas background — headline in inkPrimary
}

public struct DSEditorialCard: View {
    public let headline: String
    public let subheadline: String?
    public let ctaLabel: String
    public let imageURL: URL?
    public let variant: EditorialCardVariant
    public let onCTATapped: () -> Void

    public init(
        headline: String,
        subheadline: String? = nil,
        ctaLabel: String = "Read",
        imageURL: URL? = nil,
        variant: EditorialCardVariant = .dark,
        onCTATapped: @escaping () -> Void = {}
    ) {
        self.headline     = headline
        self.subheadline  = subheadline
        self.ctaLabel     = ctaLabel
        self.imageURL     = imageURL
        self.variant      = variant
        self.onCTATapped  = onCTATapped
    }

    private var bgColor: Color    { variant == .dark ? .forest     : .canvas }
    private var headlineColor: Color { variant == .dark ? .sageWhite  : .inkPrimary }
    private var bodyColor: Color  { variant == .dark ? .sageMuted   : .inkSecondary }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image — 3:2, full bleed
            imageArea

            // Text block
            VStack(alignment: .leading, spacing: 8) {
                Text(headline)
                    .font(.displayM)
                    .foregroundColor(headlineColor)
                    .fixedSize(horizontal: false, vertical: true)

                if let sub = subheadline {
                    Text(sub)
                        .font(.bodyM)
                        .foregroundColor(bodyColor)
                }

                Button(action: onCTATapped) {
                    Text(ctaLabel)
                        .font(.labelM)
                        .foregroundColor(headlineColor)
                        .underline()
                }
                .padding(.top, 4)
            }
            .padding(20)
            .background(bgColor)
        }
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }

    private var imageArea: some View {
        Group {
            if let url = imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        Color.canvasSecond
                    }
                }
            } else {
                Color.canvasSecond
            }
        }
        .aspectRatio(3/2, contentMode: .fit)
        .clipped()
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        DSEditorialCard(
            headline: "Moda's Edit",
            subheadline: "This week's curated selection",
            ctaLabel: "Read →",
            variant: .dark
        )
        DSEditorialCard(
            headline: "Your impact",
            subheadline: "How your wardrobe is changing fashion.",
            ctaLabel: "Discover →",
            variant: .light
        )
    }
    .padding(20)
    .background(Color.canvas)
}
