import SwiftUI
import Combine

// MARK: - DiscoveryViewModel
/// ViewModel for the Discovery feature
/// Manages garment feed, search, and filtering
@MainActor
public final class DiscoveryViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// All loaded garments
    @Published public var garments: [ModaicsGarment] = []
    
    /// Filtered/search results
    @Published public var filteredGarments: [ModaicsGarment] = []
    
    /// New arrivals section
    @Published public var newArrivals: [ModaicsGarment] = []
    
    /// Trending section
    @Published public var trendingGarments: [ModaicsGarment] = []
    
    /// Current search query
    @Published public var searchQuery: String = ""
    
    /// Loading state
    @Published public var isLoading: Bool = false
    
    /// Error message if any
    @Published public var error: Error?
    
    /// Whether an error occurred
    @Published public var hasError: Bool = false
    
    /// Selected category filter
    @Published public var selectedCategory: ModaicsCategory?
    
    /// Selected condition filter
    @Published public var selectedCondition: ModaicsCondition?
    
    /// Favorite garment IDs
    @Published public var favoriteGarmentIds: Set<UUID> = []
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init() {
        setupSearchDebounce()
    }
    
    // MARK: - Search Debounce
    
    private func setupSearchDebounce() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Load initial garment data
    public func loadGarments() async {
        isLoading = true
        hasError = false
        error = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Generate mock data
        let mockGarments = generateMockGarments()
        
        garments = mockGarments
        filteredGarments = mockGarments
        
        // Split into sections
        newArrivals = Array(mockGarments.prefix(4))
        trendingGarments = Array(mockGarments.shuffled().prefix(6))
        
        isLoading = false
    }
    
    /// Refresh the feed
    public func refresh() async {
        await loadGarments()
    }
    
    /// Search garments by query
    public func search(query: String) {
        searchQuery = query
    }
    
    /// Clear search
    public func clearSearch() {
        searchQuery = ""
        filteredGarments = garments
        applyFilters()
    }
    
    /// Filter by category
    public func filterByCategory(_ category: ModaicsCategory?) {
        selectedCategory = category
        applyFilters()
    }
    
    /// Filter by condition
    public func filterByCondition(_ condition: ModaicsCondition?) {
        selectedCondition = condition
        applyFilters()
    }
    
    /// Clear all filters
    public func clearFilters() {
        selectedCategory = nil
        selectedCondition = nil
        filteredGarments = garments
    }
    
    /// Toggle favorite status for a garment
    public func toggleFavorite(for garmentId: UUID) {
        if favoriteGarmentIds.contains(garmentId) {
            favoriteGarmentIds.remove(garmentId)
        } else {
            favoriteGarmentIds.insert(garmentId)
        }
    }
    
    /// Check if garment is favorited
    public func isFavorite(_ garmentId: UUID) -> Bool {
        favoriteGarmentIds.contains(garmentId)
    }
    
    // MARK: - Private Methods
    
    private func performSearch(query: String) {
        if query.isEmpty {
            filteredGarments = garments
        } else {
            let lowercasedQuery = query.lowercased()
            filteredGarments = garments.filter { garment in
                garment.title.lowercased().contains(lowercasedQuery) ||
                garment.description.lowercased().contains(lowercasedQuery) ||
                garment.brand?.name.lowercased().contains(lowercasedQuery) == true ||
                garment.styleTags.contains { $0.lowercased().contains(lowercasedQuery) }
            }
        }
        applyFilters()
    }
    
    private func applyFilters() {
        var result = filteredGarments
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if let condition = selectedCondition {
            result = result.filter { $0.condition == condition }
        }
        
        filteredGarments = result
    }
    
    // MARK: - Mock Data Generation
    
    private func generateMockGarments() -> [ModaicsGarment] {
        [
            ModaicsGarment(
                id: UUID(),
                title: "Vintage Silk Blouse",
                description: "Beautiful 90s silk blouse in cream color",
                storyId: UUID(),
                condition: .excellent,
                originalPrice: 180.00,
                listingPrice: 85.00,
                category: .tops,
                styleTags: ["vintage", "silk", "minimalist"],
                colors: [ModaicsGarmentColor(name: "Cream", hex: "#FFFDD0")],
                materials: [ModaicsMaterial(name: "Silk", percentage: 100, isSustainable: true)],
                brand: ModaicsBrand(name: "Theory", isLuxury: false, isSustainable: true),
                size: ModaicsSize(label: "S", system: .us),
                ownerId: UUID(),
                isListed: true,
                exchangeType: .sell
            ),
            ModaicsGarment(
                id: UUID(),
                title: "Oversized Wool Coat",
                description: "Cozy oversized wool coat in camel",
                storyId: UUID(),
                condition: .veryGood,
                originalPrice: 450.00,
                listingPrice: 220.00,
                category: .outerwear,
                styleTags: ["minimalist", "classic", "winter"],
                colors: [ModaicsGarmentColor(name: "Camel", hex: "#C19A6B")],
                materials: [ModaicsMaterial(name: "Wool", percentage: 80, isSustainable: true)],
                brand: ModaicsBrand(name: "Max Mara", isLuxury: true, isSustainable: false),
                size: ModaicsSize(label: "M", system: .us),
                ownerId: UUID(),
                isListed: true,
                exchangeType: .sellOrTrade
            ),
            ModaicsGarment(
                id: UUID(),
                title: "Leather Ankle Boots",
                description: "Classic leather ankle boots, barely worn",
                storyId: UUID(),
                condition: .excellent,
                originalPrice: 320.00,
                listingPrice: 150.00,
                category: .shoes,
                styleTags: ["classic", "leather", "versatile"],
                colors: [ModaicsGarmentColor(name: "Black", hex: "#000000")],
                materials: [ModaicsMaterial(name: "Leather", percentage: 100, isSustainable: false)],
                brand: ModaicsBrand(name: "Common Projects", isLuxury: true, isSustainable: false),
                size: ModaicsSize(label: "38", system: .eu),
                ownerId: UUID(),
                isListed: true,
                exchangeType: .sell
            ),
            ModaicsGarment(
                id: UUID(),
                title: "Linen Midi Dress",
                description: "Perfect summer linen dress in olive",
                storyId: UUID(),
                condition: .newWithoutTags,
                originalPrice: 195.00,
                listingPrice: 120.00,
                category: .dresses,
                styleTags: ["bohemian", "summer", "natural"],
                colors: [ModaicsGarmentColor(name: "Olive", hex: "#808000")],
                materials: [ModaicsMaterial(name: "Linen", percentage: 100, isSustainable: true)],
                brand: ModaicsBrand(name: "Reformation", isLuxury: false, isSustainable: true),
                size: ModaicsSize(label: "M", system: .us),
                ownerId: UUID(),
                isListed: true,
                exchangeType: .sellOrTrade
            ),
            ModaicsGarment(
                id: UUID(),
                title: "Cashmere Turtleneck",
                description: "Luxurious cashmere in terracotta",
                storyId: UUID(),
                condition: .excellent,
                originalPrice: 295.00,
                listingPrice: 145.00,
                category: .tops,
                styleTags: ["luxury", "cozy", "autumn"],
                colors: [ModaicsGarmentColor(name: "Terracotta", hex: "#E2725B")],
                materials: [ModaicsMaterial(name: "Cashmere", percentage: 100, isSustainable: true)],
                brand: ModaicsBrand(name: "Everlane", isLuxury: false, isSustainable: true),
                size: ModaicsSize(label: "S", system: .us),
                ownerId: UUID(),
                isListed: true,
                exchangeType: .sell
            ),
            ModaicsGarment(
                id: UUID(),
                title: "Vintage Denim Jacket",
                description: "80s vintage Levi's denim jacket",
                storyId: UUID(),
                condition: .good,
                originalPrice: 98.00,
                listingPrice: 65.00,
                category: .outerwear,
                styleTags: ["vintage", "denim", "classic"],
                colors: [ModaicsGarmentColor(name: "Blue", hex: "#4169E1")],
                materials: [ModaicsMaterial(name: "Cotton", percentage: 100, isSustainable: true)],
                brand: ModaicsBrand(name: "Levi's", isLuxury: false, isSustainable: false),
                size: ModaicsSize(label: "L", system: .us),
                era: .eighties,
                ownerId: UUID(),
                isListed: true,
                exchangeType: .trade
            ),
            ModaicsGarment(
                id: UUID(),
                title: "Silk Midi Skirt",
                description: "Elegant silk skirt in champagne",
                storyId: UUID(),
                condition: .excellent,
                originalPrice: 245.00,
                listingPrice: 115.00,
                category: .bottoms,
                styleTags: ["elegant", "silk", "minimalist"],
                colors: [ModaicsGarmentColor(name: "Champagne", hex: "#F7E7CE")],
                materials: [ModaicsMaterial(name: "Silk", percentage: 100, isSustainable: true)],
                brand: ModaicsBrand(name: "Vince", isLuxury: true, isSustainable: false),
                size: ModaicsSize(label: "S", system: .us),
                ownerId: UUID(),
                isListed: true,
                exchangeType: .sell
            ),
            ModaicsGarment(
                id: UUID(),
                title: "Handwoven Tote Bag",
                description: "Artisan handwoven tote from Oaxaca",
                storyId: UUID(),
                condition: .newWithTags,
                originalPrice: 150.00,
                listingPrice: 95.00,
                category: .bags,
                styleTags: ["artisan", "handwoven", "bohemian"],
                colors: [ModaicsGarmentColor(name: "Natural", hex: "#D2B48C")],
                materials: [ModaicsMaterial(name: "Cotton", percentage: 100, isSustainable: true)],
                brand: nil,
                size: ModaicsSize(label: "One Size", system: .oneSize),
                ownerId: UUID(),
                isListed: true,
                exchangeType: .sell
            )
        ]
    }
}
