import SwiftUI

// MARK: - DiscoveryView (Dark Green Porsche)
/// Main discovery feed view showing garments in a grid layout
/// with search, new arrivals, and trending sections
public struct DiscoveryView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = DiscoveryViewModel()
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Background
            Color.modaicsBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Search Bar
                    searchBar
                        .padding(.horizontal, 20)
                    
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.hasError {
                        errorView
                    } else {
                        // New Arrivals Section
                        if !viewModel.newArrivals.isEmpty {
                            newArrivalsSection
                        }
                        
                        // Trending Section
                        if !viewModel.trendingGarments.isEmpty {
                            trendingSection
                        }
                        
                        // All Garments Grid
                        allGarmentsSection
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .task {
            await viewModel.loadGarments()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("DISCOVER")
                    .font(.forestDisplaySmall)
                    .foregroundColor(.sageWhite)
                    .tracking(2)
                
                Text("Find pre-loved pieces with stories")
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageMuted)
            }
            
            Spacer()
            
            // Filter Button
            Menu {
                Button("All Categories") {
                    viewModel.filterByCategory(nil)
                }
                
                Divider()
                
                ForEach(ModaicsCategory.allCases, id: \.self) { category in
                    Button(category.displayName) {
                        viewModel.filterByCategory(category)
                    }
                }
                
                Divider()
                
                Button("Clear Filters") {
                    viewModel.clearFilters()
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.sageWhite)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(.sageSubtle)
            
            TextField("Search garments, brands, styles...", text: $viewModel.searchQuery)
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
            
            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.sageSubtle)
                }
            }
            
            // Camera button for visual search
            Button(action: {}) {
                Image(systemName: "camera")
                    .font(.system(size: 20))
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
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
        )
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.luxeGold)
            
            Text("Discovering treasures...")
                .font(.forestBodyMedium)
                .foregroundColor(.sageMuted)
        }
        .padding(.top, 80)
    }
    
    // MARK: - Error View
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.modaicsWarning)
            
            Text("Something went wrong")
                .font(.forestHeadlineMedium)
                .foregroundColor(.sageWhite)
            
            Button("Try Again") {
                Task {
                    await viewModel.loadGarments()
                }
            }
            .font(.forestBodyMedium)
            .foregroundColor(.luxeGold)
        }
        .padding(.top, 80)
    }
    
    // MARK: - New Arrivals Section
    
    private var newArrivalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            DiscoverySectionHeader(title: "NEW ARRIVALS", subtitle: "Fresh finds just added")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.newArrivals) { garment in
                        GarmentCard(
                            garment: garment,
                            isFavorite: viewModel.isFavorite(garment.id),
                            onFavoriteToggle: {
                                viewModel.toggleFavorite(for: garment.id)
                            },
                            onTap: {
                                // Handle navigation
                            }
                        )
                        .frame(width: 180)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Trending Section
    
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            DiscoverySectionHeader(title: "TRENDING", subtitle: "Popular right now")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.trendingGarments) { garment in
                        GarmentCard(
                            garment: garment,
                            isFavorite: viewModel.isFavorite(garment.id),
                            onFavoriteToggle: {
                                viewModel.toggleFavorite(for: garment.id)
                            },
                            onTap: {
                                // Handle navigation
                            }
                        )
                        .frame(width: 180)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - All Garments Section
    
    private var allGarmentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.searchQuery.isEmpty ? "ALL GARMENTS" : "RESULTS")
                        .font(.forestHeadlineMedium)
                        .foregroundColor(.sageWhite)
                        .tracking(1)
                    
                    Text("\(viewModel.filteredGarments.count) PIECES")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                        .tracking(1)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            if viewModel.filteredGarments.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(viewModel.filteredGarments) { garment in
                        GarmentCard(
                            garment: garment,
                            isFavorite: viewModel.isFavorite(garment.id),
                            onFavoriteToggle: {
                                viewModel.toggleFavorite(for: garment.id)
                            },
                            onTap: {
                                // Handle navigation
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.sageSubtle)
            
            Text("No pieces found")
                .font(.forestHeadlineMedium)
                .foregroundColor(.sageWhite)
            
            Text("Try adjusting your search or filters")
                .font(.forestBodyMedium)
                .foregroundColor(.sageMuted)
            
            Button("Clear Filters") {
                viewModel.clearFilters()
            }
            .font(.forestBodyMedium)
            .foregroundColor(.luxeGold)
            .padding(.top, 8)
        }
        .padding(.vertical, 60)
    }
}

// MARK: - Discovery Section Header

private struct DiscoverySectionHeader: View {
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.forestHeadlineMedium)
                .foregroundColor(.sageWhite)
                .tracking(1)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#if DEBUG
struct DiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryView()
            .preferredColorScheme(.dark)
    }
}
#endif