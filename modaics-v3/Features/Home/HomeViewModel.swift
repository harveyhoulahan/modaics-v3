import SwiftUI
import Combine

// MARK: - HomeViewModel
/// ViewModel for the Home feature
/// Manages personalized recommendations, new arrivals, trending items, and user greeting
@MainActor
public class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Loading state
    @Published public var isLoading: Bool = false
    
    /// Error state
    @Published public var hasError: Bool = false
    @Published public var errorMessage: String?
    
    /// Current user
    @Published public var currentUser: ModaicsUser?
    
    /// User greeting based on time of day
    @Published public var greeting: String = "Hello"
    
    /// Whether user has unread notifications
    @Published public var hasNotifications: Bool = false
    
    /// Personalized "For You" feed items
    @Published public var forYouItems: [ForYouItem] = []
    
    /// New arrivals
    @Published public var newArrivals: [ModaicsGarment] = []
    
    /// Trending items
    @Published public var trendingItems: [TrendingItem] = []
    
    /// Recommended items
    @Published public var recommendedItems: [ModaicsGarment] = []
    
    /// Selected category
    @Published public var selectedCategory: IndustrialCategory?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let mockDelay: Duration = .seconds(1)
    
    // MARK: - Initialization
    
    public init() {
        updateGreeting()
    }
    
    // MARK: - Public Methods
    
    /// Load all home data
    public func loadHomeData() async {
        isLoading = true
        hasError = false
        errorMessage = nil
        
        do {
            // Simulate network delay
            try await Task.sleep(for: mockDelay)
            
            // Load data in parallel
            async let userTask = loadCurrentUser()
            async let forYouTask = loadForYouItems()
            async let newArrivalsTask = loadNewArrivals()
            async let trendingTask = loadTrendingItems()
            async let recommendedTask = loadRecommendedItems()
            async let notificationsTask = checkNotifications()
            
            // Wait for all tasks
            let (user, forYou, arrivals, trending, recommended, notifications) = try await (
                userTask, forYouTask, newArrivalsTask, trendingTask, recommendedTask, notificationsTask
            )
            
            self.currentUser = user
            self.forYouItems = forYou
            self.newArrivals = arrivals
            self.trendingItems = trending
            self.recommendedItems = recommended
            self.hasNotifications = notifications
            
            isLoading = false
            
        } catch {
            isLoading = false
            hasError = true
            errorMessage = "Failed to load home data. Please try again."
        }
    }
    
    /// Refresh all data
    public func refresh() async {
        await loadHomeData()
    }
    
    /// Select a category
    public func selectCategory(_ category: IndustrialCategory) {
        selectedCategory = category
        // In a real app, this would filter content or navigate
    }
    
    /// Select a garment
    public func selectGarment(_ garment: ModaicsGarment) {
        // In a real app, this would navigate to garment detail
    }
    
    // MARK: - Private Methods
    
    /// Update greeting based on time of day
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            greeting = "GOOD MORNING"
        case 12..<17:
            greeting = "GOOD AFTERNOON"
        case 17..<21:
            greeting = "GOOD EVENING"
        default:
            greeting = "GOOD NIGHT"
        }
    }
    
    /// Load current user
    private func loadCurrentUser() async throws -> ModaicsUser {
        // Simulate API call
        try await Task.sleep(for: .milliseconds(300))
        return HomeMockData.mockUser
    }
    
    /// Load personalized "For You" items
    private func loadForYouItems() async throws -> [ForYouItem] {
        // Simulate API call
        try await Task.sleep(for: .milliseconds(400))
        return HomeMockData.mockForYouItems
    }
    
    /// Load new arrivals
    private func loadNewArrivals() async throws -> [ModaicsGarment] {
        // Simulate API call
        try await Task.sleep(for: .milliseconds(350))
        return HomeMockData.mockNewArrivals
    }
    
    /// Load trending items
    private func loadTrendingItems() async throws -> [TrendingItem] {
        // Simulate API call
        try await Task.sleep(for: .milliseconds(450))
        return HomeMockData.mockTrendingItems
    }
    
    /// Load recommended items
    private func loadRecommendedItems() async throws -> [ModaicsGarment] {
        // Simulate API call
        try await Task.sleep(for: .milliseconds(500))
        return HomeMockData.mockRecommendedItems
    }
    
    /// Check for unread notifications
    private func checkNotifications() async throws -> Bool {
        // Simulate API call
        try await Task.sleep(for: .milliseconds(200))
        return true
    }
}

// MARK: - For You Item
/// A personalized recommendation item with match reasoning
public struct ForYouItem: Identifiable, Hashable {
    public let id: UUID
    public let garment: ModaicsGarment
    public let reason: String
    public let matchPercentage: String
    public let score: Double
    
    public init(
        id: UUID = UUID(),
        garment: ModaicsGarment,
        reason: String,
        matchPercentage: String,
        score: Double
    ) {
        self.id = id
        self.garment = garment
        self.reason = reason
        self.matchPercentage = matchPercentage
        self.score = score
    }
}

