import SwiftUI

// MARK: - EventListCard
/// Card component for displaying community events in list views
public struct EventListCard: View {
    let event: CommunityEvent
    let onTap: () -> Void
    let onAttendTap: (() -> Void)?
    
    public init(
        event: CommunityEvent,
        onTap: @escaping () -> Void = {},
        onAttendTap: (() -> Void)? = nil
    ) {
        self.event = event
        self.onTap = onTap
        self.onAttendTap = onAttendTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image Header
                ZStack(alignment: .topLeading) {
                    // Event Image
                    eventImage
                    
                    // Type Badge
                    EventTypeBadge(type: event.type)
                        .padding(12)
                    
                    // Date Badge
                    DateBadge(date: event.startDate)
                        .padding(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    
                    // Free Badge (if free)
                    if event.isFree {
                        FreeBadge()
                            .padding(12)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    }
                }
                .frame(height: 160)
                
                // Content
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(event.title)
                        .font(.forestHeadlineSmall)
                        .foregroundColor(.sageWhite)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Venue
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.luxeGold)
                        
                        Text(event.venueName)
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                            .lineLimit(1)
                    }
                    
                    // Organizer
                    HStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.modaicsFern)
                        
                        Text(event.organizerName)
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                            .lineLimit(1)
                    }
                    
                    // Tags
                    if !event.tags.isEmpty {
                        FlowLayout(spacing: 6) {
                            ForEach(event.tags.prefix(3), id: \.self) { tag in
                                TagChip(tag: tag)
                            }
                        }
                    }
                    
                    Divider()
                        .background(Color.modaicsSurfaceHighlight)
                    
                    // Footer
                    HStack {
                        // Attendees
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.modaicsEco)
                            
                            Text("\(event.attendees)")
                                .font(.forestCaptionMedium)
                                .foregroundColor(.sageWhite)
                            
                            if let capacity = event.capacity {
                                Text("/ \(capacity)")
                                    .font(.forestCaptionSmall)
                                    .foregroundColor(.sageMuted)
                            }
                        }
                        
                        Spacer()
                        
                        // Price
                        Text(event.formattedPrice)
                            .font(.forestBodyMedium)
                            .foregroundColor(.luxeGold)
                        
                        // Attend Button
                        if let onAttendTap = onAttendTap {
                            Button(action: onAttendTap) {
                                Text("ATTEND")
                                    .font(.forestCaptionSmall)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.modaicsBackground)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.luxeGold)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.modaicsSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Subviews
    
    private var eventImage: some View {
        Group {
            if let imageURL = event.imageURL,
               let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .clipped()
    }
    
    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.modaicsSurface,
                    Color.modaicsSurfaceHighlight
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                Image(systemName: event.type.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.luxeGold.opacity(0.5))
                
                Text(event.type.displayName.uppercased())
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
            }
        }
    }
}

// MARK: - Supporting Views

struct EventTypeBadge: View {
    let type: CommunityEventType
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.system(size: 10))
            Text(type.displayName.uppercased())
                .font(.forestCaptionSmall)
        }
        .foregroundColor(.modaicsBackground)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.luxeGold)
        )
    }
}

struct DateBadge: View {
    let date: Date
    
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(monthString)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.sageMuted)
            
            Text(dayString)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.sageWhite)
        }
        .frame(width: 44, height: 44)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.modaicsBackground.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
        )
    }
}

struct FreeBadge: View {
    var body: some View {
        Text("FREE")
            .font(.forestCaptionSmall)
            .fontWeight(.semibold)
            .foregroundColor(.modaicsBackground)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.modaicsEco)
            )
    }
}

struct TagChip: View {
    let tag: String
    
    var body: some View {
        Text("#\(tag)")
            .font(.forestCaptionSmall)
            .foregroundColor(.modaicsFern)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.modaicsFern.opacity(0.15))
            )
    }
}

// MARK: - Preview
struct EventListCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EventListCard(
                event: CommunityEvent.mockEvents[0],
                onTap: {},
                onAttendTap: {}
            )
            
            EventListCard(
                event: CommunityEvent.mockEvents[1],
                onTap: {},
                onAttendTap: nil
            )
        }
        .padding()
        .background(Color.modaicsBackground)
        .preferredColorScheme(.dark)
    }
}
