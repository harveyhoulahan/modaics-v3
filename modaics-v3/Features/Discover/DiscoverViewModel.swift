import Foundation
import SwiftUI
import Combine
import MapKit

// MARK: - DiscoverCategory
/// Top-level discovery categories
public enum DiscoverCategory: String, CaseIterable, Identifiable {
    case clothing = "Clothing"
    case events = "Events"
    case workshops = "Workshops"
    case popUps = "Pop-Ups"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .clothing: return "tshirt.fill"
        case .events: return "calendar"
        case .workshops: return "hammer.fill"
        case .popUps: return "sparkles"
        }
    }
}

// MARK: - EventViewMode
public enum EventViewMode {
    case list, map
}

// MARK: - DiscoverViewModel
@MainActor
public class DiscoverViewModel: ObservableObject {
    
    // MARK: - Top-level category
    @Published public var selectedDiscoverCategory: DiscoverCategory = .clothing
    
    // MARK: - Clothing mode
    @Published public var searchQuery: String = ""
    @Published public var searchSuggestions: [SearchSuggestion] = []
    @Published public var showSearchSuggestions: Bool = false
    @Published public var trendingSearches: [SearchSuggestion] = []
    @Published public var items: [FashionItem] = []
    @Published public var selectedSubCategory: Category? = nil
    @Published public var sortOption: SortOption = .recent
    @Published public var showSortOptions: Bool = false
    @Published public var filterCriteria: FilterCriteria = FilterCriteria()
    @Published public var showFilterSheet: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var isLoadingMore: Bool = false
    @Published public var hasMoreItems: Bool = false
    
