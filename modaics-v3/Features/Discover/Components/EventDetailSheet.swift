import SwiftUI
import MapKit

// MARK: - EventDetailSheet
/// Detail sheet for events - shown when tapping an event in list or map
public struct EventDetailSheet: View {
    let event: CommunityEvent
    @Environment(\.dismiss) private var dismiss
    
    public init(event: CommunityEvent) {
        self.event = event
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Date header with day/month
                        dateHeader
                        
                        // Type badge and title
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                // Type badge
                                HStack(spacing: 4) {
                                    Image(systemName: iconForType(event.type))
                                        .font(.system(size: 12))
                                    Text(event.type.displayName.uppercased())
                                        .font(.forestCaptionSmall)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(event.type.swiftColor)
                                .clipShape(Capsule())
                                
                                Spacer()
                                
                                // Price
                                Text(event.formattedPrice)
                                    .font(.forestHeadlineSmall)
                                    .foregroundColor(event.isFree ? .modaicsEco : .luxeGold)
                            }
                            
                            Text(event.title)
                                .font(.forestDisplaySmall)
                                .foregroundColor(.sageWhite)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Location
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LOCATION")
                                .font(.forestCaptionMedium)
                                .foregroundColor(.sageMuted)
                                .tracking(1)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.modaicsFern)
                                
                                Text(event.location)
                                    .font(.forestBodyLarge)
                                    .foregroundColor(.sageWhite)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Date and time
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DATE & TIME")
                                .font(.forestCaptionMedium)
                                .foregroundColor(.sageMuted)
                                .tracking(1)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "calendar.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.modaicsFern)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.formattedDate)
                                        .font(.forestBodyLarge)
                                        .foregroundColor(.sageWhite)
                                    
                                    Text(event.timeUntil)
                                        .font(.forestCaptionMedium)
                                        .foregroundColor(.modaicsFern)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Attendees
                        HStack(spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.modaicsFern)
                                
                                Text("\(event.attendees) attending")
                                    .font(.forestBodyMedium)
                                    .foregroundColor(.sageWhite)
                            }
                            
                            if event.isAlmostFull {
                                Text("ALMOST FULL")
                                    .font(.forestCaptionSmall)
                                    .fontWeight(.bold)
                                    .foregroundColor(.modaicsWarning)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.modaicsWarning.opacity(0.15))
                                    .cornerRadius(4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                            .background(Color.luxeGold.opacity(0.2))
                        
                        // Host
                        VStack(alignment: .leading, spacing: 8) {
                            Text("HOSTED BY")
                                .font(.forestCaptionMedium)
                                .foregroundColor(.sageMuted)
                                .tracking(1)
                            
                            Text(event.host)
                                .font(.forestBodyLarge)
                                .foregroundColor(.sageWhite)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ABOUT THIS EVENT")
                                .font(.forestCaptionMedium)
                                .foregroundColor(.sageMuted)
                                .tracking(1)
                            
                            Text(event.description)
                                .font(.forestBodyMedium)
                                .foregroundColor(.sageWhite)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Tags
                        if !event.tags.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(event.tags, id: \.self) { tag in
                                    Text("#\(tag.uppercased())")
                                        .font(.forestCaptionSmall)
                                        .foregroundColor(.luxeGold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.luxeGold.opacity(0.1))
                                        .cornerRadius(6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Actions
                        VStack(spacing: 12) {
                            Button(action: {}) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(event.isFree ? "ATTEND EVENT" : "GET TICKETS")
                                        .tracking(1)
                                }
                                .font(.forestBodyMedium)
                                .foregroundColor(.modaicsBackground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.luxeGold)
                                .cornerRadius(12)
                            }
                            
                            Button(action: openInMaps) {
                                HStack(spacing: 8) {
                                    Image(systemName: "map")
                                    Text("GET DIRECTIONS")
                                        .tracking(1)
                                }
                                .font(.forestBodyMedium)
                                .foregroundColor(.sageWhite)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.modaicsSurface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
                                )
                                .cornerRadius(12)
                            }
                            
                            Button(action: {}) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("SHARE EVENT")
                                        .tracking(1)
                                }
                                .font(.forestBodyMedium)
                                .foregroundColor(.sageMuted)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                        }
                        .padding(.top, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.sageMuted)
                    }
                }
            }
        }
    }
    
    private var dateHeader: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text(event.dayDisplay)
                    .font(.forestDisplayMedium)
                    .foregroundColor(.luxeGold)
                Text(event.monthDisplay)
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageMuted)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.modaicsSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.luxeGold.opacity(0.3), lineWidth: 2)
                    )
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Save the date")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                Text("Don't miss out!")
                    .font(.forestBodyLarge)
                    .foregroundColor(.sageWhite)
            }
            
            Spacer()
        }
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
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: event.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = event.title
        mapItem.openInMaps()
    }
}

// MARK: - FlowLayout Helper
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Preview
struct EventDetailSheet_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailSheet(event: CommunityEvent.mockEvents[0])
    }
}
