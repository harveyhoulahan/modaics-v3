import SwiftUI

// MARK: - DiscoverView
// Main view with:
// D1: Collapsing header with TrackableScrollView
// D2: Search bar with text + visual (camera) search
// D3: Category filter strip
// D4: Sort controls
// D5: 2-column grid with ItemCard
// D6: FilterView sheet
// D7: Empty state
// D8: Shimmer loading
// D9: Pull-to-refresh
// D10: Search suggestions dropdown

public struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @State private var scrollOffset: CGPoint = .zero
    @State private var isRefreshing = false
    
    // Constants for header collapse
    private let headerHeight: CGFloat = 180
    private let collapsedHeaderHeight: CGFloat = 60
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            Color.modaicsBackground
                .ignoresSafeArea()
            
            // Main Content
            mainContent
            
            // Search Suggestions Overlay
            if viewModel.showSearchSuggestions && !viewModel.searchSuggestions.isEmpty {
                searchSuggestionsOverlay
            }
        }
        .sheet(isPresented: $viewModel.showFilterSheet) {
            FilterView(
                isPresented: $viewModel.showFilterSheet,
                filters: $viewModel.filterCriteria,
                onApply: {
                    viewModel.applyFilters()
                },
                onReset: {
                    viewModel.resetFilters()
                }
            )
        }
        .sheet(isPresented: $viewModel.showVisualSearch) {
            VisualSearchCameraView(
                isPresented: $viewModel.showVisualSearch,
                onImageSelected: { image in
                    Task {
                        await viewModel.performVisualSearch(image: image)
                    }
                }
            )
        }
        .actionSheet(isPresented: $viewModel.showSortOptions) {
            ActionSheet(
                title: Text("SORT BY").font(.system(.headline, design: .monospaced)),
                buttons: SortOption.allCases.map { option in
                    .default(Text(option.rawValue)) {
                        viewModel.setSortOption(option)
                    }
                } + [.cancel()]
            )
        }
        .onAppear {
            Task {
                await viewModel.loadInitialData()
            }
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Collapsible Header
            headerView
            
            // Content with TrackableScrollView
            TrackableScrollView(
                .vertical,
                showIndicators: false,
                threshold: -10,
                scrollOffset: $scrollOffset,
                onScrollNearTop: { isNearTop in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.updateHeaderState(isCollapsed: !isNearTop)
                    }
                }
            ) {
                VStack(spacing: 0) {
                    // Category Filter Strip
                    categoryFilterStrip
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    
                    // Sort and Filter Controls
                    sortFilterBar
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    
                    // Results Grid or Empty State
                    if viewModel.isLoading && viewModel.items.isEmpty {
                        // Shimmer Loading State
                        shimmerGrid
                    } else if viewModel.isEmpty {
                        // Empty State
                        emptyStateView
                    } else {
                        // Results Grid
                        resultsGrid
                    }
                    
                    // Load More Indicator
                    if viewModel.isLoadingMore {
                        ProgressView()
                            .tint(Color.luxeGold)
                            .frame(height: 50)
                    }
                    
                    // Bottom padding
                    Color.clear.frame(height: 20)
                }
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                // Title (shows when collapsed)
                if viewModel.isHeaderCollapsed {
                    Text("DISCOVER")
                        .font(.font(.forestBodyLarge))
                        .foregroundColor(Color.sageWhite)
                        .tracking(2)
                        .transition(.opacity)
                }
                
                Spacer()
                
                // Gold accent line
                Rectangle()
                    .fill(Color.luxeGold)
                    .frame(width: 40, height: 2)
                    .opacity(viewModel.isHeaderCollapsed ? 1 : 0)
            }
            .padding(.horizontal, 16)
            .frame(height: viewModel.isHeaderCollapsed ? collapsedHeaderHeight : 0)
            .background(Color.modaicsBackground)
            
            // Expanded Header Content
            if !viewModel.isHeaderCollapsed {
                VStack(spacing: 16) {
                    // Title
                    HStack {
                        Text("DISCOVER")
                            .font(.font(.forestDisplayLarge))
                            .foregroundColor(Color.sageWhite)
                            .tracking(2)
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(Color.luxeGold)
                            .frame(width: 60, height: 3)
                    }
                    
                    // Search Bar
                    searchBar
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(Color.modaicsBackground)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(Color.modaicsBackground)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            // Search Icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.sageMuted)
            
            // Search TextField
            TextField("", text: $viewModel.searchQuery)
                .font(.font(.forestBodyMedium))
                .foregroundColor(Color.sageWhite)
                .placeholder(when: viewModel.searchQuery.isEmpty) {
                    Text("SEARCH BRANDS, STYLES...")
                        .font(.font(.forestBodyMedium))
                        .foregroundColor(Color.sageMuted)
                }
                .submitLabel(.search)
                .onSubmit {
                    viewModel.performSearch()
                }
            
            // Clear Button
            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.sageMuted)
                }
            }
            
            // Divider
            Rectangle()
                .fill(Color.luxeGold.opacity(0.3))
                .frame(width: 1, height: 20)
            
            // Visual Search Button
            Button(action: {
                viewModel.showVisualSearch = true
            }) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.luxeGold)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.modaicsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.luxeGold.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Search Suggestions Overlay
    
    private var searchSuggestionsOverlay: some View {
        VStack(spacing: 0) {
            // Spacer to push below search bar
            if !viewModel.isHeaderCollapsed {
                Color.clear.frame(height: 140)
            } else {
                Color.clear.frame(height: 70)
            }
            
            // Suggestions List
            VStack(alignment: .leading, spacing: 0) {
                Text("SUGGESTIONS")
                    .font(.font(.forestCaptionSmall))
                    .foregroundColor(Color.luxeGold)
                    .tracking(1.5)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                
                ForEach(viewModel.searchSuggestions.prefix(5)) { suggestion in
                    Button(action: {
                        viewModel.selectSearchSuggestion(suggestion)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: suggestionIcon(for: suggestion.type))
                                .font(.system(size: 14))
                                .foregroundColor(Color.luxeGold)
                            
                            Text(suggestion.text)
                                .font(.font(.forestBodyMedium))
                                .foregroundColor(Color.sageWhite)
                            
                            Spacer()
                            
                            if suggestion.type == .trending {
                                Text("TRENDING")
                                    .font(.font(.forestCaptionSmall))
                                    .foregroundColor(Color.modaicsEco)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.modaicsEco.opacity(0.15))
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    Divider()
                        .background(Color.luxeGold.opacity(0.1))
                        .padding(.horizontal, 16)
                }
                
                // Trending Section
                if !viewModel.trendingSearches.isEmpty && viewModel.searchSuggestions.isEmpty {
                    Text("TRENDING NOW")
                        .font(.font(.forestCaptionSmall))
                        .foregroundColor(Color.luxeGold)
                        .tracking(1.5)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(viewModel.trendingSearches.prefix(6)) { search in
                            Button(action: {
                                viewModel.selectSearchSuggestion(search)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10))
                                    
                                    Text(search.text)
                                        .font(.font(.forestCaptionSmall))
                                }
                                .foregroundColor(Color.sageWhite)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.modaicsSurface)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .background(Color.modaicsBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .background(Color.modaicsBackground.opacity(0.95).ignoresSafeArea())
        .onTapGesture {
            viewModel.showSearchSuggestions = false
        }
    }
    
    // MARK: - Category Filter Strip
    
    private var categoryFilterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All button
                CategoryPill(
                    title: "ALL",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectCategory(nil)
                }
                
                ForEach(Category.allCases) { category in
                    CategoryPill(
                        title: category.displayName,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Sort and Filter Bar
    
    private var sortFilterBar: some View {
        HStack(spacing: 12) {
            // Sort Button
            Button(action: {
                viewModel.showSortOptions = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 12))
                    
                    Text(viewModel.sortOption.rawValue)
                        .font(.font(.forestCaptionSmall))
                        .lineLimit(1)
                }
                .foregroundColor(Color.sageWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.modaicsSurface)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.luxeGold.opacity(0.2), lineWidth: 1)
                )
            }
            
            Spacer()
            
            // Filter Button
            Button(action: {
                viewModel.showFilterSheet = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 12))
                    
                    Text("FILTERS")
                        .font(.font(.forestCaptionSmall))
                    
                    if viewModel.activeFilterCount > 0 {
                        Text("\(viewModel.activeFilterCount)")
                            .font(.font(.forestCaptionSmall))
                            .fontWeight(.bold)
                            .foregroundColor(Color.modaicsBackground)
                            .frame(minWidth: 18, minHeight: 18)
                            .background(Color.luxeGold)
                            .cornerRadius(9)
                    }
                }
                .foregroundColor(Color.sageWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.modaicsSurface)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(viewModel.activeFilterCount > 0 ? Color.luxeGold : Color.luxeGold.opacity(0.2), lineWidth: viewModel.activeFilterCount > 0 ? 1.5 : 1)
                )
            }
        }
    }
    
    // MARK: - Results Grid
    
    private var resultsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 16
        ) {
            ForEach(viewModel.items) { item in
                ItemCard(
                    item: item,
                    onLikeTapped: {
                        viewModel.toggleLike(for: item)
                    },
                    onCardTapped: {
                        // Navigate to item detail
                        print("Tapped item: \(item.id)")
                    }
                )
                .onAppear {
                    if item.id == viewModel.items.last?.id {
                        Task {
                            await viewModel.loadMoreItems()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Shimmer Loading Grid
    
    private var shimmerGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 16
        ) {
            ForEach(0..<6) { _ in
                ItemCardSkeleton()
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.luxeGold.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "bag")
                    .font(.system(size: 40))
                    .foregroundColor(Color.luxeGold)
            }
            
            // Text
            VStack(spacing: 8) {
                Text(viewModel.emptyStateTitle)
                    .font(.font(.forestHeadlineSmall))
                    .foregroundColor(Color.sageWhite)
                    .tracking(1)
                
                Text(viewModel.emptyStateMessage)
                    .font(.font(.forestBodyMedium))
                    .foregroundColor(Color.sageMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Reset Button
            if viewModel.activeFilterCount > 0 || !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.resetFilters()
                    viewModel.clearSearch()
                }) {
                    Text("CLEAR ALL FILTERS")
                        .font(.font(.forestBodyLarge))
                        .foregroundColor(Color.modaicsBackground)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.luxeGold)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .frame(minHeight: 400)
    }
    
    // MARK: - Helpers
    
    private func suggestionIcon(for type: SearchAPIClient.SearchSuggestion.SuggestionType) -> String {
        switch type {
        case .brand:
            return "tag"
        case .category:
            return "folder"
        case .style:
            return "sparkles"
        case .recent:
            return "clock"
        case .trending:
            return "flame"
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.font(.forestCaptionSmall))
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
                .tracking(0.5)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.luxeGold.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - TextField Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
