import SwiftUI
import Combine

// MARK: - Activity Item
public struct ProfileActivityItem: Identifiable, Hashable {
    public let id: UUID
    public var type: ActivityType
    public var title: String
    public var subtitle: String?
    public var timestamp: Date
    public var icon: String
    public var iconColorName: String
    
    public enum ActivityType: String, Codable {
        case listed, sold, swapped, rented
        case liked, commented, followed
        case badgeEarned, pointsEarned
        case priceDrop, eventRSVP
        case joinedSketchbook
    }
    
    public init(
        id: UUID = UUID(),
        type: ActivityType,
        title: String,
        subtitle: String? = nil,
        timestamp: Date,
        icon: String,
        iconColorName: String
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.timestamp = timestamp
        self.icon = icon
        self.iconColorName = iconColorName
    }
}

// MARK: - Profile Wardrobe View Model
@MainActor
public class ProfileWardrobeViewModel: ObservableObject {
    @Published public var wardrobeItems: [WardrobeItem] = []
    @Published public var savedItems: [WardrobeItem] = []
    @Published public var savedEvents: [SavedEvent] = []
    @Published public var activityFeed: [ProfileActivityItem] = []
    @Published public var selectedWardrobeTab: WardrobeTab = .active
    @Published public var selectedSavedFilter: SavedFilter = .all
    @Published public var isLoading: Bool = false
    @Published public var selectedItem: WardrobeItem? = nil
    
    public enum WardrobeTab: String, CaseIterable {
        case active = "active"
        case sold = "sold"
        case swapped = "swapped"
        case rented = "rented"
        
        public var icon: String {
            switch self {
            case .active: return "tag.fill"
            case .sold: return "dollarsign.circle.fill"
            case .swapped: return "arrow.left.arrow.right"
            case .rented: return "calendar"
            }
        }
        
        public var label: String { rawValue.capitalized }
    }
    
    public enum SavedFilter: String, CaseIterable {
        case all = "All"
        case clothing = "Clothing"
        case events = "Events"
        case brands = "Brands"
    }
    
    public var filteredWardrobe: [WardrobeItem] {
        switch selectedWardrobeTab {
        case .active:
            return wardrobeItems.filter { !$0.isSold && !$0.isSwapped && !$0.isRented }
        case .sold:
            return wardrobeItems.filter { $0.isSold }
        case .swapped:
            return wardrobeItems.filter { $0.isSwapped }
        case .rented:
            return wardrobeItems.filter { $0.isRented }
        }
    }
    
    public var filteredSaved: [WardrobeItem] {
        switch selectedSavedFilter {
        case .all:
            return savedItems
        case .clothing:
            return savedItems.filter { $0.type == .clothing }
        case .events:
            return savedItems.filter { $0.type == .event }
        case .brands:
            return savedItems.filter { $0.type == .brand }
        }
    }
    
    public init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Mock wardrobe items
        wardrobeItems = [
            WardrobeItem(
                id: UUID(),
                title: "Vintage Denim Jacket",
                brand: "Levi's",
                size: "M",
                price: 85,
                imageURL: nil,
                status: .listed,
                type: .clothing
            ),
            WardrobeItem(
                id: UUID(),
                title: "Cashmere Sweater",
                brand: "Everlane",
                size: "M",
                price: 150,
                imageURL: nil,
                status: .available,
                type: .clothing
            ),
            WardrobeItem(
                id: UUID(),
                title: "Silk Blouse",
                brand: "Reformation",
                size: "S",
                price: 120,
                imageURL: nil,
                status: .sold,
                type: .clothing,
                isSold: true
            ),
            WardrobeItem(
                id: UUID(),
                title: "Wool Coat",
                brand: "COS",
                size: "M",
                price: 280,
                imageURL: nil,
                status: .swapped,
                type: .clothing,
                isSwapped: true
            ),
            WardrobeItem(
                id: UUID(),
                title: "Linen Trousers",
                brand: "Uniqlo",
                size: "32",
                price: 45,
                imageURL: nil,
                status: .rented,
                type: .clothing,
                isRented: true
            )
        ]
        
