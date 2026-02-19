import SwiftUI
import Combine

// MARK: - Home View Model
@MainActor
class HomeViewModel: ObservableObject {
    @Published var greeting: String = "Good morning"
    @Published var ecoScore: Int = 0
    @Published var pickedForYou: [PickedItem] = []
    @Published var nearbyEvents: [ModaicsEvent] = []
    @Published var wardrobePreview: [ModaicsGarment] = []
    @Published var trendingPieces: [ModaicsGarment] = []
    @Published var wardrobeCount: Int = 0
    @Published var savedCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadHomeData() {
        isLoading = true
        
        // Set greeting based on time
        updateGreeting()
        
        // Load mock data for now (replace with API calls)
        loadMockData()
        
        isLoading = false
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            greeting = "Good morning"
        case 12..<17:
            greeting = "Good afternoon"
        case 17..<22:
            greeting = "Good evening"
        default:
            greeting = "Hello"
        }
    }
    
    private func loadMockData() {
        // Mock picked items
        pickedForYou = [
            PickedItem(
                garment: MockData.vintageDenimJacket,
                reason: "Matches your vintage style"
            ),
            PickedItem(
                garment: MockData.silkBlouse,
                reason: "Similar to pieces you've liked"
            ),
            PickedItem(
                garment: MockData.leatherBag,
                reason: "Trending in your area"
            ),
            PickedItem(
                garment: MockData.linenTrousers,
                reason: "Sustainable choice"
            )
        ]
        
        // Mock events
        nearbyEvents = [
            ModaicsEvent(
                title: "Vintage Market",
                location: "Bondi Beach, Sydney",
                day: "15",
                month: "MAR",
                attendees: 234
            ),
            ModaicsEvent(
                title: "Clothing Swap",
                location: "Newtown Community Centre",
                day: "22",
                month: "MAR",
                attendees: 89
            ),
            ModaicsEvent(
                title: "Designer Sample Sale",
                location: "Paddington Markets",
                day: "28",
                month: "MAR",
                attendees: 456
            )
        ]
        
        // Mock wardrobe preview
        wardrobePreview = [
            MockData.vintageDenimJacket,
            MockData.silkBlouse,
            MockData.linenTrousers
        ]
        
        // Mock trending
        trendingPieces = [
            MockData.leatherBag,
            MockData.vintageDenimJacket,
            MockData.silkBlouse,
            MockData.linenTrousers
        ]
        
        // Mock eco score
        ecoScore = 1250
        
        // Stats
        wardrobeCount = 12
        savedCount = 8
    }
}

// MARK: - Picked Item
struct PickedItem: Identifiable {
    let id = UUID()
    let garment: ModaicsGarment
    let reason: String
}

// MARK: - Event Model
struct ModaicsEvent: Identifiable {
    let id = UUID()
    let title: String
    let location: String
    let day: String
    let month: String
    let attendees: Int
}

// MARK: - Mock Data
enum MockData {
    static let vintageDenimJacket = ModaicsGarment(
        title: "Vintage Denim Jacket",
        description: "Classic vintage Levi's denim jacket, perfect condition",
        storyId: UUID(),
        condition: .good,
        originalPrice: 120.00,
        listingPrice: 85.00,
        category: .outerwear,
        brand: ModaicsBrand(name: "Levi's", isLuxury: false, isSustainable: false),
        size: ModaicsSize(label: "M", system: .us),
        colors: [ModaicsGarmentColor(name: "Blue", hex: "#2E5C8A")],
        ownerId: UUID(),
        isListed: true,
        exchangeType: .sell
    )
    
    static let silkBlouse = ModaicsGarment(
        title: "Silk Blouse",
        description: "Elegant silk blouse, worn once to a wedding",
        storyId: UUID(),
        condition: .excellent,
        originalPrice: 280.00,
        listingPrice: 180.00,
        category: .tops,
        brand: ModaicsBrand(name: "Zimmermann", isLuxury: true, isSustainable: false),
        size: ModaicsSize(label: "S", system: .us),
        colors: [ModaicsGarmentColor(name: "Cream", hex: "#F5F5DC")],
        ownerId: UUID(),
        isListed: true,
        exchangeType: .sell
    )
    
    static let leatherBag = ModaicsGarment(
        title: "Vintage Leather Bag",
        description: "Authentic vintage Coach leather bag",
        storyId: UUID(),
        condition: .good,
        originalPrice: 350.00,
        listingPrice: 220.00,
        category: .bags,
        brand: ModaicsBrand(name: "Vintage Coach", isLuxury: false, isSustainable: false),
        size: ModaicsSize(label: "OS", system: .oneSize),
        colors: [ModaicsGarmentColor(name: "Brown", hex: "#8B4513")],
        ownerId: UUID(),
        isListed: true,
        exchangeType: .sellOrTrade
    )
    
    static let linenTrousers = ModaicsGarment(
        title: "Linen Trousers",
        description: "Perfect summer linen trousers, breathable and stylish",
        storyId: UUID(),
        condition: .veryGood,
        originalPrice: 89.00,
        listingPrice: 45.00,
        category: .bottoms,
        brand: ModaicsBrand(name: "Zara", isLuxury: false, isSustainable: false),
        size: ModaicsSize(label: "M", system: .us),
        colors: [ModaicsGarmentColor(name: "Beige", hex: "#F5F5DC")],
        ownerId: UUID(),
        isListed: true,
        exchangeType: .sell
    )
}