import SwiftUI
import Foundation

// MARK: - EventCard (Design System Primitive)
// Image (3:2) + date as plain text + serif title + venue + attendance.
// No category pill, no hashtag stack, no emoji icons.
// Used across Home, Discover, Community.

public struct DSEventCard: View {
    public let title: String
    public let venue: String
    public let dateLabel: String       // e.g. "May 7"
    public let typeLabel: String?      // e.g. "Exhibition" — sentence case, no pill
    public let attendees: Int?
    public let price: String?          // "Free" or "$25"
    public let imageURL: URL?
    public let width: CGFloat?         // nil = flexible

    public init(
        title: String,
        venue: String,
        dateLabel: String,
        typeLabel: String? = nil,
        attendees: Int? = nil,
        price: String? = nil,
        imageURL: URL? = nil,
        width: CGFloat? = nil
    ) {
        self.title      = title
        self.venue      = venue
        self.dateLabel  = dateLabel
        self.typeLabel  = typeLabel
        self.attendees  = attendees
        self.price      = price
        self.imageURL   = imageURL
        self.width      = width
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageArea

            VStack(alignment: .leading, spacing: 4) {
                // Date · Type line
                HStack(spacing: 4) {
                    Text(dateLabel)
                        .font(.labelM)
                        .foregroundColor(.brass)
                    if let type = typeLabel {
                        Text("·")
                            .font(.labelM)
                            .foregroundColor(.inkMuted)
                        Text(type)
                            .font(.labelM)
                            .foregroundColor(.inkMuted)
                    }
                }
                .padding(.top, 12)

                Text(title)
                    .font(.displayM)
                    .foregroundColor(.inkPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)

                Text(venue)
                    .font(.bodyS)
                    .foregroundColor(.inkSecondary)
                    .padding(.top, 2)

                Rectangle()
                    .fill(Color.hairline)
                    .frame(height: 0.5)
                    .padding(.vertical, 12)

                HStack {
                    if let att = attendees {
                        Text("\(att) going")
                            .font(.bodyS)
                            .foregroundColor(.inkSecondary)
                    }
                    Spacer()
                    if let price = price {
                        Text(price)
                            .font(.price)
                            .foregroundColor(.brass)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Color.canvas)
        }
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.hairline, lineWidth: 0.5)
        )
        .frame(width: width)
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

// MARK: - Convenience init from CommunityEvent
public extension DSEventCard {
    init(event: CommunityEvent, width: CGFloat? = nil) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let dateStr = formatter.string(from: event.startDate)

        let priceStr: String? = event.isFree ? "Free" : event.price.map { "$\(Int($0))" }

        self.init(
            title:     event.title,
            venue:     event.venueName,
            dateLabel: dateStr,
            typeLabel: event.type.displayName,
            attendees: event.attendees,
            price:     priceStr,
            imageURL:  event.imageURL.flatMap { URL(string: $0) },
            width:     width
        )
    }
}

// MARK: - Preview
#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 16) {
            DSEventCard(
                title: "Fashion Through the Ages",
                venue: "Melbourne Museum",
                dateLabel: "May 7",
                typeLabel: "Exhibition",
                attendees: 892,
                price: "$25",
                width: 280
            )
            DSEventCard(
                title: "Sustainable Clothing Swap",
                venue: "Newtown Community Centre",
                dateLabel: "May 22",
                typeLabel: "Swap meet",
                attendees: 89,
                price: "Free",
                width: 280
            )
        }
        .padding(20)
    }
    .background(Color.canvas)
}
