import SwiftUI

// MARK: - DiscoveryView
/// Main discovery feed view showing garments in a grid layout
/// with search, new arrivals, and trending sections
public struct DiscoveryView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = DiscoveryViewModel()
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Background
            Color.modaicsWarmSand
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: ModaicsLayout.large) {
                    // Header
                    headerSection
                    
                    // Search Bar
                    searchBar
                        .padding(.horizontal, ModaicsLayout.margin)
                    
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
                .padding(.vertical, ModaicsLayout.medium)
            }
        }
        .task {
            await viewModel.loadGarments()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
                Text("Discover")
                    .font(.modaicsDisplaySmall)
                    .foregroundColor(.modaicsTextPrimary)
                
                Text("Find pre-loved pieces with stories")
                    .font(.modaicsBodyRegular)
                    .foregroundColor(.modaicsTextSecondary)
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
                    .foregroundColor(.modaicsCharcoal)
            }
        }
        .padding(.horizontal, ModaicsLayout.margin)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: ModaicsLayout.small) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(.modaicsStone)
            
            TextField("Search garments, brands, styles...", text: $viewModel.searchQuery)
                .font(.modaicsBodyRegular)
                .foregroundColor(.modaicsTextPrimary)
            
            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.modaicsStone)
                }
            }
        }
        .padding(.horizontal, ModaicsLayout.medium)
        .padding(.vertical, ModaicsLayout.small)
        .background(
            RoundedRectangle(cornerRadius: ModaicsLayout.cornerRadiusButton)
                .fill(Color.modaicsPaper)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ModaicsLayout.cornerRadiusButton)
                .stroke(Color.modaicsCharcoal.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: ModaicsLayout.medium) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Discovering treasures...")
                .font(.modaicsBodyRegular)
                .foregroundColor(.modaicsTextSecondary)
        }
        .padding(.top, ModaicsLayout.xxxlarge)
    }
    
    // MARK: - Error View
    
    private var errorView: some View {
        VStack(spacing: ModaicsLayout.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.modaicsOchre)
            
            Text("Something went wrong")
                .font(.modaicsHeadline3)
                .foregroundColor(.modaicsTextPrimary)
            
            Button("Try Again") {
                Task {
                    await viewModel.loadGarments()
                }
            }
            .font(.modaicsButton)
            .foregroundColor(.modaicsTerracotta)
        }
        .padding(.top, ModaicsLayout.xxxlarge)
    }
    
    // MARK: - New Arrivals Section
    
    private var newArrivalsSection: some View {
        VStack(alignment: .leading, spacing: ModaicsLayout.medium) {
            SectionHeader(title: "New Arrivals", subtitle: "Fresh finds just added")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ModaicsLayout.medium) {
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
                .padding(.horizontal, ModaicsLayout.margin)
            }
        }
    }
    
    // MARK: - Trending Section
    
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: ModaicsLayout.medium) {
            SectionHeader(title: "Trending", subtitle: "Popular right now")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ModaicsLayout.medium) {
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
                .padding(.horizontal, ModaicsLayout.margin)
            }
        }
    }
    
    // MARK: - All Garments Section
    
    private var allGarmentsSection: some View {
        VStack(alignment: .leading, spacing: ModaicsLayout.medium) {
            HStack {
                VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
                    Text(viewModel.searchQuery.isEmpty ? "All Garments" : "Results")
                        .font(.modaicsHeadingSemiBold)
                        .foregroundColor(.modaicsTextPrimary)
                    
                    Text("\(viewModel.filteredGarments.count) items")
                        .font(.modaicsCaption)
                        .foregroundColor(.modaicsTextSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, ModaicsLayout.margin)
            
            if viewModel.filteredGarments.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: ModaicsLayout.medium),
                        GridItem(.flexible(), spacing: ModaicsLayout.medium)
                    ],
                    spacing: ModaicsLayout.medium
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
                .padding(.horizontal, ModaicsLayout.margin)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: ModaicsLayout.medium) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.modaicsStone)
            
            Text("No garments found")
                .font(.modaicsHeadline3)
                .foregroundColor(.modaicsTextPrimary)
            
            Text("Try adjusting your search or filters")
                .font(.modaicsBodyRegular)
                .foregroundColor(.modaicsTextSecondary)
            
            Button("Clear Filters") {
                viewModel.clearFilters()
            }
            .font(.modaicsButton)
            .foregroundColor(.modaicsTerracotta)
            .padding(.top, ModaicsLayout.small)
        }
        .padding(.vertical, ModaicsLayout.xxlarge)
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
            Text(title)
                .font(.modaicsHeadingSemiBold)
                .foregroundColor(.modaicsTextPrimary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.modaicsCaption)
                    .foregroundColor(.modaicsTextSecondary)
            }
        }
        .padding(.horizontal, ModaicsLayout.margin)
    }
}

// MARK: - Preview

#if DEBUG
struct DiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryView()
    }
}
#endif
