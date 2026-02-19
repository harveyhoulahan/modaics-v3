import SwiftUI
import MapKit

// MARK: - EventDetailSheet
/// Detail sheet for viewing full event information
public struct EventDetailSheet: View {
    let event: CommunityEvent
    let onAttend: () -> Void
    let onDismiss: () -> Void
    let onShare: (() -> Void)?
    
    @State private var selectedTab: DetailTab = .details
    @State private var region: MKCoordinateRegion
    
    public init(
        event: CommunityEvent,
        onAttend: @escaping () -> Void = {},
        onDismiss: @escaping () -> Void = {},
        onShare: (() -> Void)? = nil
    ) {
        self.event = event
        self.onAttend = onAttend
        self.onDismiss = onDismiss
        self.onShare = onShare
        
        // Initialize region with event coordinates
        _region = State(initialValue: MKCoordinateRegion(
            center: event.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    public var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Image
                    heroImage
                    
                    // Content
                    VStack(alignment: .leading, spacing: 24) {
                        // Title Section
                        titleSection
                        
                        // Tab Selector
                        tabSelector
                        
                        // Tab Content
                        switch selectedTab {
                        case .details:
                            detailsTab
                        case .location:
                            locationTab
                        case .organizer:
                            organizerTab
                        }
                        
                        // Bottom padding
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .background(Color.modaicsBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.sageWhite)
                    }
                }
                
                if let onShare = onShare {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: onShare) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18))
                                .foregroundColor(.luxeGold)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Attend Button
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.luxeGold.opacity(0.2))
                    
                    HStack(spacing: 16) {
                        // Price
                        VStack(alignment: .leading, spacing: 2) {
                            Text("TICKET")
                                .font(.forestCaptionSmall)
                                .foregroundColor(.sageMuted)
                            
                            Text(event.formattedPrice)
                                .font(.forestHeadlineSmall)
                                .foregroundColor(.luxeGold)
                        }
                        
                        Spacer()
                        
                        // Attend Button
                        Button(action: onAttend) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("ATTEND EVENT")
                                    .font(.forestBodyMedium)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.modaicsBackground)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.luxeGold)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.modaicsBackground)
                }
            }
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Subviews
    
    private var heroImage: some View {
        ZStack(alignment: .bottomLeading) {
            // Image
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
            .frame(height: 240)
            .clipped()
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    .clear,
                    Color.modaicsBackground.opacity(0.8)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Type badge
            EventTypeBadge(type: event.type)
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            // Date info
            HStack(spacing: 12) {
                // Date box
                VStack(spacing: 0) {
                    Text(monthString(from: event.startDate))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.sageMuted)
                    
                    Text(dayString(from: event.startDate))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.sageWhite)
                }
                .frame(width: 56, height: 56)
                .background(Color.modaicsSurface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedFullDate(from: event.startDate))
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageWhite)
                    
                    Text(formattedTimeRange())
                        .font(.forestCaptionMedium)
                        .foregroundColor(.luxeGold)
                }
            }
            .padding(16)
        }
        .frame(height: 240)
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
            
            VStack(spacing: 12) {
                Image(systemName: event.type.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.luxeGold.opacity(0.5))
                
                Text(event.type.displayName.uppercased())
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(event.title)
                .font(.forestHeadlineLarge)
                .foregroundColor(.sageWhite)
                .lineLimit(3)
            
            HStack(spacing: 16) {
                // Attendees
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.modaicsEco)
                    
                    Text("\(event.attendees) attending")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                }
                
                // Status
                if event.isOngoing {
                    StatusBadge(text: "LIVE NOW", color: .red)
                } else if let days = event.daysUntil {
                    StatusBadge(text: "IN \(days) DAYS", color: .modaicsFern)
                }
            }
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab.displayName)
                            .font(.forestCaptionMedium)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .foregroundColor(selectedTab == tab ? .sageWhite : .sageMuted)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? Color.luxeGold : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(Color.modaicsSurface)
                .cornerRadius(8)
        )
    }
    
    private var detailsTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("ABOUT")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.luxeGold)
                    .tracking(1.5)
                
                Text(event.description)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageWhite)
                    .lineSpacing(4)
            }
            
            // Tags
            if !event.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("TAGS")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.luxeGold)
                        .tracking(1.5)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(event.tags, id: \.self) { tag in
                            TagChip(tag: tag)
                        }
                    }
                }
            }
            
            // Capacity
            if let capacity = event.capacity {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CAPACITY")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.luxeGold)
                        .tracking(1.5)
                    
                    HStack(spacing: 8) {
                        ProgressView(value: Double(event.attendees), total: Double(capacity))
                            .progressViewStyle(LinearProgressViewStyle(tint: .luxeGold))
                            .frame(height: 8)
                        
                        Text("\(event.attendees)/\(capacity)")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                    }
                }
            }
        }
    }
    
    private var locationTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Venue info
            VStack(alignment: .leading, spacing: 8) {
                Text("VENUE")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.luxeGold)
                    .tracking(1.5)
                
                Text(event.venueName)
                    .font(.forestHeadlineSmall)
                    .foregroundColor(.sageWhite)
                
                Text(event.address)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageMuted)
            }
            
            // Map
            Map(coordinateRegion: $region, annotationItems: [event]) { event in
                MapMarker(coordinate: event.coordinate, tint: .luxeGold)
            }
            .frame(height: 200)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
            )
            
            // Open in Maps button
            Button(action: {
                openInMaps()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "map")
                    Text("OPEN IN MAPS")
                }
                .font(.forestBodyMedium)
                .foregroundColor(.luxeGold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.modaicsSurface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    private var organizerTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("ORGANIZER")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.luxeGold)
                    .tracking(1.5)
                
                HStack(spacing: 16) {
                    // Avatar placeholder
                    Circle()
                        .fill(Color.modaicsSurface)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.sageMuted)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.organizerName)
                            .font(.forestHeadlineSmall)
                            .foregroundColor(.sageWhite)
                        
                        Text("Event Organizer")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                    }
                }
                .padding()
                .background(Color.modaicsSurface)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
    
    private func formattedFullDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func formattedTimeRange() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let start = formatter.string(from: event.startDate)
        let end = formatter.string(from: event.endDate)
        return "\(start) - \(end)"
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: event.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = event.venueName
        mapItem.openInMaps()
    }
}

// MARK: - Supporting Types

enum DetailTab: String, CaseIterable, Identifiable {
    case details = "DETAILS"
    case location = "LOCATION"
    case organizer = "ORGANIZER"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .details: return "Details"
        case .location: return "Location"
        case .organizer: return "Organizer"
        }
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.forestCaptionSmall)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
    }
}

// MARK: - Preview
struct EventDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailSheet(
            event: CommunityEvent.mockEvents[0],
            onAttend: {},
            onDismiss: {},
            onShare: {}
        )
    }
}
