import SwiftUI

// MARK: - Home View (Editorial Style)
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appState: AppState
    @State private var showHeader = true
    @State private var headerOffset: CGFloat = 0
    
    // Detail sheet states
    @State private var selectedItem: ModaicsGarment?
    @State private var selectedEvent: ModaicsEvent?
    @State private var showItemDetail = false
    @State private var showEventDetail = false
    @State private var showModaAssistant = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background - Light editorial
            Color.warmOffWhite.ignoresSafeArea()
            
            // Main Scroll Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Small spacer for initial header
                    Spacer().frame(height: showHeader ? 60 : 16)
                    
                    // Header Content
                    headerContent
                    
                    // Horizontal scroll: Trending
                    trendingSection
                    
                    // Full-width editorial card
                    editorialCard
                    
                    // 2-column grid: Picked for you
                    pickedForYouSection
                    
                    // Events section
                    eventsSection
                    
                    // Full-width sustainability feature
                    sustainabilityCard
                    
                    // New in grid
                    newInSection
                    
                    Spacer(minLength: 100)
                }
                .background(
                    GeometryReader { proxy -> Color in
                        let offset = proxy.frame(in: .global).minY
                        DispatchQueue.main.async {
                            let shouldShow = offset > -30
                            if showHeader != shouldShow {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showHeader = shouldShow
                                    headerOffset = shouldShow ? 0 : -100
                                }
                            }
                        }
                        return Color.clear
                    }
                )
            }
            
            // Collapsing Header
            collapsingHeader
                .offset(y: headerOffset)
                .opacity(showHeader ? 1 : 0)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showItemDetail) {
            if let item = selectedItem {
                ItemDetailSheet(item: item)
            }
        }
        .sheet(isPresented: $showEventDetail) {
            if let event = selectedEvent {
                LegacyEventDetailSheet(event: event)
            }
        }
        .sheet(isPresented: $showModaAssistant) {
            ModaAssistantView()
        }
        .onAppear {
            viewModel.loadHomeData()
        }
    }
    
    // MARK: - Collapsing Header (Editorial)
    private var collapsingHeader: some View {
        VStack(spacing: 0) {
            HStack {
                // lowercase modaics - editorial voice
                Text("modaics")
                    .font(.editorialDisplayMedium(24))
                    .foregroundColor(.nearBlack)
                
                Spacer()
                
                // Moda AI, Notification buttons
                HStack(spacing: 16) {
                    Button(action: { showModaAssistant = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .light))
                            Text("Moda")
                                .font(.caption)
                        }
                        .foregroundColor(.agedBrass)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(.nearBlack)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 16)
            .background(Color.warmOffWhite.opacity(0.95))
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Header Content (Editorial)
    private var headerContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.greeting) // "Good morning, Harvey" - sentence case
                .font(.caption)
                .foregroundColor(.warmCharcoal)
            
            Text("Pieces with stories")
                .font(.editorialLarge)
                .foregroundColor(.nearBlack)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 48)
    }
    
    // MARK: - Trending Section (Horizontal scroll)
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trending now")
                .font(.editorialSmall)
                .foregroundColor(.nearBlack)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.trendingPieces.prefix(6)) { garment in
                        EditorialItemCard(garment: garment)
                            .onTapGesture {
                                selectedItem = garment
                                showItemDetail = true
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 48)
    }
    
    // MARK: - Full-width Editorial Card
    private var editorialCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Rectangle()
                .fill(Color.ivory)
                .aspectRatio(16/9, contentMode: .fit)
                .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Moda's Edit")
                    .font(.editorialSmall)
                    .foregroundColor(.nearBlack)
                
                Text("This week's curated selection")
                    .font(.bodySmall)
                    .foregroundColor(.warmCharcoal)
                
                Button("Read") {}
                    .font(.uiLabelSmall)
                    .foregroundColor(.nearBlack)
                    .underline()
            }
            .padding(20)
        }
        .background(Color.ivory)
        .padding(.horizontal, 20)
        .padding(.bottom, 48)
    }
    
    // MARK: - Picked For You (2-column grid)
    private var pickedForYouSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Picked for you")
                    .font(.editorialSmall)
                    .foregroundColor(.nearBlack)
                
                Text("Based on your style")
                    .font(.caption)
                    .foregroundColor(.warmCharcoal)
            }
            .padding(.horizontal, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.pickedForYou.prefix(4)) { item in
                    EditorialItemCard(garment: item.garment)
                        .onTapGesture {
                            selectedItem = item.garment
                            showItemDetail = true
                        }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 48)
    }
    
    // MARK: - Events Section
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Happening near you")
                        .font(.editorialSmall)
                        .foregroundColor(.nearBlack)
                    
                    Text("Events worth checking out")
                        .font(.caption)
                        .foregroundColor(.warmCharcoal)
                }
                
                Spacer()
                
                Button("See all") {}
                    .font(.bodySmall)
                    .foregroundColor(.nearBlack)
                    .underline()
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.nearbyEvents) { event in
                        EditorialEventCard(event: event)
                            .onTapGesture {
                                selectedEvent = event
                                showEventDetail = true
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 48)
    }
    
    // MARK: - Sustainability Feature Card
    private var sustainabilityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Rectangle()
                .fill(Color.forestDeep)
                .aspectRatio(16/9, contentMode: .fit)
                .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Your impact")
                    .font(.editorialSmall)
                    .foregroundColor(.nearBlack)
                
                HStack(spacing: 24) {
                    ImpactMetric(value: "\(viewModel.wardrobeCount)", label: "Pieces")
                    ImpactMetric(value: "\(viewModel.savedCount)", label: "Saved")
                    ImpactMetric(value: "\(viewModel.ecoScore)%", label: "Eco")
                }
            }
            .padding(20)
        }
        .background(Color.ivory)
        .padding(.horizontal, 20)
        .padding(.bottom, 48)
    }
    
    // MARK: - New In Section
    private var newInSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New in")
                .font(.editorialSmall)
                .foregroundColor(.nearBlack)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.trendingPieces.suffix(4)) { garment in
                    EditorialItemCard(garment: garment)
                        .onTapGesture {
                            selectedItem = garment
                            showItemDetail = true
                        }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Editorial Item Card (Minimal)
struct EditorialItemCard: View {
    let garment: ModaicsGarment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Image - full bleed, no corners
            Rectangle()
                .fill(Color.ivory)
                .aspectRatio(3/4, contentMode: .fit)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundColor(.mutedGray)
                )
                .clipped()
            
            // Brand name - ALL CAPS, tracked
            if let brand = garment.brand?.name, !brand.isEmpty {
                Text(brand)
                    .brandNameStyle()
                    .foregroundColor(.warmCharcoal)
            }
            
            // Product name - sentence case
            Text(garment.category.rawValue.capitalized)
                .font(.bodySmall)
                .foregroundColor(.nearBlack)
                .lineLimit(1)
            
            // Price
            if let price = garment.listingPrice {
                Text("$\(Int(price))")
                    .font(.price)
                    .foregroundColor(.nearBlack)
            }
        }
    }
}

