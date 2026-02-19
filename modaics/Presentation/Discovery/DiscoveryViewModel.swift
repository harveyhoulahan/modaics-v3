import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Source Filter
public enum SourceFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case modaics = "modaics"
    case depop = "depop"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .all: return "All Sources"
        case .modaics: return "Modaics"
        case .depop: return "Depop"
        }
    }
    
    public var icon: String {
        switch self {
        case .all: return "globe"
        case .modaics: return "m.circle.fill"
        case .depop: return "d.circle.fill"
        }
    }
    
    /// Convert to GarmentSource array for API calls
    public var toGarmentSources: [GarmentSource] {
        switch self {
        case .all: return [.modaics, .depop]
        case .modaics: return [.modaics]
        case .depop: return [.depop]
        }
    }
}

// MARK: - Discovery View State

public enum DiscoveryViewState: Equatable {
    case loading
    case loaded([Garment])
    case empty
    case error(String)
    case searchingByImage // v3.5: New state for visual search
    case visualSearchResults([VisualSearchResult]) // v3.5: Visual search results
    
    public static func == (lhs: DiscoveryViewState, rhs: DiscoveryViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.empty, .empty): return true
        case (.error(let lhsMsg), .error(let rhsMsg)): return lhsMsg == rhsMsg
        case (.searchingByImage, .searchingByImage): return true
        case (.loaded(let lhsGarments), .loaded(let rhsGarments)):
            return lhsGarments.map(\.id) == rhsGarments.map(\.id)
        case (.visualSearchResults(let lhsResults), .visualSearchResults(let rhsResults)):
            return lhsResults.map(\.id) == rhsResults.map(\.id)
        default: return false
        }
    }
}

// MARK: - Discovery Tab

public enum DiscoveryTab: String, CaseIterable, Identifiable {
    case forYou = "for_you"
    case trending = "trending"
    case newArrivals = "new_arrivals"
    case visualSearch = "visual_search" // v3.5: Visual search tab
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .forYou: return "For You"
        case .trending: return "Trending"
        case .newArrivals: return "New"
        case .visualSearch: return "Visual"
        }
    }
    
    public var icon: String {
        switch self {
        case .forYou: return "person.fill"
        case .trending: return "flame.fill"
        case .newArrivals: return "sparkles"
        case .visualSearch: return "camera.viewfinder"
        }
    }
    
    var discoveryType: DiscoveryType {
        switch self {
        case .forYou: return .personalizedFeed
        case .trending: return .trending
        case .newArrivals: return .newArrivals
        case .visualSearch: return .search(query: "") // Placeholder
        }
    }
}

// MARK: - Discovery View Model

