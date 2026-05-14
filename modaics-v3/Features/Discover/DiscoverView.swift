import SwiftUI
import MapKit

// MARK: - DiscoverView
public struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @State private var scrollOffset: CGFloat = 0
    
    private let headerHeight: CGFloat = 110
    private let categorySelectorHeight: CGFloat = 60
    private let collapsedThreshold: CGFloat = 50
    
    private var headerCollapseProgress: CGFloat {
        min(CGFloat(1), max(CGFloat(0), scrollOffset / collapsedThreshold))
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.warmOffWhite.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: DiscoverScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    collapsableHeader
                    contentArea
                    Color.clear.frame(height: 100)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(DiscoverScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
            }
            
            // Search suggestions overlay
            if viewModel.showSearchSuggestions && !viewModel.searchSuggestions.isEmpty {
                searchSuggestionsOverlay
            }
        }
        .sheet(isPresented: $viewModel.showFilterSheet) {
            FilterView(
                isPresented: $viewModel.showFilterSheet,
                filters: $viewModel.filterCriteria,
                onApply: { viewModel.applyFilters() },
                onReset: { viewModel.resetFilters() }
            )
        }
        .sheet(isPresented: $viewModel.showVisualSearch) {
            VisualSearchCameraView(
                isPresented: $viewModel.showVisualSearch,
                onImageSelected: { image in
                    Task { await viewModel.performVisualSearch(image: image) }
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
                title: Text("Sort by"),
                buttons: SortOption.allCases.map { option in
                    .default(Text(option.displayName)) { viewModel.setSortOption(option) }
                } + [.cancel()]
            )
        }
        .onAppear {
            Task { await viewModel.loadInitialData() }
        }
    }
    
    private var collapsableHeader: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Discover")
                        .font(.editorialMedium)
                        .foregroundColor(.nearBlack)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.warmCharcoal)
                    }
                }
                Text("Pre-loved pieces with stories")
                    .font(.bodyMedium)
                    .foregroundColor(.warmCharcoal)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(Color.warmOffWhite)
            .frame(height: headerHeight * (CGFloat(1) - headerCollapseProgress * CGFloat(0.5)))
            .opacity(CGFloat(1) - headerCollapseProgress)
            .clipped()
            
            categorySelector
                .frame(height: categorySelectorHeight * (CGFloat(1) - headerCollapseProgress * CGFloat(0.3)))
                .opacity(CGFloat(1) - headerCollapseProgress * CGFloat(0.5))
        }
        .background(Color.warmOffWhite)
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(DiscoverCategory.allCases) { category in
                    CategoryTab(
                        category: category,
                        isSelected: viewModel.selectedDiscoverCategory == category
                    ) { viewModel.selectDiscoverCategory(category) }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .background(Color.warmOffWhite)
    }
    
    private var contentArea: some View {
        Group {
            switch viewModel.selectedDiscoverCategory {
            case .clothing: clothingContent
            case .events, .workshops, .popUps: eventsContent
            }
        }
    }
    
    private var clothingContent: some View {
        VStack(spacing: 16) {
            searchBar.padding(.horizontal, 20)
            subcategoryStrip
            sortFilterBar.padding(.horizontal, 20)
            
            if viewModel.isLoading && viewModel.items.isEmpty {
                shimmerGrid.padding(.horizontal, 20)
            } else if viewModel.isEmpty {
                emptyStateView.padding(.horizontal, 20)
            } else {
                resultsGrid.padding(.horizontal, 20)
            }
            
            if viewModel.isLoadingMore {
                ProgressView().tint(Color.agedBrass).frame(height: 50)
            }
        }
        .padding(.top, 8)
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.warmCharcoal)
            
            TextField("", text: $viewModel.searchQuery)
                .font(.bodyMedium)
                .foregroundColor(.nearBlack)
                .placeholder(when: viewModel.searchQuery.isEmpty) {
                    Text("Search pieces, brands, styles...")
                        .font(.bodyMedium)
                        .foregroundColor(.mutedGray)
                }
                .submitLabel(.search)
                .onSubmit { viewModel.performSearch() }
            
            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.searchQuery = ""; viewModel.performSearch() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.warmCharcoal)
                }
            }
            
            Button(action: { viewModel.showVisualSearch = true }) {
                Image(systemName: "camera")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.inkPrimary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.canvasSecond)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.hairline, lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }
    
    private var searchSuggestionsOverlay: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.warmCharcoal)
                
                TextField("", text: $viewModel.searchQuery)
                    .font(.bodyMedium)
                    .foregroundColor(.nearBlack)
                    .placeholder(when: viewModel.searchQuery.isEmpty) {
                        Text("Search pieces, brands, styles...")
                            .font(.bodyMedium)
                            .foregroundColor(.mutedGray)
                    }
                    .submitLabel(.search)
                    .onSubmit { viewModel.performSearch() }
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: { viewModel.searchQuery = ""; viewModel.performSearch() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.warmCharcoal)
                    }
                }
                
                Button(action: { viewModel.showVisualSearch = true }) {
                    Image(systemName: "camera")
                        .font(.system(size: 18))
                        .foregroundColor(.warmCharcoal)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.ivory)
            
            Divider().background(Color.warmDivider)
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.searchSuggestions) { suggestion in
                    Button(action: { viewModel.selectSearchSuggestion(suggestion) }) {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(.mutedGray)
                            Text(suggestion.text)
                                .font(.bodyMedium)
                                .foregroundColor(.nearBlack)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    Divider()
                        .background(Color.warmDivider)
                        .padding(.leading, 44)
                }
            }
            .background(Color.warmOffWhite)
        }
        .background(Color.warmOffWhite)
        .padding(.horizontal, 20)
    }
    
    private var subcategoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                SubcategoryTab(
                    title: "All",
                    isSelected: viewModel.selectedSubCategory == nil
                ) {
                    viewModel.selectSubCategory(nil)
                }
                ForEach(Category.allCases) { category in
                    SubcategoryTab(
                        title: category.sentenceCaseName,
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
    
    private var sortFilterBar: some View {
        HStack(spacing: 20) {
            Button(action: { viewModel.showSortOptions = true }) {
                HStack(spacing: 4) {
                    Text("Sort")
                        .font(.bodyMedium)
                        .foregroundColor(.nearBlack)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.warmCharcoal)
                }
            }
            
            Spacer()
            
            filterButton
        }
    }
    
    private var resultsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
            spacing: 24
        ) {
            ForEach(viewModel.items) { item in
                DSItemCard(
                    brand: item.brand,
                    name: item.name,
                    price: item.price.map { Decimal($0) }
                )
                .onTapGesture { /* navigate to detail */ }
            }
        }
    }

    private var shimmerGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
            spacing: 24
        ) {
            ForEach(0..<6, id: \.self) { _ in DSItemCardSkeleton() }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.mutedGray)
            Text(viewModel.emptyStateTitle)
                .font(.bodyText(18, weight: .semibold))
                .foregroundColor(.nearBlack)
                .multilineTextAlignment(.center)
            Text("Try adjusting your search or filters")
                .font(.bodyMedium)
                .foregroundColor(.warmCharcoal)
                .multilineTextAlignment(.center)
            Button(action: { viewModel.resetFilters() }) {
                Text("Clear filters")
                    .font(.bodyMedium)
                    .foregroundColor(.warmOffWhite)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.nearBlack)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
            .padding(.top, 8)
            Spacer()
        }
        .frame(minHeight: 400)
    }
    
    private var eventsContent: some View {
        VStack(spacing: 16) {
            viewModeToggle.padding(.horizontal, 20)
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
    
    private var viewModeToggle: some View {
        HStack(spacing: 24) {
            ForEach([EventViewMode.list, EventViewMode.map], id: \.self) { mode in
                UnderlineFilter(
                    mode == .list ? "List" : "Map",
                    isSelected: viewModel.eventViewMode == mode,
                    useBrass: true
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) { viewModel.eventViewMode = mode }
                }
            }
            Spacer()
        }
    }
    
    private var filterButton: some View {
        Button {
            viewModel.showFilterSheet = true
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.activeFilterCount > 0 ? "Filters (\(viewModel.activeFilterCount))" : "Filters")
                    .font(.bodyMedium)
                    .foregroundColor(.nearBlack)
            }
        }
    }
    
    private var eventsListView: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.filteredEvents) { event in
                DSEventCard(event: event)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .onTapGesture {
                        viewModel.selectedEvent = event
                        viewModel.showEventDetail = true
                    }
            }
            Color.clear.frame(height: 20)
        }
        .padding(.top, 4)
    }
}

// MARK: - Scroll Offset Preference Key
struct DiscoverScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

// MARK: - Category Tab (Underline Filter)
struct CategoryTab: View {
    let category: DiscoverCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        UnderlineFilter(category.rawValue, isSelected: isSelected, useBrass: true, action: action)
    }
}

// MARK: - Subcategory Tab (Underline Filter)
struct SubcategoryTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        UnderlineFilter(title, isSelected: isSelected, useBrass: true, action: action)
    }
}

// MARK: - Preview
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
