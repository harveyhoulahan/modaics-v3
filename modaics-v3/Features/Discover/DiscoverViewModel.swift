import Foundation
import SwiftUI
import Combine

// MARK: - DiscoverViewModel
// ViewModel with search, filtering, sorting logic for the Discover page

@MainActor
public class DiscoverViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // Search
    @Published public var searchQuery: String = ""
    @Published public var searchSuggestions: [SearchAPIClient.SearchSuggestion] = []
    @Published public var showSearchSuggestions: Bool = false
    @Published public var trendingSearches: [SearchAPIClient.SearchSuggestion] = []
    
    // Results
    @Published public var items: [FashionItem] = []
    @Published public var isLoading: Bool = false
    @Published public var isLoadingMore: Bool = false
    @Published public var errorMessage: String?
    @Published public var hasMoreItems: Bool = false
    
    // Category Filter
    @Published public var selectedCategory: Category? = nil
    @Published public var categoryFilters: [Category] = Category.allCases
    
    // Sort
    @Published public var sortOption: SortOption = .newest
    @Published public var showSortOptions: Bool = false
    
    // Filters
    @Published public var filterCriteria: FilterCriteria = FilterCriteria()
    @Published public var showFilterSheet: Bool = false
    @Published public var activeFilterCount: Int = 0
    
    // Visual Search
    @Published public var showVisualSearch: Bool = false
    @Published public var visualSearchImage: UIImage?
    
    // Header
    @Published public var isHeaderCollapsed: Bool = false
    
    // Pagination
    private var currentPage: Int = 1
    private let itemsPerPage: Int = 20
    
    // Dependencies
    private let apiClient: SearchAPIClient
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    public init(apiClient: SearchAPIClient = .shared) {
        self.apiClient = apiClient
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
        
        // Update active filter count
        $filterCriteria
            .map { $0.activeFilterCount }
            .assign(to: &$activeFilterCount)
    }
    
    // MARK: - Data Loading
    
    public func loadInitialData() async {
        await loadItems(reset: true)
        await loadTrendingSearches()
    }
    
    public func loadItems(reset: Bool = false) async {
        if reset {
            currentPage = 1
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        errorMessage = nil
        
        do {
            let parameters = SearchAPIClient.SearchParameters(
                query: searchQuery.isEmpty ? nil : searchQuery,
                category: selectedCategory,
                condition: filterCriteria.condition,
                size: filterCriteria.size,
                minPrice: filterCriteria.minPrice > 0 ? filterCriteria.minPrice : nil,
                maxPrice: filterCriteria.maxPrice < 2000 ? filterCriteria.maxPrice : nil,
                sustainabilityOnly: filterCriteria.sustainabilityOnly,
                vintageOnly: filterCriteria.vintageOnly,
                sortBy: sortOption,
                page: currentPage,
                limit: itemsPerPage
            )
            
            let response = try await apiClient.search(parameters: parameters)
            
            if reset {
                items = response.items
            } else {
                items.append(contentsOf: response.items)
            }
            
            hasMoreItems = response.hasMore
            
        } catch {
            errorMessage = "Failed to load items. Please try again."
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
    
    public func performSearch() {
        showSearchSuggestions = false
        Task {
            await loadItems(reset: true)
        }
    }
    
    public func selectSearchSuggestion(_ suggestion: SearchAPIClient.SearchSuggestion) {
        searchQuery = suggestion.text
        showSearchSuggestions = false
        performSearch()
    }
    
    public func selectCategory(_ category: Category?) {
        selectedCategory = category
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
    
    // MARK: - Like Action
    
    public func toggleLike(for item: FashionItem) {
        // In real implementation, this would call an API
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
        visualSearchImage = image
        
        do {
            let parameters = SearchAPIClient.SearchParameters(
                category: selectedCategory,
                sortBy: sortOption,
                page: 1,
                limit: itemsPerPage
            )
            
            let response = try await apiClient.visualSearch(image: image, parameters: parameters)
            items = response.items
            hasMoreItems = response.hasMore
            
        } catch {
            errorMessage = "Visual search failed. Please try again."
            print("Visual search error: \(error)")
        }
        
        isLoading = false
        showVisualSearch = false
    }
    
    // MARK: - Header
    
    public func updateHeaderState(isCollapsed: Bool) {
        isHeaderCollapsed = isCollapsed
    }
    
    // MARK: - Pull to Refresh
    
    public func refresh() async {
        await loadItems(reset: true)
    }
}

// MARK: - Empty State
extension DiscoverViewModel {
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
