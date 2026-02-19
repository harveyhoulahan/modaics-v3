import SwiftUI

// MARK: - EventListCard
/// Reusable card component for displaying events in list view
public struct EventListCard: View {
    let event: CommunityEvent
    let onTap: () -> Void
    
    public init(event: CommunityEvent, onTap: @escaping () -> Void = {}) {
        self.event = event
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Top row: Type badge and distance (if available)
                HStack {
                    // Type badge
                    HStack(spacing: 4) {
                        Image(systemName: iconForType(event.type))
                            .font(.system(size: 10))
                        Text(event.type.displayName.uppercased())
                            .font(.forestCaptionSmall)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(event.type.swiftColor)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Price badge
                    Text(event.formattedPrice)
                        .font(.forestCaptionMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(event.isFree ? .modaicsEco : .luxeGold)
                }
                
                // Title
                Text(event.title)
                    .font(.forestHeadlineSmall)
                    .foregroundColor(.sageWhite)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Location and date
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 12))
                            .foregroundColor(.sageMuted)
                        Text(event.location)
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.sageMuted)
                        Text(event.timeUntil)
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                    }
                }
                
                // Attendees
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 10))
                        .foregroundColor(event.isAlmostFull ? .modaicsWarning : .sageSubtle)
                    
                    Text("\(event.attendees)/\(event.maxAttendees)")
                        .font(.forestCaptionSmall)
                        .foregroundColor(event.isAlmostFull ? .modaicsWarning : .sageSubtle)
                    
                    if event.isAlmostFull {
                        Text("ALMOST FULL")
                            .font(.forestCaptionSmall)
                            .fontWeight(.bold)
                            .foregroundColor(.modaicsWarning)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.modaicsWarning.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(16)
            .background(Color.modaicsSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForType(_ type: CommunityEventType) -> String {
        switch type {
        case .market:
            return "storefront"
        case .exhibition:
            return "photo"
        case .talk:
            return "mic"
        case .party:
            return "music.note"
        case .swapMeet:
            return "arrow.triangle.2.circlepath"
        case .workshop:
            return "hammer"
        case .classSession:
            return "book"
        case .popUp:
            return "sparkles"
        }
    }
}

// MARK: - Preview
struct EventListCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            VStack(spacing: 16) {
                EventListCard(event: CommunityEvent.mockEvents[0]) {}
                EventListCard(event: CommunityEvent.mockEvents[5]) {}
                EventListCard(event: CommunityEvent.mockEvents[2]) {}
            }
            .padding(20)
        }
    }
}
