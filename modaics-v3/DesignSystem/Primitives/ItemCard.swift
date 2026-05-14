import SwiftUI

// MARK: - ItemCard (Design System Primitive)
// 3:4 image + brand caption + name + price.
// No badges, no eco leaf, no condition pill, no save heart.
// Condition and sustainability live on the detail view only.

public struct DSItemCard: View {
    public let brand: String?
    public let name: String
    public let price: Decimal?
    public let imageURL: URL?

    public init(
        brand: String? = nil,
        name: String,
        price: Decimal? = nil,
        imageURL: URL? = nil
    ) {
        self.brand   = brand
        self.name    = name
        self.price   = price
        self.imageURL = imageURL
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            imageArea
            infoArea
        }
    }

    // MARK: — Image
    private var imageArea: some View {
        Group {
            if let url = imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        emptyImagePlaceholder
                    }
                }
            } else {
                emptyImagePlaceholder
            }
        }
        .aspectRatio(3/4, contentMode: .fit)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }

    private var emptyImagePlaceholder: some View {
        Color.canvasSecond.overlay(
            Text(brand?.prefix(2).uppercased() ?? "")
                .font(.labelS)
                .tracking(1.5)
                .foregroundColor(.inkMuted)
        )
    }

    // MARK: — Info
    private var infoArea: some View {
        VStack(alignment: .leading, spacing: 3) {
            if let brand = brand, !brand.isEmpty {
                Text(brand)
                    .font(.labelS)
                    .tracking(1.5)
                    .textCase(.uppercase)
                    .foregroundColor(.inkSecondary)
                    .lineLimit(1)
            }
            Text(name)
                .font(.bodyM)
                .foregroundColor(.inkPrimary)
                .lineLimit(1)
            if let price = price {
                Text("$\(NSDecimalNumber(decimal: price).intValue)")
                    .font(.price)
                    .foregroundColor(.brass)
            }
        }
    }
}

// MARK: - Skeleton / loading state
public struct DSItemCardSkeleton: View {
    @State private var shimmer = false

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Color.canvasSecond
                .aspectRatio(3/4, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .opacity(shimmer ? 0.5 : 1.0)
                .animation(.easeInOut(duration: 0.9).repeatForever(), value: shimmer)
                .onAppear { shimmer = true }

            RoundedRectangle(cornerRadius: 2)
                .fill(Color.canvasSecond)
                .frame(width: 60, height: 10)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.canvasSecond)
                .frame(width: 90, height: 12)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.canvasSecond)
                .frame(width: 40, height: 10)
        }
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 16) {
        DSItemCard(brand: "Levi's", name: "Vintage Denim Jacket", price: 85)
        DSItemCard(brand: nil, name: "Silk Blouse", price: 180)
    }
    .padding(20)
    .background(Color.canvas)
}
