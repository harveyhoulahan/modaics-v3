import SwiftUI
import MapKit

// MARK: - DiscoverView
/// Main discovery view with static header, category tabs, and content switching
public struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            Color.modaicsBackground
                .ignoresSafeArea()
            
            // Main Content
            VStack(spacing: 0) {
                // FIXED header — always visible, never collapses
                discoverHeader
                
                // Category selector — always visible below header
                categorySelector
                
                // Content area — scrollable, changes based on category
                contentArea
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
    
    // MARK: - Fixed Header
    private var discoverHeader: some View {
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
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
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
                
                Color.clear.frame(height: 20)
            }
            .padding(.top, 8)
        }
        .refreshable {
            await viewModel.loadItems(reset: true)
        }
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
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.sageMuted)
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
                    .foregroundColor(.luxeGold)
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
    
    // MARK: - Subcategory Strip
    private var subcategoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All button
                SubcategoryPill(
                    title: "ALL",
                    isSelected: viewModel.selectedSubCategory == nil
                ) {
                    viewModel.selectSubCategory(nil)
                }
                
                ForEach(Category.allCases) { category in
                    SubcategoryPill(
                        title: category.displayName,
                        isSelected: viewModel.selectedSubCategory == category
                    ) {
                        viewModel.selectSubCategory(category)
                    }
                }
            }
            .padding(.horizontal, 20)
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
                    
                    Text(viewModel.sortOption.displayName)
                        .font(.forestCaptionSmall)
                        .lineLimit(1)
                }
                .foregroundColor(.sageWhite)
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
                        .font(.forestCaptionSmall)
                    
                    if viewModel.filterCriteria.activeFilterCount > 0 {
                        Text("\(viewModel.filterCriteria.activeFilterCount)")
                            .font(.forestCaptionSmall)
                            .fontWeight(.bold)
                            .foregroundColor(Color.modaicsBackground)
                            .frame(minWidth: 18, minHeight: 18)
                            .background(Color.luxeGold)
                            .cornerRadius(9)
                    }
                }
                .foregroundColor(.sageWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.modaicsSurface)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(viewModel.filterCriteria.activeFilterCount > 0 ? Color.luxeGold : Color.luxeGold.opacity(0.2), 
                               lineWidth: viewModel.filterCriteria.activeFilterCount > 0 ? 1.5 : 1)
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
                    .font(.forestHeadlineSmall)
                    .foregroundColor(Color.sageWhite)
                    .tracking(1)
                
                Text(viewModel.emptyStateMessage)
                    .font(.forestBodyMedium)
                    .foregroundColor(Color.sageMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Reset Button
            if viewModel.filterCriteria.activeFilterCount > 0 || !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.resetFilters()
                    viewModel.clearSearch()
                }) {
                    Text("CLEAR ALL FILTERS")
                        .font(.forestBodyLarge)
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
    
    // MARK: - Events Content
    private var eventsContent: some View {
        VStack(spacing: 0) {
            // Search bar for events
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.sageMuted)
                
                TextField("", text: .constant(""))
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageWhite)
                    .placeholder(when: true) {
                        Text("SEARCH EVENTS...")
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageMuted)
                    }
                    .disabled(true)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.modaicsSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.luxeGold.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // List/Map toggle
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.eventViewMode = .list
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 14))
                        Text("LIST")
                            .font(.forestCaptionSmall)
                    }
                    .foregroundColor(viewModel.eventViewMode == .list ? .modaicsBackground : .sageWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(viewModel.eventViewMode == .list ? Color.luxeGold : Color.modaicsSurface)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.eventViewMode = .map
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "map")
                            .font(.system(size: 14))
                        Text("MAP")
                            .font(.forestCaptionSmall)
                    }
                    .foregroundColor(viewModel.eventViewMode == .map ? .modaicsBackground : .sageWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(viewModel.eventViewMode == .map ? Color.luxeGold : Color.modaicsSurface)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Content based on view mode
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
            }
        }
    }
    
    // MARK: - Events List View
    private var eventsListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
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
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
            .tracking(0.5)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
            .clipShape(Capsule())
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
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.forestCaptionSmall)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
                .tracking(0.5)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.luxeGold.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Item Card Skeleton
struct ItemCardSkeleton: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image placeholder
            Rectangle()
                .fill(Color.modaicsSurface)
                .aspectRatio(3/4, contentMode: .fit)
                .overlay(
                    shimmerOverlay
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Text placeholders
            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(Color.modaicsSurface)
                    .frame(height: 16)
                    .overlay(shimmerOverlay)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color.modaicsSurface)
                    .frame(width: 80, height: 14)
                    .overlay(shimmerOverlay)
                    .cornerRadius(4)
                
                HStack {
                    Rectangle()
                        .fill(Color.modaicsSurface)
                        .frame(width: 50, height: 12)
                        .overlay(shimmerOverlay)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(Color.modaicsSurface)
                        .frame(width: 40, height: 14)
                        .overlay(shimmerOverlay)
                        .cornerRadius(4)
                }
            }
        }
        .padding(12)
        .background(Color.modaicsSurface.opacity(0.5))
        .cornerRadius(12)
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    private var shimmerOverlay: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.modaicsSurface,
                    Color.modaicsSurfaceHighlight.opacity(0.5),
                    Color.modaicsSurface
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
        }
    }
}

// MARK: - Preview
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
