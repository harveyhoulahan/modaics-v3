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
        id: "1",
        brand: .levis,
        category: .outerwear,
        size: .medium,
        condition: .good,
        color: .blue,
        images: [],
        story: "Classic vintage find",
        price: 85.00,
        sellerId: "user1",
        createdAt: Date()
    )
    
    static let silkBlouse = ModaicsGarment(
        id: "2",
        brand: .zimmermann,
        category: .tops,
        size: .small,
        condition: .excellent,
        color: .cream,
        images: [],
        story: "Worn once to a wedding",
        price: 180.00,
        sellerId: "user2",
        createdAt: Date()
    )
    
    static let leatherBag = ModaicsGarment(
        id: "3",
        brand: .other("Vintage Coach"),
        category: .accessories,
        size: .oneSize,
        condition: .good,
        color: .brown,
        images: [],
        story: "Authentic vintage piece",
        price: 220.00,
        sellerId: "user3",
        createdAt: Date()
    )
    
    static let linenTrousers = ModaicsGarment(
        id: "4",
        brand: .zara,
        category: .bottoms,
        size: .medium,
        condition: .likeNew,
        color: .beige,
        images: [],
        story: "Perfect for summer",
        price: 45.00,
        sellerId: "user4",
        createdAt: Date()
    )
}