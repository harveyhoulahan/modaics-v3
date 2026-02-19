import SwiftUI
import MapKit

// MARK: - DiscoverMapPin
/// Custom map annotation view for events
public struct DiscoverMapPin: View {
    let event: CommunityEvent
    let isSelected: Bool
    let onTap: () -> Void
    
    public init(
        event: CommunityEvent,
        isSelected: Bool = false,
        onTap: @escaping () -> Void = {}
    ) {
        self.event = event
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            ZStack {
                // Outer ring when selected
                if isSelected {
                    Circle()
                        .fill(event.type.swiftColor.opacity(0.3))
                        .frame(width: 52, height: 52)
                }
                
                // Main pin circle
                Circle()
                    .fill(event.type.swiftColor)
                    .frame(width: isSelected ? 44 : 32, height: isSelected ? 44 : 32)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.luxeGold : Color.white, lineWidth: isSelected ? 3 : 2)
                    )
                
                // Icon
                Image(systemName: iconForType(event.type))
                    .font(.system(size: isSelected ? 18 : 14, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForType(_ type: CommunityEventType) -> String {
        switch type {
        case .market:
            return "storefront.fill"
        case .exhibition:
            return "photo.fill"
        case .talk:
            return "mic.fill"
        case .party:
            return "music.note"
        case .swapMeet:
            return "arrow.triangle.2.circlepath"
        case .workshop:
            return "hammer.fill"
        case .classSession:
            return "book.fill"
        case .popUp:
            return "sparkles"
        }
    }
}

// MARK: - Map Event Annotation
public struct MapEventAnnotation: Identifiable {
    public let id = UUID()
    public let event: CommunityEvent
    
    public var coordinate: CLLocationCoordinate2D {
        event.coordinate
    }
}

// MARK: - Preview
struct DiscoverMapPin_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            HStack(spacing: 40) {
                VStack(spacing: 20) {
                    DiscoverMapPin(
                        event: CommunityEvent.mockEvents[0],
                        isSelected: false
                    )
                    Text("Default")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageWhite)
                }
                
                VStack(spacing: 20) {
                    DiscoverMapPin(
                        event: CommunityEvent.mockEvents[0],
                        isSelected: true
                    )
                    Text("Selected")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageWhite)
                }
            }
        }
    }
}
