import SwiftUI
import Combine

// MARK: - Profile ViewModel
class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var user: UserProfile
    @Published var wardrobeItems: [WardrobeItem] = []
    @Published var sustainabilityStats: SustainabilityStats
    @Published var isFollowing: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var initials: String {
        let components = user.displayName.split(separator: " ")
        if components.count > 1,
           let first = components.first?.first,
           let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return String(user.displayName.prefix(2)).uppercased()
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let currentUserId = "user_001" // Mock current user
    
    // MARK: - Initialization
    init() {
        // Initialize with empty/default values
        self.user = UserProfile.empty
        self.sustainabilityStats = SustainabilityStats.empty
    }
    
    // MARK: - Profile Loading
    func loadProfile(userId: String?) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            if let userId = userId {
                // Load other user's profile
                self.user = MockData.getUser(byId: userId) ?? MockData.mockUsers[1]
                self.isFollowing = MockData.isFollowing(userId: userId)
            } else {
                // Load current user's profile
                self.user = MockData.currentUser
            }
            
            self.calculateSustainabilityStats()
            self.isLoading = false
        }
    }
    
    // MARK: - Wardrobe Loading
    func loadWardrobe(userId: String?) {
        let targetId = userId ?? currentUserId
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.wardrobeItems = MockData.getWardrobe(forUserId: targetId)
        }
    }
    
    // MARK: - Sustainability Stats Calculation
    func calculateSustainabilityStats() {
        let items = wardrobeItems.filter { $0.isSold }
        
        // Approximate environmental impact:
        // - Average CO2 per garment: 15-20 kg
        // - Average water per garment: 2,700 liters
        
        let co2PerItem = 17.5 // kg
        let waterPerItem = 2700 // liters
        
        let totalCO2 = items.count * Int(co2PerItem)
        let totalWater = items.count * waterPerItem
        
        sustainabilityStats = SustainabilityStats(
            co2Saved: totalCO2,
            waterSaved: totalWater,
            itemsRecirculated: items.count
        )
    }
    
    // MARK: - Profile Editing
    func saveProfile() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            // In real app, this would save to backend
            MockData.updateUser(self.user)
            self.isLoading = false
        }
    }
    
    // MARK: - Follow/Unfollow
    func toggleFollow() {
        isFollowing.toggle()
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            MockData.toggleFollow(userId: self.user.id, follow: self.isFollowing)
            
            // Update follower count locally
            if self.isFollowing {
                self.user.followers += 1
            } else {
                self.user.followers = max(0, self.user.followers - 1)
            }
        }
    }
    
    // MARK: - Settings Navigation
    func navigateToSettings() -> SettingsView {
        return SettingsView()
    }
}

// MARK: - Models

struct UserProfile: Identifiable {
    let id: String
    var displayName: String
    var username: String
    var bio: String
    var location: String
    var avatar: String?
    var isVerified: Bool
    var itemsSold: Int
    var itemsBought: Int
    var followers: Int
    var following: Int
    
    static var empty: UserProfile {
        UserProfile(
            id: "",
            displayName: "",
            username: "",
            bio: "",
            location: "",
            avatar: nil,
            isVerified: false,
            itemsSold: 0,
            itemsBought: 0,
            followers: 0,
            following: 0
        )
    }
}

struct WardrobeItem: Identifiable {
    let id: String
    let name: String
    let imageName: String
    let brand: String
    let size: String
    let isForSale: Bool
    let isSold: Bool
    let price: Double?
    let purchaseDate: Date
}

struct SustainabilityStats {
    let co2Saved: Int // kg
    let waterSaved: Int // liters
    let itemsRecirculated: Int
    
    static var empty: SustainabilityStats {
        SustainabilityStats(co2Saved: 0, waterSaved: 0, itemsRecirculated: 0)
    }
}

// MARK: - Mock Data
enum MockData {
    static let currentUser = UserProfile(
        id: "user_001",
        displayName: "Alex Chen",
        username: "alexchen",
        bio: "Sustainable fashion enthusiast. Thrifting since 2019. Building a capsule wardrobe one vintage piece at a time. 🌱",
        location: "San Francisco, CA",
        avatar: nil,
        isVerified: true,
        itemsSold: 47,
        itemsBought: 32,
        followers: 1284,
        following: 342
    )
    
