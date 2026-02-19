import SwiftUI
import MapKit
import UIKit

// MARK: - DiscoverMapView
/// Map view for displaying events with pins
public struct DiscoverMapView: View {
    @Binding var region: MKCoordinateRegion
    let events: [CommunityEvent]
    @Binding var selectedEvent: CommunityEvent?
    let onEventTap: (CommunityEvent) -> Void
    
    public init(
        region: Binding<MKCoordinateRegion>,
        events: [CommunityEvent],
        selectedEvent: Binding<CommunityEvent?>,
        onEventTap: @escaping (CommunityEvent) -> Void = { _ in }
    ) {
        self._region = region
        self.events = events
        self._selectedEvent = selectedEvent
        self.onEventTap = onEventTap
    }
    
    public var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region,
                annotationItems: events.map { MapEventAnnotation(event: $0) }) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    DiscoverMapPin(
                        event: annotation.event,
                        isSelected: selectedEvent?.id == annotation.event.id
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedEvent = annotation.event
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            
            // Detail card at bottom when event is selected
            if let event = selectedEvent {
                VStack {
                    Spacer()
                    
                    eventDetailCard(event: event)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
    
    private func eventDetailCard(event: CommunityEvent) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedEvent = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.sageMuted)
                }
            }
            
            // Type and title
            HStack {
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
                
                Text(event.formattedPrice)
                    .font(.forestCaptionMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(event.isFree ? .modaicsEco : .luxeGold)
            }
            
            Text(event.title)
                .font(.forestHeadlineSmall)
                .foregroundColor(.sageWhite)
                .lineLimit(1)
            
            HStack(spacing: 12) {
                Label(event.venueName, systemImage: "mappin")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .lineLimit(1)
                
                Label(event.timeUntil, systemImage: "calendar")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
            }
            
            HStack(spacing: 8) {
                Text("\(event.attendees)/\(event.maxAttendees) attending")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageSubtle)
                
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
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    onEventTap(event)
                }) {
                    Text("VIEW DETAILS")
                        .font(.forestCaptionMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.modaicsBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.luxeGold)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    openInMaps(event: event)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "map")
                        Text("DIRECTIONS")
                            .font(.forestCaptionSmall)
                    }
                    .foregroundColor(.sageWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.modaicsSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.modaicsSurface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
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
    
    private func openInMaps(event: CommunityEvent) {
        let coordinates = event.coordinate
        let url = URL(string: "http://maps.apple.com/?ll=\(coordinates.latitude),\(coordinates.longitude)&q=\(event.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
        UIApplication.shared.open(url)
    }
}

// MARK: - Preview
struct DiscoverMapView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverMapView(
            region: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631),
                span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
            )),
            events: Array(CommunityEvent.mockEvents.prefix(5)),
            selectedEvent: .constant(CommunityEvent.mockEvents[0])
        )
    }
}