        // Mock saved items
        savedItems = [
            WardrobeItem(
                id: UUID(),
                title: "Vintage Band Tee",
                brand: "Vintage",
                size: "L",
                price: 65,
                imageURL: nil,
                status: .available,
                type: .clothing
            ),
            WardrobeItem(
                id: UUID(),
                title: "Fitzroy Market",
                brand: "Event",
                size: "",
                price: 0,
                imageURL: nil,
                status: .available,
                type: .event
            )
        ]
        
        // Mock activity feed
        activityFeed = [
            ProfileActivityItem(
                id: UUID(),
                type: .listed,
                title: "You listed \"Vintage Denim...\"",
                subtitle: nil,
                timestamp: Date(),
                icon: "bag.fill",
                iconColorName: "modaicsEco"
            ),
            ProfileActivityItem(
                id: UUID(),
                type: .liked,
                title: "You liked a post by @styleguru",
                subtitle: nil,
                timestamp: Date().addingTimeInterval(-3600),
                icon: "heart.fill",
                iconColorName: "luxeGold"
            ),
            ProfileActivityItem(
                id: UUID(),
                type: .badgeEarned,
                title: "You earned the Seedling badge",
                subtitle: nil,
                timestamp: Date().addingTimeInterval(-7200),
                icon: "leaf.fill",
                iconColorName: "modaicsEco"
            ),
            ProfileActivityItem(
                id: UUID(),
                type: .priceDrop,
                title: "Price drop on saved item",
                subtitle: "Vintage Band Tee - now $45",
                timestamp: Date().addingTimeInterval(-86400),
                icon: "tag.fill",
                iconColorName: "modaicsWarning"
            ),
            ProfileActivityItem(
                id: UUID(),
                type: .eventRSVP,
                title: "You RSVP'd to Fitzroy Market",
                subtitle: nil,
                timestamp: Date().addingTimeInterval(-172800),
                icon: "calendar",
                iconColorName: "luxeGold"
            )
        ]
    }
    
    public func itemCount(for tab: WardrobeTab) -> Int {
        switch tab {
        case .active:
            return wardrobeItems.filter { !$0.isSold && !$0.isSwapped && !$0.isRented }.count
        case .sold:
            return wardrobeItems.filter { $0.isSold }.count
        case .swapped:
            return wardrobeItems.filter { $0.isSwapped }.count
        case .rented:
            return wardrobeItems.filter { $0.isRented }.count
        }
    }
    
    public func loadWardrobe() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        loadMockData()
        isLoading = false
    }
    
    public func unsaveItem(_ item: WardrobeItem) async {
        savedItems.removeAll { $0.id == item.id }
    }
    
    public func deleteItem(_ item: WardrobeItem) async {
        wardrobeItems.removeAll { $0.id == item.id }
    }
}

// MARK: - Wardrobe Item
public struct WardrobeItem: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var brand: String
    public var size: String
    public var price: Decimal
    public var imageURL: String?
    public var status: ItemStatus
    public var type: ItemType
    public var isSold: Bool
    public var isSwapped: Bool
    public var isRented: Bool
    
    public enum ItemStatus: String, Codable {
        case listed, available, sold, swapped, rented
    }
    
    public enum ItemType: String, Codable {
        case clothing, event, brand
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        brand: String,
        size: String,
        price: Decimal,
        imageURL: String? = nil,
        status: ItemStatus,
        type: ItemType,
        isSold: Bool = false,
        isSwapped: Bool = false,
        isRented: Bool = false
    ) {
        self.id = id
        self.title = title
        self.brand = brand
        self.size = size
        self.price = price
        self.imageURL = imageURL
        self.status = status
        self.type = type
        self.isSold = isSold
        self.isSwapped = isSwapped
        self.isRented = isRented
    }
}

// MARK: - Saved Event
public struct SavedEvent: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var date: Date
    public var location: String
    
    public init(id: UUID = UUID(), title: String, date: Date, location: String) {
        self.id = id
        self.title = title
        self.date = date
        self.location = location
    }
}