    static let mockUsers = [
        currentUser,
        UserProfile(
            id: "user_002",
            displayName: "Maya Johnson",
            username: "mayaj",
            bio: "Vintage lover | Photographer | Reducing fashion footprint 🌍",
            location: "Brooklyn, NY",
            avatar: nil,
            isVerified: false,
            itemsSold: 23,
            itemsBought: 56,
            followers: 892,
            following: 445
        ),
        UserProfile(
            id: "user_003",
            displayName: "Jordan Smith",
            username: "jsmith",
            bio: "Streetwear collector. Always hunting for grails.",
            location: "Los Angeles, CA",
            avatar: nil,
            isVerified: true,
            itemsSold: 156,
            itemsBought: 89,
            followers: 5234,
            following: 120
        )
    ]
    
    static var currentUserWardrobe: [WardrobeItem] = [
        WardrobeItem(id: "item_001", name: "Vintage Denim Jacket", imageName: "jacket", brand: "Levi's", size: "M", isForSale: true, isSold: false, price: 85.00, purchaseDate: Date()),
        WardrobeItem(id: "item_002", name: "Cashmere Sweater", imageName: " sweater", brand: "Everlane", size: "L", isForSale: false, isSold: false, price: nil, purchaseDate: Date()),
        WardrobeItem(id: "item_003", name: "Leather Boots", imageName: "shoe", brand: "Dr. Martens", size: "10", isForSale: true, isSold: false, price: 120.00, purchaseDate: Date()),
        WardrobeItem(id: "item_004", name: "Silk Scarf", imageName: "scarf", brand: "Vintage", size: "OS", isForSale: false, isSold: true, price: 45.00, purchaseDate: Date()),
        WardrobeItem(id: "item_005", name: "Wool Coat", imageName: "coat", brand: "COS", size: "M", isForSale: false, isSold: true, price: 200.00, purchaseDate: Date()),
        WardrobeItem(id: "item_006", name: "Linen Shirt", imageName: "tshirt", brand: "Uniqlo", size: "L", isForSale: true, isSold: false, price: 25.00, purchaseDate: Date()),
        WardrobeItem(id: "item_007", name: "Corduroy Pants", imageName: "pants", brand: "Patagonia", size: "32", isForSale: true, isSold: false, price: 60.00, purchaseDate: Date()),
        WardrobeItem(id: "item_008", name: "Canvas Tote", imageName: "bag", brand: "Baggu", size: "OS", isForSale: false, isSold: true, price: 30.00, purchaseDate: Date())
    ]
    
    static let otherUserWardrobe: [WardrobeItem] = [
        WardrobeItem(id: "item_101", name: "Oversized Blazer", imageName: "jacket", brand: "Theory", size: "S", isForSale: true, isSold: false, price: 150.00, purchaseDate: Date()),
        WardrobeItem(id: "item_102", name: "Midi Skirt", imageName: "pants", brand: "Reformation", size: "4", isForSale: true, isSold: false, price: 75.00, purchaseDate: Date()),
        WardrobeItem(id: "item_103", name: "Knit Beanie", imageName: "hat", brand: "Carhartt", size: "OS", isForSale: false, isSold: false, price: nil, purchaseDate: Date()),
        WardrobeItem(id: "item_104", name: "Vintage Tee", imageName: "tshirt", brand: "Band Tee", size: "M", isForSale: true, isSold: true, price: 40.00, purchaseDate: Date())
    ]
    
    private static var followingSet: Set<String> = []
    
    static func getUser(byId id: String) -> UserProfile? {
        return mockUsers.first { $0.id == id }
    }
    
    static func getWardrobe(forUserId userId: String) -> [WardrobeItem] {
        if userId == currentUser.id {
            return currentUserWardrobe
        }
        return otherUserWardrobe
    }
    
    static func updateUser(_ user: UserProfile) {
        // In real app, this would update backend
        // For mock, we'd update the current user reference
    }
    
    static func isFollowing(userId: String) -> Bool {
        return followingSet.contains(userId)
    }
    
    static func toggleFollow(userId: String, follow: Bool) {
        if follow {
            followingSet.insert(userId)
        } else {
            followingSet.remove(userId)
        }
    }
}