import SwiftUI
import MapKit

// MARK: - DiscoverView
/// Main discovery view with collapsable header, category tabs, and content switching
public struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @State private var scrollOffset: CGFloat = 0
    
    private let headerHeight: CGFloat = 110
    private let categorySelectorHeight: CGFloat = 60
    private let collapsedThreshold: CGFloat = 50
    
    public init() {}
    
    private var headerCollapseProgress: CGFloat {
        let progress = min(1, max(0, scrollOffset / collapsedThreshold))
        return progress
    }
    
    public var body: some View {
        ZStack {
            // Background
            Color.modaicsBackground
                .ignoresSafeArea()
            
            // Main Content with integrated scrolling
            ScrollView(showsIndicators: false) {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    // Collapsable Header
                    collapsableHeader
                    
                    // Content area - changes based on category
                    contentArea
                    
                    // Bottom padding for tab bar
                    Color.clear.frame(height: 100)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
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
        .sheet(isPresented: $viewModel.showEventDetail) {
            if let event = viewModel.selectedEvent {
                EventDetailSheet(event: event)
            }
        }
        .actionSheet(isPresented: $viewModel.showSortOptions) {
            ActionSheet(
                title: Text("SORT BY").font(.system(.headline, design: .monospaced)),
                buttons: SortOption.allCases.map { option in
                    .default(Text(option.displayName)) {
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
    
    // MARK: - Collapsable Header
    private var collapsableHeader: some View {
        VStack(spacing: 0) {
            // Title section that collapses
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("DISCOVER")
                        .font(.forestDisplaySmall)
                        .foregroundColor(.sageWhite)
                        .tracking(2)
                    
                    Spacer()
                    
                    // Notification bell
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.sageMuted)
                    }
                }
                
                Text("Find pieces, events & more nearby")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(Color.modaicsBackground)
            // Collapse animation
            .frame(height: headerHeight * (1 - headerCollapseProgress * 0.5))
            .opacity(1 - headerCollapseProgress)
            .clipped()
            
            // Category selector - also collapses slightly
            categorySelector
                .frame(height: categorySelectorHeight * (1 - headerCollapseProgress * 0.3))
                .opacity(1 - headerCollapseProgress * 0.5)
        }
        .background(Color.modaicsBackground)
    }
    
    // MARK: - Category Selector
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(DiscoverCategory.allCases) { category in
                    CategoryTabPill(
                        category: category,
                        isSelected: viewModel.selectedDiscoverCategory == category
                    ) {
                        viewModel.selectDiscoverCategory(category)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .background(Color.modaicsBackground)
    }
    
    // MARK: - Content Area
    private var contentArea: some View {
        Group {
            switch viewModel.selectedDiscoverCategory {
            case .clothing:
                clothingContent
            case .events, .workshops, .popUps:
                eventsContent
            }
        }
    }
    
    // MARK: - Clothing Content
    private var clothingContent: some View {
        VStack(spacing: 16) {
            // Search bar
            searchBar
                .padding(.horizontal, 20)
            
            // Sub-category filter strip
            subcategoryStrip
            
            // Sort and filter controls
            sortFilterBar
                .padding(.horizontal, 20)
            
            // Results or empty/loading state
            if viewModel.isLoading && viewModel.items.isEmpty {
                shimmerGrid
                    .padding(.horizontal, 20)
            } else if viewModel.isEmpty {
                emptyStateView
                    .padding(.horizontal, 20)
            } else {
                resultsGrid
                    .padding(.horizontal, 20)
            }
            
            // Load more indicator
            if viewModel.isLoadingMore {
                ProgressView()
                    .tint(Color.luxeGold)
                    .frame(height: 50)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            // Search Icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.sageMuted)
            
            // Search TextField
            TextField("", text: $viewModel.searchQuery)
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
                .placeholder(when: viewModel.searchQuery.isEmpty) {
                    Text("SEARCH GARMENTS...")
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageMuted)
                }
                .submitLabel(.search)
                .onSubmit {
                    viewModel.performSearch()
                }
            
            // Clear Button
            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.searchQuery = ""
                    viewModel.performSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.sageMuted)
                }
            }
            
            // Visual Search Button
            Button(action: {
                viewModel.showVisualSearch = true
            }) {
                Image(systemName: "camera")
                    .font(.system(size: 18))
                    .foregroundColor(.luxeGold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.luxeGold.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Subcategory Strip
    private var subcategoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All option
                SubcategoryPill(
                    title: "ALL",
                    icon: "square.grid.2x2",
                    isSelected: viewModel.selectedSubCategory == nil
                ) {
                    viewModel.selectSubCategory(nil)
                }
                
                // Category options
                ForEach(Category.allCases) { category in
                    SubcategoryPill(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: viewModel.selectedSubCategory == category
                    ) {
                        viewModel.selectSubCategory(category)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
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
                    Text(viewModel.sortOption.displayName.uppercased())
                        .font(.forestCaptionSmall)
                }
                .foregroundColor(.sageWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.modaicsSurface)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
            }
            
            Spacer()
            
            // Filter Button
            Button(action: {
                viewModel.showFilterSheet = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 12))
                    Text("FILTERS")
                        .font(.forestCaptionSmall)
                    
                    if viewModel.activeFilterCount > 0 {
                        Text("(\(viewModel.activeFilterCount))")
                            .font(.forestCaptionSmall)
                            .foregroundColor(.luxeGold)
                    }
                }
                .foregroundColor(.sageWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(viewModel.activeFilterCount > 0 ? Color.luxeGold.opacity(0.15) : Color.modaicsSurface)
                )
                .overlay(
                    Capsule()
                        .stroke(viewModel.activeFilterCount > 0 ? Color.luxeGold : Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Results Grid
    private var resultsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ForEach(viewModel.items) { item in
                ItemCard(
                    item: item,
                    onLikeTapped: {
                        viewModel.toggleLike(item)
                    },
                    onCardTapped: {
                        // Show detail
                    }
                )
            }
        }
    }
    
    // MARK: - Shimmer Grid (Loading)
    private var shimmerGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ForEach(0..<6) { _ in
                ItemCard(
                    title: "Loading...",
                    subtitle: nil,
                    isLoading: true
                )
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.sageSubtle)
            
            Text(viewModel.emptyStateTitle)
                .font(.forestHeadlineMedium)
                .foregroundColor(.sageWhite)
                .multilineTextAlignment(.center)
            
            Text("Try adjusting your search or filters")
                .font(.forestCaptionMedium)
                .foregroundColor(.sageMuted)
                .multilineTextAlignment(.center)
            
            Button(action: {
                viewModel.resetFilters()
            }) {
                Text("CLEAR FILTERS")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.modaicsBackground)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.luxeGold)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(minHeight: 400)
    }
    
    // MARK: - Events Content
    private var eventsContent: some View {
        VStack(spacing: 16) {
            // View mode toggle (List / Map)
            viewModeToggle
                .padding(.horizontal, 20)
            
            // Content based on mode
            if viewModel.eventViewMode == .list {
                eventsListView
            } else {
                DiscoverMapView(
                    region: $viewModel.mapRegion,
                    events: viewModel.filteredEvents,
                    selectedEvent: $viewModel.selectedEvent,
                    onEventTap: { event in
                        viewModel.selectedEvent = event
                        viewModel.showEventDetail = true
                    }
                )
                .frame(height: 500)
            }
        }
    }
    
    // MARK: - View Mode Toggle
    private var viewModeToggle: some View {
        HStack(spacing: 0) {
            ForEach([EventViewMode.list, EventViewMode.map], id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.eventViewMode = mode
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: mode == .list ? "list.bullet" : "map")
                            .font(.system(size: 14))
                        Text(mode == .list ? "LIST" : "MAP")
                            .font(.forestCaptionSmall)
                    }
                    .foregroundColor(viewModel.eventViewMode == mode ? .modaicsBackground : .sageWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        viewModel.eventViewMode == mode ? Color.luxeGold : Color.modaicsSurface
                    )
                }
            }
        }
        .background(Color.modaicsSurface)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
        )
    }
    
    // MARK: - Events List View
    private var eventsListView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.filteredEvents) { event in
                EventListCard(event: event, onTap: {
                    viewModel.selectedEvent = event
                    viewModel.showEventDetail = true
                })
            }
            
            Color.clear.frame(height: 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Category Tab Pill
struct CategoryTabPill: View {
    let category: DiscoverCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(category.rawValue.uppercased())
                    .font(.forestCaptionSmall)
            }
            .foregroundColor(isSelected ? .modaicsBackground : .sageMuted)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.luxeGold : Color.modaicsSurface)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Subcategory Pill
struct SubcategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.forestCaptionSmall)
            }
            .foregroundColor(isSelected ? .modaicsBackground : .sageWhite)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.luxeGold : Color.modaicsSurface)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}