// MARK: - Trending Item
/// A trending garment with popularity metrics
public struct TrendingItem: Identifiable, Hashable {
    public let id: UUID
    public let garment: ModaicsGarment
    public let rank: Int
    public let heatScore: Int
    public let viewCount: Int
    public let favoriteCount: Int
    
    public init(
        id: UUID = UUID(),
        garment: ModaicsGarment,
        rank: Int,
        heatScore: Int,
        viewCount: Int,
        favoriteCount: Int
    ) {
        self.id = id
        self.garment = garment
        self.rank = rank
        self.heatScore = heatScore
        self.viewCount = viewCount
        self.favoriteCount = favoriteCount
    }
}

// MARK: - Mock Data
/// Mock data for previews and testing
public enum HomeMockData {
    
    // MARK: - Mock User
    public static let mockUser = ModaicsUser(
        id: UUID(),
        displayName: "Alex Rivera",
        username: "arivera",
        bio: "Sustainable fashion enthusiast | Vintage lover",
        styleDescriptors: ["minimalist", "vintage", "sustainable"],
        aesthetic: .vintage,
        favoriteColors: ["black", "cream", "terracotta"],
        openToTrade: true,
        preferredExchangeTypes: [.sellOrTrade],
        wardrobeCount: 24,
        exchangeCount: 12,
        rating: 4.8,
        ratingCount: 15,
        followerCount: 128,
        followingCount: 89,
        totalCarbonSavingsKg: 45.5,
        totalWaterSavingsLiters: 12500,
        itemsCirculated: 18,
        email: "alex@example.com",
        tier: .premium
    )
    
    // MARK: - Mock Garments
    public static let mockGarments: [ModaicsGarment] = [
        ModaicsGarment(
            id: UUID(),
            title: "Vintage Wool Overcoat",
            description: "Classic camel overcoat from the 80s",
            storyId: UUID(),
            condition: .excellent,
            originalPrice: 450,
            listingPrice: 180,
            category: .outerwear,
            styleTags: ["vintage", "classic", "wool"],
            colors: [ModaicsGarmentColor(name: "camel")],
            materials: [ModaicsMaterial(name: "wool", percentage: 100)],
            brand: ModaicsBrand(name: "Burberry", isLuxury: true),
            size: ModaicsSize(label: "M", system: .us),
            era: .eighties,
            ownerId: UUID(),
            isListed: true,
            exchangeType: .sell,
            viewCount: 234,
            favoriteCount: 45
        ),
        ModaicsGarment(
            id: UUID(),
            title: "Silk Midi Dress",
            description: "Elegant black silk dress",
            storyId: UUID(),
            condition: .newWithTags,
            originalPrice: 320,
            listingPrice: 220,
            category: .dresses,
            styleTags: ["elegant", "evening", "silk"],
            colors: [ModaicsGarmentColor(name: "black")],
            materials: [ModaicsMaterial(name: "silk", percentage: 100)],
            brand: ModaicsBrand(name: "Reformation", isSustainable: true),
            size: ModaicsSize(label: "S", system: .us),
            ownerId: UUID(),
            isListed: true,
            exchangeType: .sell,
            viewCount: 189,
            favoriteCount: 32
        ),
        ModaicsGarment(
            id: UUID(),
            title: "Denim Chore Jacket",
            description: "Workwear inspired denim jacket",
            storyId: UUID(),
            condition: .veryGood,
            listingPrice: 65,
            category: .outerwear,
            styleTags: ["workwear", "denim", "casual"],
            colors: [ModaicsGarmentColor(name: "indigo")],
            materials: [ModaicsMaterial(name: "denim", percentage: 100, isSustainable: true)],
            brand: ModaicsBrand(name: "Levi's"),
            size: ModaicsSize(label: "L", system: .us),
            era: .contemporary,
            ownerId: UUID(),
            isListed: true,
            exchangeType: .sellOrTrade,
            viewCount: 156,
            favoriteCount: 28
        ),
        ModaicsGarment(
            id: UUID(),
            title: "Cashmere Turtleneck",
            description: "Soft cream cashmere sweater",
            storyId: UUID(),
            condition: .excellent,
            originalPrice: 280,
            listingPrice: 120,
            category: .tops,
            styleTags: ["cashmere", "luxury", "minimal"],
            colors: [ModaicsGarmentColor(name: "cream")],
            materials: [ModaicsMaterial(name: "cashmere", percentage: 100)],
            brand: ModaicsBrand(name: "Everlane", isSustainable: true),
            size: ModaicsSize(label: "M", system: .us),
            ownerId: UUID(),
            isListed: true,
            exchangeType: .sell,
            viewCount: 312,
            favoriteCount: 67
        ),
        ModaicsGarment(
            id: UUID(),
            title: "Vintage Band Tee",
            description: "Rare 90s concert t-shirt",
            storyId: UUID(),
            condition: .good,
            listingPrice: 85,
            category: .tops,
            styleTags: ["vintage", "band", "grunge"],
            colors: [ModaicsGarmentColor(name: "black")],
            materials: [ModaicsMaterial(name: "cotton", percentage: 100)],
            era: .nineties,
            ownerId: UUID(),
            isListed: true,
            exchangeType: .trade,
            viewCount: 445,
            favoriteCount: 89
        ),
        ModaicsGarment(
            id: UUID(),
            title: "Pleated Wool Trousers",
            description: "High-waisted tailored trousers",
            storyId: UUID(),
            condition: .excellent,
            originalPrice: 195,
            listingPrice: 95,
            category: .bottoms,
            styleTags: ["tailored", "workwear", "minimal"],
            colors: [ModaicsGarmentColor(name: "charcoal")],
            materials: [ModaicsMaterial(name: "wool", percentage: 100)],
            brand: ModaicsBrand(name: "COS"),
            size: ModaicsSize(label: "28", system: .numeric),
            ownerId: UUID(),
            isListed: true,
            exchangeType: .sell,
            viewCount: 178,
            favoriteCount: 23
        ),
        ModaicsGarment(
            id: UUID(),
            title: "Linen Blazer",
            description: "Breathable summer blazer",
            storyId: UUID(),
            condition: .newWithoutTags,
            originalPrice: 165,
            listingPrice: 110,
            category: .outerwear,
            styleTags: ["summer", "linen", "professional"],
            colors: [ModaicsGarmentColor(name: "beige")],
            materials: [ModaicsMaterial(name: "linen", percentage: 100, isSustainable: true)],
            size: ModaicsSize(label: "M", system: .us),
            ownerId: UUID(),
            isListed: true,
            exchangeType: .sell,
            viewCount: 134,
            favoriteCount: 19
        ),
        ModaicsGarment(
            id: UUID(),
            title: "Leather Crossbody Bag",
            description: "Vintage brown leather bag",
            storyId: UUID(),
            condition: .vintage,
            listingPrice: 145,
            category: .bags,
            styleTags: ["vintage", "leather", "accessories"],
            colors: [ModaicsGarmentColor(name: "brown")],
            materials: [ModaicsMaterial(name: "leather", percentage: 100)],
            era: .seventies,
            ownerId: UUID(),
            isListed: true,
            exchangeType: .sellOrTrade,
            viewCount: 267,
            favoriteCount: 54
        )
    ]
    