    // MARK: - Events/Map mode
    @Published public var eventViewMode: EventViewMode = .list
    @Published public var events: [CommunityEvent] = []
    @Published public var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631),
        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
    )
    @Published public var selectedEvent: CommunityEvent? = nil
    @Published public var showEventDetail: Bool = false
    
    // MARK: - Visual search
    @Published public var showVisualSearch: Bool = false
    
    // MARK: - Pagination
    private var currentPage: Int = 1
    private let itemsPerPage: Int = 20
    
    // MARK: - Dependencies
    private let apiClient: SearchAPIClient
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    public init(apiClient: SearchAPIClient? = nil) {
        self.apiClient = apiClient ?? SearchAPIClient.shared
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Debounce search query
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] query in
                self?.fetchSearchSuggestions(query: query)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    public func loadInitialData() async {
        await loadItems(reset: true)
        await loadTrendingSearches()
        loadEvents()
    }
    
    public func loadItems(reset: Bool = false) async {
        if reset {
            currentPage = 1
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        do {
            let parameters = SearchParameters(
                query: searchQuery.isEmpty ? nil : searchQuery,
                category: selectedSubCategory,
                condition: filterCriteria.condition,
                minPrice: filterCriteria.minPrice > 0 ? filterCriteria.minPrice : nil,
                maxPrice: filterCriteria.maxPrice < 2000 ? filterCriteria.maxPrice : nil,
                sortBy: sortOption,
                page: currentPage,
                limit: itemsPerPage,
                sustainabilityOnly: filterCriteria.sustainabilityOnly,
                vintageOnly: filterCriteria.vintageOnly
            )
            
            let response = try await apiClient.search(parameters: parameters)
            
            if reset {
                items = response.items
            } else {
                items.append(contentsOf: response.items)
            }
            
            hasMoreItems = response.hasMore
            
        } catch {
            print("Search error: \(error)")
        }
        
        isLoading = false
        isLoadingMore = false
    }
    
    public func loadMoreItems() async {
        guard !isLoadingMore && hasMoreItems else { return }
        currentPage += 1
        await loadItems(reset: false)
    }
    
    public func loadEvents() {
        events = CommunityEvent.mockEvents
    }
    
    // MARK: - Search Suggestions
    private func fetchSearchSuggestions(query: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            do {
                let suggestions = try await apiClient.getSearchSuggestions(query: query)
                if !Task.isCancelled {
                    self.searchSuggestions = suggestions
                    self.showSearchSuggestions = !suggestions.isEmpty
                }
            } catch {
                print("Failed to fetch suggestions: \(error)")
            }
        }
    }
    
    private func loadTrendingSearches() async {
        do {
            trendingSearches = try await apiClient.getTrendingSearches()
        } catch {
            print("Failed to load trending searches: \(error)")
        }
    }
    
    // MARK: - Actions
    public func selectDiscoverCategory(_ category: DiscoverCategory) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDiscoverCategory = category
        }
        
        if category != .clothing && events.isEmpty {
            loadEvents()
        }
    }
    
    public func performSearch() {
        showSearchSuggestions = false
        Task {
            await loadItems(reset: true)
        }
    }
    
    public func selectSearchSuggestion(_ suggestion: SearchSuggestion) {
        searchQuery = suggestion.text
        showSearchSuggestions = false
        performSearch()
    }
    
    public func selectSubCategory(_ category: Category?) {
        selectedSubCategory = category
        Task {
            await loadItems(reset: true)
        }
    }
    
    public func setSortOption(_ option: SortOption) {
        sortOption = option
        showSortOptions = false
        Task {
            await loadItems(reset: true)
        }
    }
    
    public func applyFilters() {
        Task {
            await loadItems(reset: true)
        }
    }
    
    public func resetFilters() {
        filterCriteria = FilterCriteria()
        Task {
            await loadItems(reset: true)
        }
    }
    
    public func clearSearch() {
        searchQuery = ""
        showSearchSuggestions = false
        searchSuggestions = []
        Task {
            await loadItems(reset: true)
        }
    }
    
    public func toggleLike(for item: FashionItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            var updatedItem = items[index]
            updatedItem = FashionItem(
                id: updatedItem.id,
                brand: updatedItem.brand,
                name: updatedItem.name,
                description: updatedItem.description,
                price: updatedItem.price,
                originalPrice: updatedItem.originalPrice,
                category: updatedItem.category,
                condition: updatedItem.condition,
                size: updatedItem.size,
                images: updatedItem.images,
                sellerId: updatedItem.sellerId,
                sellerName: updatedItem.sellerName,
                sellerAvatar: updatedItem.sellerAvatar,
                sustainabilityScore: updatedItem.sustainabilityScore,
                materials: updatedItem.materials,
                isVintage: updatedItem.isVintage,
                isRecycled: updatedItem.isRecycled,
                createdAt: updatedItem.createdAt,
                likes: updatedItem.isLiked ? updatedItem.likes - 1 : updatedItem.likes + 1,
                isLiked: !updatedItem.isLiked
            )
            items[index] = updatedItem
        }
    }
    
    // MARK: - Visual Search
    public func performVisualSearch(image: UIImage) async {
        isLoading = true
        
        do {
            let parameters = SearchParameters(
                category: selectedSubCategory,
                sortBy: sortOption,
                page: 1,
                limit: itemsPerPage
            )
            
            let response = try await apiClient.visualSearch(image: image, parameters: parameters)
            items = response.items
            hasMoreItems = response.hasMore
            
        } catch {
            print("Visual search error: \(error)")
        }
        
        isLoading = false
        showVisualSearch = false
    }
    
    // MARK: - Computed Properties
    public var filteredEvents: [CommunityEvent] {
        let typeFilter: [CommunityEventType]
        switch selectedDiscoverCategory {
        case .clothing:
            return []
        case .events:
            typeFilter = [.market, .exhibition, .talk, .party, .swapMeet]
        case .workshops:
            typeFilter = [.workshop, .classSession]
        case .popUps:
            typeFilter = [.popUp]
        }
        return events
            .filter { typeFilter.contains($0.type) }
            .sorted { $0.startDate < $1.startDate }
    }
    
    public var isEmpty: Bool {
        items.isEmpty && !isLoading
    }
    
    public var emptyStateTitle: String {
        if !searchQuery.isEmpty {
            return "NO RESULTS FOUND"
        } else if filterCriteria.activeFilterCount > 0 {
            return "NO ITEMS MATCH"
        } else {
            return "NO ITEMS YET"
        }
    }
    
    public var emptyStateMessage: String {
        if !searchQuery.isEmpty {
            return "Try adjusting your search or filters to find what you're looking for."
        } else if filterCriteria.activeFilterCount > 0 {
            return "Try removing some filters to see more items."
        } else {
            return "Check back soon for new sustainable fashion items!"
        }
    }
}
