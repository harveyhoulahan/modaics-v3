import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.modaicsWarmSand.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        headerSection
                        
                        // Picked for You
                        pickedForYouSection
                        
                        // Happening Near You
                        eventsSection
                        
                        // Quick Wardrobe Access
                        wardrobeSummarySection
                        
                        // Trending Now
                        trendingSection
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Modaics")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.loadHomeData()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.greeting)
                .font(.modaicsCaption)
                .foregroundColor(.modaicsStone)
            
            Text("Discover pieces with stories")
                .font(.modaicsDisplaySmall)
                .foregroundColor(.modaicsCharcoal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
    
    // MARK: - Picked for You Section
    private var pickedForYouSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Picked for You")
                        .font(.modaicsHeadingSemiBold)
                        .foregroundColor(.modaicsCharcoal)
                    
                    Text("Based on your style and interests")
                        .font(.modaicsCaptionRegular)
                        .foregroundColor(.modaicsStone)
                }
                
                Spacer()
                
                Button("See All") {
                    appState.selectedTab = .discover
                }
                .font(.modaicsCaption)
                .foregroundColor(.modaicsTerracotta)
            }
            .padding(.horizontal, 20)
            
            // Horizontal scroll of recommendations
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.pickedForYou) { item in
                        PickedForYouCard(item: item)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Events Section
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Happening Near You")
                        .font(.modaicsHeadingSemiBold)
                        .foregroundColor(.modaicsCharcoal)
                    
                    Text("Markets, pop-ups, and meetups")
                        .font(.modaicsCaptionRegular)
                        .foregroundColor(.modaicsStone)
                }
                
                Spacer()
                
                Button("See All") {
                    // Navigate to events
                }
                .font(.modaicsCaption)
                .foregroundColor(.modaicsTerracotta)
            }
            .padding(.horizontal, 20)
            
            // Events list
            VStack(spacing: 12) {
                ForEach(viewModel.nearbyEvents.prefix(3)) { event in
                    EventRow(event: event)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Wardrobe Summary Section
    private var wardrobeSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Wardrobe")
                        .font(.modaicsHeadingSemiBold)
                        .foregroundColor(.modaicsCharcoal)
                    
                    Text("Eco Score: \(viewModel.ecoScore) points")
                        .font(.modaicsCaptionRegular)
                        .foregroundColor(.modaicsDeepOlive)
                }
                
                Spacer()
                
                Button("Open") {
                    appState.selectedTab = .profile
                }
                .font(.modaicsCaption)
                .foregroundColor(.modaicsTerracotta)
            }
            .padding(.horizontal, 20)
            
            // Wardrobe preview
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.wardrobePreview) { garment in
                        WardrobePreviewCard(garment: garment)
                    }
                    
                    // Add more button
                    Button {
                        appState.selectedTab = .create
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                            Text("Add Piece")
                                .font(.modaicsFinePrint)
                        }
                        .foregroundColor(.modaicsTerracotta)
                        .frame(width: 100, height: 120)
                        .background(Color.modaicsPaper)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Trending Section
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trending Now")
                        .font(.modaicsHeadingSemiBold)
                        .foregroundColor(.modaicsCharcoal)
                    
                    Text("What's popular in the community")
                        .font(.modaicsCaptionRegular)
                        .foregroundColor(.modaicsStone)
                }
                
                Spacer()
                
                Button("See All") {
                    appState.selectedTab = .discover
                }
                .font(.modaicsCaption)
                .foregroundColor(.modaicsTerracotta)
            }
            .padding(.horizontal, 20)
            
            // Trending grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.trendingPieces.prefix(4)) { garment in
                    TrendingCard(garment: garment)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Picked For You Card
struct PickedForYouCard: View {
    let item: PickedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsOatmeal)
                .frame(width: 160, height: 200)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.modaicsStone.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.garment.brand.displayName)
                    .font(.modaicsCaption)
                    .foregroundColor(.modaicsStone)
                
                Text(item.garment.category.displayName)
                    .font(.modaicsBodyEmphasis)
                    .foregroundColor(.modaicsCharcoal)
                    .lineLimit(1)
                
                Text(item.reason)
                    .font(.modaicsFinePrint)
                    .foregroundColor(.modaicsDeepOlive)
                    .lineLimit(2)
            }
        }
        .frame(width: 160)
    }
}

// MARK: - Event Row
struct EventRow: View {
    let event: ModaicsEvent
    
    var body: some View {
        HStack(spacing: 16) {
            // Date block
            VStack(spacing: 4) {
                Text(event.day)
                    .font(.modaicsHeadingSemiBold)
                    .foregroundColor(.modaicsTerracotta)
                Text(event.month)
                    .font(.modaicsFinePrint)
                    .foregroundColor(.modaicsStone)
            }
            .frame(width: 60, height: 60)
            .background(Color.modaicsPaper)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.modaicsBodyEmphasis)
                    .foregroundColor(.modaicsCharcoal)
                
                Text(event.location)
                    .font(.modaicsCaptionRegular)
                    .foregroundColor(.modaicsStone)
                
                Text("\(event.attendees) attending")
                    .font(.modaicsFinePrint)
                    .foregroundColor(.modaicsDeepOlive)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.modaicsStone)
        }
        .padding(16)
        .background(Color.modaicsPaper)
        .cornerRadius(16)
    }
}

// MARK: - Wardrobe Preview Card
struct WardrobePreviewCard: View {
    let garment: ModaicsGarment
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.modaicsOatmeal)
            .frame(width: 100, height: 120)
            .overlay(
                Image(systemName: "tshirt")
                    .font(.system(size: 32))
                    .foregroundColor(.modaicsStone.opacity(0.5))
            )
    }
}

// MARK: - Trending Card
struct TrendingCard: View {
    let garment: ModaicsGarment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsOatmeal)
                .frame(height: 140)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundColor(.modaicsStone.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(garment.brand.displayName)
                    .font(.modaicsFinePrint)
                    .foregroundColor(.modaicsStone)
                
                Text(garment.category.displayName)
                    .font(.modaicsBodyEmphasis)
                    .foregroundColor(.modaicsCharcoal)
                    .lineLimit(1)
            }
        }
    }
}