@MainActor
public class DiscoveryViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var state: DiscoveryViewState = .loading
    @Published public var selectedTab: DiscoveryTab = .forYou
    @Published public var selectedGarment: Garment?
    @Published public var isLoadingMore = false
    @Published public var hasMoreContent = true
    @Published public var searchQuery: String = "" // v3.5: Text search query
    @Published public var sourceFilter: SourceFilter = .all // v3.5: Source filter
    @Published public var isPerformingVisualSearch: Bool = false // v3.5: Visual search state
    @Published public var selectedImageForSearch: UIImage? // v3.5: Selected image
    @Published public var visualSearchResults: [VisualSearchResult] = [] // v3.5: Results
    
    // MARK: - Private Properties
    
    private let discoverUseCase: DiscoverGarmentsUseCaseProtocol?
    private let styleMatchingService: StyleMatchingServiceProtocol? // v3.5: For visual search
    private var currentPage = 1
    private var currentGarments: [Garment] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(
        discoverUseCase: DiscoverGarmentsUseCaseProtocol? = nil,
        styleMatchingService: StyleMatchingServiceProtocol? = nil // v3.5
    ) {
        self.discoverUseCase = discoverUseCase
        self.styleMatchingService = styleMatchingService
        setupBindings()
    }
    
    private func setupBindings() {
        // Debounce search query
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self, !query.isEmpty else { return }
                Task {
                    await self.performTextSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    public func loadGarments() async {
        // Skip regular loading if on visual search tab
        guard selectedTab != .visualSearch else {
            state = .loaded([])
            return
        }
        
        state = .loading
        currentPage = 1
        currentGarments = []
        
        await fetchGarments()
    }
    
    public func loadMore() async {
        guard !isLoadingMore && hasMoreContent else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        await fetchGarments(append: true)
        
        isLoadingMore = false
    }
    
    public func selectTab(_ tab: DiscoveryTab) {
        selectedTab = tab
        Task {
            if tab == .visualSearch {
                // Visual search tab - show empty state or camera
                state = .loaded([])
            } else {
                await loadGarments()
            }
        }
    }
    
    public func selectGarment(_ garment: Garment) {
        selectedGarment = garment
    }
    
    public func toggleFavorite(_ garment: Garment) {
        // In real implementation, would call favorite use case
        print("Toggle favorite for: \(garment.title)")
    }
    
    public func refresh() async {
        await loadGarments()
    }
    
    // MARK: - v3.5: Visual Search
    
    /// Perform visual search using an image
    public func performVisualSearch(image: UIImage) async {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            state = .error("Failed to process image")
            return
        }
        
        guard let styleService = styleMatchingService else {
            // Fallback to mock results if no service available
            await performMockVisualSearch(image: image)
            return
        }
        
        isPerformingVisualSearch = true
        state = .searchingByImage
        selectedImageForSearch = image
        
        do {
            let response = try await styleService.searchByImage(
                imageData: imageData,
                topK: 20,
                sourceFilter: sourceFilter.toGarmentSources
            )
            
            visualSearchResults = response.results
            
            if response.results.isEmpty {
                state = .empty
            } else {
                state = .visualSearchResults(response.results)
            }
            
        } catch {
            state = .error("Visual search failed: \(error.localizedDescription)")
        }
        
        isPerformingVisualSearch = false
    }
    
    /// Perform visual search using an image URL
    public func performVisualSearch(imageUrl: URL) async {
        guard let styleService = styleMatchingService else {
            state = .error("Visual search service not available")
            return
        }
        
        isPerformingVisualSearch = true
        state = .searchingByImage
        
        do {
            let response = try await styleService.searchByImageUrl(
                imageUrl: imageUrl,
                topK: 20,
                sourceFilter: sourceFilter.toGarmentSources
            )
            
            visualSearchResults = response.results
            
            if response.results.isEmpty {
                state = .empty
            } else {
                state = .visualSearchResults(response.results)
            }
            
        } catch {
            state = .error("Visual search failed: \(error.localizedDescription)")
        }
        
        isPerformingVisualSearch = false
    }
    
    /// Clear visual search and return to normal discovery
    public func clearVisualSearch() {
        selectedImageForSearch = nil
        visualSearchResults = []
        if selectedTab == .visualSearch {
            state = .loaded([])
        } else {
            Task {
                await loadGarments()
            }
        }
    }
    
    /// Update source filter and refresh results
    public func updateSourceFilter(_ filter: SourceFilter) async {
        sourceFilter = filter
        
        // If we have visual search results, refresh with new filter
        if !visualSearchResults.isEmpty, let image = selectedImageForSearch {
            await performVisualSearch(image: image)
        } else {
            await loadGarments()
        }
    }
    
    // MARK: - v3.5: Text Search
    
    /// Perform text-based search
    public func performTextSearch(query: String) async {
        guard !query.isEmpty else {
            await loadGarments()
            return
        }
        
        state = .loading
        
        if let useCase = discoverUseCase {
            let input = DiscoverGarmentsInput(
                userId: nil,
                discoveryType: .search(query: query),
                page: 1,
                limit: 20
            )
            
            do {
                let output = try await useCase.execute(input: input)
                currentGarments = output.garments
                
                if currentGarments.isEmpty {
                    state = .empty
                } else {
                    state = .loaded(currentGarments)
                }
            } catch {
                state = .error(error.localizedDescription)
            }
        } else {
            // Mock search
            await performMockSearch(query: query)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchGarments(append: Bool = false) async {
        // Check if we have a real use case
        if let useCase = discoverUseCase {
            await fetchFromUseCase(useCase, append: append)
        } else {
            // Use sample data for preview/development
            await fetchSampleData(append: append)
        }
    }
    
    private func fetchFromUseCase(_ useCase: DiscoverGarmentsUseCaseProtocol, append: Bool) async {
        // Apply source filter to filters
        var filters = DiscoveryFilters()
        // Note: In full implementation, source filter would be part of DiscoveryFilters
        
        let input = DiscoverGarmentsInput(
            userId: nil, // Current user
            discoveryType: selectedTab.discoveryType,
            page: currentPage,
            limit: 20,
            filters: filters
        )
        
        do {
            let output = try await useCase.execute(input: input)
            
            if append {
                currentGarments.append(contentsOf: output.garments)
            } else {
                currentGarments = output.garments
            }
            
            hasMoreContent = output.hasMore
            
            // Filter by source if needed
            if sourceFilter != .all {
                let filteredGarments = currentGarments.filter { garment in
                    switch sourceFilter {
                    case .modaics: return garment.source == .modaics
                    case .depop: return garment.source == .depop
                    case .all: return true
                    }
                }
                
                if filteredGarments.isEmpty {
                    state = .empty
                } else {
                    state = .loaded(filteredGarments)
                }
            } else {
                if currentGarments.isEmpty {
                    state = .empty
                } else {
                    state = .loaded(currentGarments)
                }
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    private func fetchSampleData(append: Bool) async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Include sample from Depop for testing
        let sampleGarments = [
            Garment.sample,
            Garment.sampleDress,
            Garment.sampleFromDepop, // v3.5: Depop sample
            Garment.sampleVintageCoat,
            Garment.sampleLinenShirt,
            Garment.sampleWoolSweater
        ]
        
        // Filter by source if needed
        let filteredGarments: [Garment]
        switch sourceFilter {
        case .all:
            filteredGarments = sampleGarments
        case .modaics:
            filteredGarments = sampleGarments.filter { $0.source == .modaics }
        case .depop:
            filteredGarments = sampleGarments.filter { $0.source == .depop }
        }
        
        if append {
            currentGarments.append(contentsOf: filteredGarments)
        } else {
            currentGarments = filteredGarments
        }
        
        hasMoreContent = currentPage < 3
        
        if currentGarments.isEmpty {
            state = .empty
        } else {
            state = .loaded(currentGarments)
        }
    }
    
    private func performMockSearch(query: String) async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Simple mock search filtering
        let allSamples = [
            Garment.sample,
            Garment.sampleDress,
            Garment.sampleFromDepop,
            Garment.sampleVintageCoat,
            Garment.sampleLinenShirt,
            Garment.sampleWoolSweater
        ]
        
        let lowerQuery = query.lowercased()
        let filtered = allSamples.filter {
            $0.title.lowercased().contains(lowerQuery) ||
            $0.description.lowercased().contains(lowerQuery) ||
            $0.styleTags.contains { $0.lowercased().contains(lowerQuery) }
        }
        
        currentGarments = filtered
        
        if filtered.isEmpty {
            state = .empty
        } else {
            state = .loaded(filtered)
        }
    }
    
    private func performMockVisualSearch(image: UIImage) async {
        isPerformingVisualSearch = true
        state = .searchingByImage
        selectedImageForSearch = image
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Create mock visual search results with similarity scores
        let mockResults = [
            VisualSearchResult(
                garment: Garment.sample,
                similarityScore: 0.94,
                matchReasons: ["Similar leather texture", "Vintage aesthetic", "Dark color palette"]
            ),
            VisualSearchResult(
                garment: Garment.sampleVintageCoat,
                similarityScore: 0.87,
                matchReasons: ["Similar outerwear style", "Vintage era", "Classic design"]
            ),
            VisualSearchResult(
                garment: Garment.sampleFromDepop,
                similarityScore: 0.82,
                matchReasons: ["Similar vintage style", "Outerwear category"]
            )
        ]
        
        // Filter by source if needed
        let filteredResults: [VisualSearchResult]
        switch sourceFilter {
        case .all:
            filteredResults = mockResults
        case .modaics:
            filteredResults = mockResults.filter { $0.garment.source == .modaics }
        case .depop:
            filteredResults = mockResults.filter { $0.garment.source == .depop }
        }
        
        visualSearchResults = filteredResults
        
        if filteredResults.isEmpty {
            state = .empty
        } else {
            state = .visualSearchResults(filteredResults)
        }
        
        isPerformingVisualSearch = false
    }
}

// MARK: - Preview Helpers

extension DiscoveryViewModel {
    public static func preview() -> DiscoveryViewModel {
        let vm = DiscoveryViewModel()
        vm.state = .loaded([
            .sample,
            .sampleDress,
            .sampleFromDepop,
            .sampleVintageCoat,
            .sampleLinenShirt,
            .sampleWoolSweater
        ])
        return vm
    }
    
    public static func previewVisualSearch() -> DiscoveryViewModel {
        let vm = DiscoveryViewModel()
        vm.state = .visualSearchResults([
            VisualSearchResult(
                garment: .sample,
                similarityScore: 0.94,
                matchReasons: ["Similar leather texture", "Vintage aesthetic"]
            ),
            VisualSearchResult(
                garment: .sampleVintageCoat,
                similarityScore: 0.87,
                matchReasons: ["Similar outerwear style", "Vintage era"]
            )
        ])
        return vm
    }
    
    public static func previewEmpty() -> DiscoveryViewModel {
        let vm = DiscoveryViewModel()
        vm.state = .empty
        return vm
    }
    
    public static func previewLoading() -> DiscoveryViewModel {
        DiscoveryViewModel()
    }
    
    public static func previewError() -> DiscoveryViewModel {
        let vm = DiscoveryViewModel()
        vm.state = .error("Network connection failed")
        return vm
    }
}

// MARK: - Sample Data Extensions

extension Garment {
    static let sampleVintageCoat = Garment(
        title: "Camel Wool Overcoat",
        description: "A timeless camel overcoat in heavyweight wool. Single-breasted with notch lapels.",
        story: Story(
            narrative: "My grandfather wore this coat for twenty years through London winters. The lining has been repaired twice, the buttons replaced once, but the wool still holds its shape beautifully.",
            provenance: "Savile Row, London - 1980s",
            whySelling: "Too warm for my current climate, deserves to see more winters"
        ),
        condition: .vintage,
        suggestedPrice: 340.00,
        currency: .gbp,
        category: .outerwear,
        styleTags: ["classic", "vintage", "wool", "timeless"],
        colors: [ModaicsColor(name: "Camel", hex: "#C19A6B")],
        materials: [Material(name: "Wool", percentage: 100)],
        brand: Brand(name: "Burberry", isLuxury: true),
        size: Size(label: "42R", system: .us),
        era: .eighties,
        ownerId: UUID(),
        isListed: true,
        exchangeType: .sell
    )
    
    static let sampleLinenShirt = Garment(
        title: "Oversized Linen Shirt",
        description: "Relaxed fit linen shirt in natural oatmeal. Perfect for Mediterranean summers.",
        story: Story(
            narrative: "Found this in a small atelier in Lisbon. The fabric is from a family-run mill in Porto that has been weaving linen for five generations.",
            provenance: "Lisbon, Portugal"
        ),
        condition: .excellent,
        suggestedPrice: 85.00,
        currency: .gbp,
        category: .tops,
        styleTags: ["minimal", "summer", "natural"],
        colors: [ModaicsColor(name: "Oatmeal", hex: "#E6DCC8")],
        materials: [Material(name: "Linen", percentage: 100, isSustainable: true)],
        brand: Brand(name: "Atelier M", isSustainable: true),
        size: Size(label: "L", system: .us),
        ownerId: UUID(),
        isListed: true,
        exchangeType: .sellOrTrade
    )
    
    static let sampleWoolSweater = Garment(
        title: "Hand-Knit Fisherman Sweater",
        description: "Traditional Aran knit in undyed cream wool. Cable patterns tell the story of Irish fishing families.",
        story: Story(
            narrative: "Each cable pattern has meaning - the honeycomb represents hard work, the diamond marks success. My grandmother taught me to read these patterns before she taught me to read books.",
            provenance: "Aran Islands, Ireland - Handmade",
            whySelling: "Passing it on to someone who will appreciate the craftsmanship"
        ),
        condition: .veryGood,
        suggestedPrice: 165.00,
        currency: .gbp,
        category: .tops,
        styleTags: ["handmade", "heritage", "wool", "cozy"],
        colors: [ModaicsColor(name: "Cream", hex: "#F5F0E8")],
        materials: [Material(name: "Wool", percentage: 100, isSustainable: true)],
        size: Size(label: "M", system: .us),
        era: .contemporary,
        ownerId: UUID(),
        isListed: true,
        exchangeType: .trade
    )
}
