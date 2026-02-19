import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appState: AppState
    @State private var scrollOffset: CGFloat = 0
    @State private var showNavTitle = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color.modaicsBackground.ignoresSafeArea()
            
            // Main Scroll Content
            ScrollView(showsIndicators: false) {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
                }
                .frame(height: 0)
                
                VStack(spacing: 32) {
                    // Spacer for header
                    Spacer().frame(height: 140)
                    
                    // Header Content (greeting + title)
                    headerContent
                    
                    // Stats Row
                    statsSection
                    
                    // Happening Near You
                    eventsSection
                    
                    // Picked for You
                    pickedForYouSection
                    
                    // Trending Now
                    trendingSection
                    
                    Spacer(minLength: 100)
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
                showNavTitle = value < -80
            }
            
            // Fixed Collapsing Header
            collapsingHeader
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.loadHomeData()
        }
    }
    
    // MARK: - Collapsing Header (Fixed at top)
    private var collapsingHeader: some View {
        VStack(spacing: 0) {
            HStack {
                // Logo/Title that changes on scroll
                if showNavTitle {
                    Text("MODAICS")
                        .font(.forestHeadlineMedium)
                        .foregroundColor(.sageWhite)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    // Hidden but takes up space to prevent jump
                    Text("MODAICS")
                        .font(.forestHeadlineMedium)
                        .foregroundColor(.clear)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.sageWhite)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.sageWhite)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 16)
            
            // Chrome divider line (only shows when collapsed)
            Rectangle()
                .fill(Color.modaicsChrome.opacity(0.3))
                .frame(height: 0.5)
                .opacity(showNavTitle ? 1 : 0)
        }
        .background(
            showNavTitle ? 
                Color.modaicsBackground.opacity(0.98) :
                Color.clear
        )
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Header Content (scrolls away)
    private var headerContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.greeting.uppercased())
                .font(.forestCaptionLarge)
                .foregroundColor(.sageMuted)
                .tracking(2)
            
            Text("Discover pieces\nwith stories")
                .font(.forestDisplayMedium)
                .foregroundColor(.sageWhite)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .opacity(showNavTitle ? 0 : 1)
        .offset(y: showNavTitle ? -20 : 0)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "square.grid.3x3.fill",
                value: "\(viewModel.wardrobeCount)",
                label: "ITEMS",
                color: .luxeGold
            )
            
            StatCard(
                icon: "heart.fill",
                value: "\(viewModel.savedCount)",
                label: "SAVED",
                color: .modaicsEco
            )
            
            StatCard(
                icon: "leaf.fill",
                value: "\(viewModel.ecoScore)",
                label: "ECO",
                color: .modaicsFern
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Events Section
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("HAPPENING NEAR YOU")
                        .font(.forestTabLabel)
                        .foregroundColor(.sageWhite)
                        .tracking(2)
                    
                    Text("Events worth checking out")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                }
                
                Spacer()
                
                Button("SEE ALL") {
                    appState.selectedTab = .community
                }
                .font(.forestCaptionLarge)
                .foregroundColor(.luxeGold)
                .tracking(1)
            }
            .padding(.horizontal, 20)
            
            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.nearbyEvents) { event in
                        EventCard(event: event)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Picked For You Section
    private var pickedForYouSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header with AI badge
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(.luxeGold)
                    
                    Text("PICKED FOR YOU")
                        .font(.forestTabLabel)
                        .foregroundColor(.sageWhite)
                        .tracking(2)
                    
                    Text("AI-POWERED")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.modaicsBackground)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.luxeGold))
                }
                
                Spacer()
                
                Button("SEE ALL") {
                    appState.selectedTab = .discover
                }
                .font(.forestCaptionLarge)
                .foregroundColor(.luxeGold)
                .tracking(1)
            }
            .padding(.horizontal, 20)
            
            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.pickedForYou) { item in
                        PickedItemCard(item: item)
                            .onTapGesture {
                                // Show item detail
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Trending Section
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("TRENDING NOW")
                    .font(.forestTabLabel)
                    .foregroundColor(.sageWhite)
                    .tracking(2)
                
                Spacer()
                
                Button("SEE ALL") {
                    appState.selectedTab = .discover
                }
                .font(.forestCaptionLarge)
                .foregroundColor(.luxeGold)
                .tracking(1)
            }
            .padding(.horizontal, 20)
            
            // Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.trendingPieces.prefix(4)) { garment in
                    TrendingItemCard(garment: garment)
                        .onTapGesture {
                            // Show item detail
                        }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.forestHeadlineMedium)
                .foregroundColor(.sageWhite)
            
            Text(label)
                .font(.forestCaptionSmall)
                .foregroundColor(.sageMuted)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
        )
    }
}

// MARK: - Event Card
struct EventCard: View {
    let event: ModaicsEvent
    
    var body: some View {
        HStack(spacing: 16) {
            // Date block
            VStack(spacing: 2) {
                Text(event.day)
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.luxeGold)
                Text(event.month)
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
            }
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.modaicsSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
                    )
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageWhite)
                    .lineLimit(1)
                
                Text(event.location)
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .lineLimit(1)
                
                Text("\(event.attendees) attending")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.modaicsFern)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.sageMuted)
        }
        .padding(16)
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.modaicsSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
        )
    }
}

// MARK: - Picked Item Card
struct PickedItemCard: View {
    let item: PickedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsSurface)
                .frame(width: 160, height: 200)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.sageSubtle)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text((item.garment.brand?.name ?? "Unknown").uppercased())
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
                
                Text(item.garment.category.rawValue.capitalized)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageWhite)
                    .lineLimit(1)
                
                Text(item.reason)
                    .font(.forestCaptionSmall)
                    .foregroundColor(.modaicsFern)
                    .lineLimit(2)
            }
        }
        .frame(width: 160)
    }
}

// MARK: - Trending Item Card
struct TrendingItemCard: View {
    let garment: ModaicsGarment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsSurface)
                .frame(height: 140)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundColor(.sageSubtle)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text((garment.brand?.name ?? "Unknown").uppercased())
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
                
                Text(garment.category.rawValue.capitalized)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageWhite)
                    .lineLimit(1)
            }
        }
    }
}