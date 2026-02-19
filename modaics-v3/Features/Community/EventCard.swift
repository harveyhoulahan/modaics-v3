import SwiftUI

struct EventCard: View {
    let event: CommunityEvent
    let onRSVP: () -> Void
    
    // Industrial Design Colors
    private let backgroundColor = Color(red: 0.10, green: 0.12, blue: 0.18)
    private let accentRed = Color(red: 0.85, green: 0.20, blue: 0.18)
    private let borderColor = Color(red: 0.20, green: 0.22, blue: 0.28)
    private let textPrimary = Color.white
    private let textSecondary = Color(white: 0.6)
    private let textTertiary = Color(white: 0.4)
    
    private var eventColor: Color {
        switch event.eventType {
        case .swapMeet:
            return Color(red: 0.85, green: 0.60, blue: 0.20)
        case .market:
            return Color(red: 0.30, green: 0.70, blue: 0.50)
        case .workshop:
            return Color(red: 0.40, green: 0.50, blue: 0.90)
        case .meetup:
            return Color(red: 0.70, green: 0.40, blue: 0.70)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event Image
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 0)
                    .fill(borderColor)
                    .frame(height: 160)
                    .overlay(
                        Image(systemName: "calendar")
                            .font(.system(size: 48))
                            .foregroundColor(textTertiary)
                    )
                
                // Event Type Badge
                Text(event.eventType.rawValue.uppercased())
                    .font(.system(.caption2, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(eventColor)
                    .cornerRadius(4)
                    .padding(12)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(event.title.uppercased())
                    .font(.system(.headline, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(textPrimary)
                    .lineLimit(2)
                
                // Date & Location
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                            .foregroundColor(accentRed)
                            .frame(width: 20)
                        
                        Text(formatDate(event.date))
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(textSecondary)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 14))
                            .foregroundColor(accentRed)
                            .frame(width: 20)
                        
                        Text(event.location)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(textSecondary)
                    }
                }
                
                Divider()
                    .background(borderColor)
                
                // Footer
                HStack {
                    // Attendees
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12))
                            .foregroundColor(textTertiary)
                        
                        Text("\(event.attendeeCount) GOING")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(textTertiary)
                    }
                    
                    Spacer()
                    
                    // RSVP Button
                    Button(action: onRSVP) {
                        HStack(spacing: 6) {
                            Image(systemName: event.isRSVPd ? "checkmark" : "plus")
                                .font(.system(size: 12, weight: .bold))
                            
                            Text(event.isRSVPd ? "GOING" : "RSVP")
                                .font(.system(.caption, design: .monospaced))
                                .fontWeight(.bold)
                        }
                        .foregroundColor(event.isRSVPd ? .white : accentRed)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(event.isRSVPd ? accentRed : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(event.isRSVPd ? Color.clear : accentRed, lineWidth: 1.5)
                        )
                        .background(event.isRSVPd ? Color.clear : accentRed.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }
            .padding(16)
        }
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct EventCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.06, green: 0.08, blue: 0.14)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                EventCard(
                    event: CommunityEvent(
                        id: UUID(),
                        title: "Brooklyn Denim Swap Meet",
                        image: "event1",
                        date: Date().addingTimeInterval(86400 * 7),
                        location: "Williamsburg, NY",
                        attendeeCount: 234,
                        isRSVPd: false,
                        eventType: .swapMeet
                    ),
                    onRSVP: {}
                )
                
                EventCard(
                    event: CommunityEvent(
                        id: UUID(),
                        title: "Raw Denim Market",
                        image: "event2",
                        date: Date().addingTimeInterval(86400 * 14),
                        location: "Shibuya, Tokyo",
                        attendeeCount: 567,
                        isRSVPd: true,
                        eventType: .market
                    ),
                    onRSVP: {}
                )
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