// MARK: - Editorial Event Card (Minimal)
struct EditorialEventCard: View {
    let event: ModaicsEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color.ivory)
                .aspectRatio(4/3, contentMode: .fit)
                .clipped()
            
            // Date - quiet text
            Text("\(event.day) \(event.month)")
                .font(.uiLabelSmall)
                .foregroundColor(.warmCharcoal)
            
            // Title
            Text(event.title)
                .font(.bodyText(15, weight: .medium))
                .foregroundColor(.nearBlack)
                .lineLimit(2)
            
            // Attendance
            Text("\(event.attendees) going")
                .font(.captionSmall)
                .foregroundColor(.mutedGray)
        }
        .frame(width: 240)
    }
}

// MARK: - Impact Metric (Minimal)
struct ImpactMetric: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.bodyText(18, weight: .medium))
                .foregroundColor(.nearBlack)
            Text(label)
                .font(.captionSmall)
                .foregroundColor(.warmCharcoal)
        }
    }
}

// MARK: - Legacy Views (bridged)
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        ImpactMetric(value: value, label: label)
    }
}

struct EventCard: View {
    let event: ModaicsEvent
    var body: some View { EditorialEventCard(event: event) }
}

struct PickedItemCard: View {
    let item: PickedItem
    var body: some View { EditorialItemCard(garment: item.garment) }
}

struct TrendingItemCard: View {
    let garment: ModaicsGarment
    var body: some View { EditorialItemCard(garment: garment) }
}