    // MARK: - For You Items
    public static let mockForYouItems: [ForYouItem] = [
        ForYouItem(
            garment: mockGarments[0],
            reason: "Based on your love for vintage outerwear and classic styles",
            matchPercentage: "98%",
            score: 0.98
        ),
        ForYouItem(
            garment: mockGarments[2],
            reason: "Matches your workwear aesthetic preference",
            matchPercentage: "94%",
            score: 0.94
        ),
        ForYouItem(
            garment: mockGarments[3],
            reason: "Similar to items you've favorited before",
            matchPercentage: "91%",
            score: 0.91
        ),
        ForYouItem(
            garment: mockGarments[5],
            reason: "Fits your minimalist style profile",
            matchPercentage: "89%",
            score: 0.89
        )
    ]
    
    // MARK: - New Arrivals
    public static let mockNewArrivals: [ModaicsGarment] = Array(mockGarments.prefix(4))
    
    // MARK: - Trending Items
    public static let mockTrendingItems: [TrendingItem] = [
        TrendingItem(
            garment: mockGarments[4],
            rank: 1,
            heatScore: 2450,
            viewCount: 445,
            favoriteCount: 89
        ),
        TrendingItem(
            garment: mockGarments[3],
            rank: 2,
            heatScore: 1890,
            viewCount: 312,
            favoriteCount: 67
        ),
        TrendingItem(
            garment: mockGarments[7],
            rank: 3,
            heatScore: 1520,
            viewCount: 267,
            favoriteCount: 54
        ),
        TrendingItem(
            garment: mockGarments[0],
            rank: 4,
            heatScore: 1280,
            viewCount: 234,
            favoriteCount: 45
        )
    ]
    
    // MARK: - Recommended Items
    public static let mockRecommendedItems: [ModaicsGarment] = [
        mockGarments[1],
        mockGarments[3],
        mockGarments[6],
        mockGarments[7]
    ]
}

// MARK: - Preview Helper
#if DEBUG
extension HomeViewModel {
    /// Create a view model with mock data for previews
    static func preview() -> HomeViewModel {
        let vm = HomeViewModel()
        vm.currentUser = HomeMockData.mockUser
        vm.forYouItems = HomeMockData.mockForYouItems
        vm.newArrivals = HomeMockData.mockNewArrivals
        vm.trendingItems = HomeMockData.mockTrendingItems
        vm.recommendedItems = HomeMockData.mockRecommendedItems
        vm.hasNotifications = true
        vm.isLoading = false
        return vm
    }
}
#endif
