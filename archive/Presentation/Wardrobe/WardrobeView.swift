import SwiftUI
import Combine

// MARK: - Wardrobe View
/// "The Mosaic" — the user's personal collection
/// A visual tapestry of their sustainable fashion journey
struct WardrobeView: View {
    @StateObject private var viewModel = WardrobeViewModel()
    @State private var selectedCollection: GarmentCollection?
    @State private var showSustainabilityScore = false
    @State private var selectedGarment: Garment?
    
    var body: some View {
        ZStack {
            // Warm sand background
            Color.modaicsWarmSand
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header with sustainability score
                    headerSection
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // The Mosaic — garment grid
                    mosaicSection
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    // Collections
                    if !viewModel.collections.isEmpty {
                        collectionsSection
                            .padding(.top, 40)
                    }
                    
                    // Community connections
                    if !viewModel.communityConnections.isEmpty {
                        communitySection
                            .padding(.horizontal, 24)
                            .padding(.top, 40)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .sheet(isPresented: $showSustainabilityScore) {
            SustainabilityScoreView(score: viewModel.sustainabilityScore)
        }
        .onAppear {
            viewModel.loadWardrobe()
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("The Mosaic")
                        .font(.modaicsDisplayMedium(size: 32))
                        .foregroundColor(.modaicsCharcoalClay)
                    
                    Text("\(viewModel.totalGarments) pieces, \(viewModel.uniqueBrands) brands, endless stories")
                        .font(.modaicsBodyRegular(size: 15))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.7))
                }
                
                Spacer()
                
                // Sustainability badge
                Button(action: { showSustainabilityScore = true }) {
                    SustainabilityBadge(score: viewModel.sustainabilityScore)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Impact stats
            HStack(spacing: 24) {
                ImpactStat(value: "\(viewModel.waterSaved)L", label: "Water saved")
                ImpactStat(value: "\(viewModel.co2Prevented)kg", label: "CO₂ prevented")
                ImpactStat(value: "\(viewModel.garmentsRecirculated)", label: "Pieces recirculated")
            }
            .padding(.top, 16)
        }
    }
    
    // MARK: - Mosaic Grid
    private var mosaicSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Collection")
                    .font(.modaicsHeadingSemiBold(size: 20))
                    .foregroundColor(.modaicsCharcoalClay)
                
                Spacer()
                
                Menu {
                    Button("Recently Added") { viewModel.sortBy = .recent }
                    Button("Alphabetical") { viewModel.sortBy = .alphabetical }
                    Button("Brand") { viewModel.sortBy = .brand }
                    Button("Most Worn") { viewModel.sortBy = .mostWorn }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.modaicsDeepOlive)
                }
            }
            
            if viewModel.isLoading {
                MosaicShimmerView()
                    .frame(height: 400)
            } else if viewModel.garments.isEmpty {
                EmptyStateView(
                    icon: "hanger",
                    title: "Your wardrobe is waiting",
                    message: "Start building your mosaic by adding pieces from the exchange or your existing collection."
                )
                .frame(height: 300)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 12)], spacing: 12) {
                    ForEach(viewModel.garments) { garment in
                        MosaicTile(garment: garment) {
                            selectedGarment = garment
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Collections Section
    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Curated Sets")
                .font(.modaicsHeadingSemiBold(size: 20))
                .foregroundColor(.modaicsCharcoalClay)
                .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.collections) { collection in
                        CollectionPreviewCard(collection: collection) {
                            selectedCollection = collection
                        }
                    }
                    
                    // Add new collection button
                    Button(action: { viewModel.createNewCollection() }) {
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color.modaicsTerracotta.opacity(0.1))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.modaicsTerracotta)
                                )
                            
                            Text("New Set")
                                .font(.modaicsBodyMedium(size: 14))
                                .foregroundColor(.modaicsCharcoalClay)
                        }
                        .frame(width: 140, height: 180)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: - Community Section
    private var communitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Community Connections")
                .font(.modaicsHeadingSemiBold(size: 20))
                .foregroundColor(.modaicsCharcoalClay)
            
            VStack(spacing: 12) {
                ForEach(viewModel.communityConnections.prefix(3)) { connection in
                    CommunityConnectionRow(connection: connection)
                }
            }
            
            if viewModel.communityConnections.count > 3 {
                Button(action: { viewModel.showAllConnections() }) {
                    Text("See all \(viewModel.communityConnections.count) connections")
                        .font(.modaicsBodyMedium(size: 15))
                        .foregroundColor(.modaicsTerracotta)
                }
                .padding(.top, 8)
            }
        }
    }
}

// MARK: - Sustainability Badge
struct SustainabilityBadge: View {
    let score: SustainabilityScore
    
    var body: some View {
        ZStack {
            Circle()
                .fill(score.backgroundColor)
                .frame(width: 64, height: 64)
            
            Circle()
                .stroke(score.accentColor, lineWidth: 3)
                .frame(width: 56, height: 56)
            
            VStack(spacing: 0) {
                Text("\(score.rating)")
                    .font(.modaicsDisplayMedium(size: 24))
                    .foregroundColor(score.accentColor)
                
                Text("/100")
                    .font(.modaicsCaptionRegular(size: 10))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
            }
        }
    }
}

// MARK: - Impact Stat
struct ImpactStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.modaicsHeadingSemiBold(size: 18))
                .foregroundColor(.modaicsDeepOlive)
            
            Text(label)
                .font(.modaicsCaptionRegular(size: 12))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
        }
    }
}

// MARK: - Mosaic Tile
struct MosaicTile: View {
    let garment: Garment
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.modaicsWarmSand)
                    .aspectRatio(3/4, contentMode: .fit)
                
                Image(systemName: "tshirt")
                    .font(.system(size: 28))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.2))
                
                // Mosaic accent pattern
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        MosaicAccentPattern()
                            .frame(width: 30, height: 30)
                            .opacity(0.3)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Mosaic Accent Pattern
struct MosaicAccentPattern: View {
    var body: some View {
        Canvas { context, size in
            let tileSize = size.width / 3
            
            for row in 0..<3 {
                for col in 0..<3 {
                    let rect = CGRect(
                        x: CGFloat(col) * tileSize,
                        y: CGFloat(row) * tileSize,
                        width: tileSize,
                        height: tileSize
                    )
                    
                    if (row + col) % 2 == 0 {
                        let path = Path(rect.insetBy(dx: 1, dy: 1))
                        context.fill(path, with: .color(.modaicsTerracotta.opacity(0.4)))
                    }
                }
            }
        }
    }
}

// MARK: - Collection Preview Card
struct CollectionPreviewCard: View {
    let collection: GarmentCollection
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Preview grid
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.modaicsWarmSand)
                    
                    // Mini mosaic preview
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                        ForEach(collection.previewGarments.prefix(4)) { _ in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.modaicsDeepOlive.opacity(0.2))
                        }
                    }
                    .padding(8)
                }
                .frame(height: 100)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.name)
                        .font(.modaicsBodyMedium(size: 15))
                        .foregroundColor(.modaicsCharcoalClay)
                        .lineLimit(1)
                    
                    Text("\(collection.garmentCount) pieces")
                        .font(.modaicsCaptionRegular(size: 13))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                }
            }
            .padding(12)
            .frame(width: 140, height: 180)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Community Connection Row
struct CommunityConnectionRow: View {
    let connection: CommunityConnection
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(connection.avatarColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Text(connection.initials)
                    .font(.modaicsBodySemiBold(size: 16))
                    .foregroundColor(connection.avatarColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(connection.description)
                    .font(.modaicsBodyRegular(size: 15))
                    .foregroundColor(.modaicsCharcoalClay)
                    .lineSpacing(2)
                
                Text(connection.date, style: .relative)
                    .font(.modaicsCaptionRegular(size: 12))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.5))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - Supporting Models
struct GarmentCollection: Identifiable {
    let id = UUID()
    let name: String
    let garmentCount: Int
    let previewGarments: [Garment]
    let createdAt: Date
}

struct CommunityConnection: Identifiable {
    let id = UUID()
    let userName: String
    let initials: String
    let avatarColor: Color
    let description: String
    let date: Date
}

struct SustainabilityScore {
    let rating: Int
    let level: SustainabilityLevel
    
    var backgroundColor: Color {
        switch level {
        case .seedling: return .green.opacity(0.1)
        case .growing: return .blue.opacity(0.1)
        case .blooming: return .modaicsTerracotta.opacity(0.1)
        case .flourishing: return .purple.opacity(0.1)
        }
    }
    
    var accentColor: Color {
        switch level {
        case .seedling: return .green
        case .growing: return .blue
        case .blooming: return .modaicsTerracotta
        case .flourishing: return .purple
        }
    }
}

enum SustainabilityLevel {
    case seedling    // 0-25
    case growing     // 26-50
    case blooming    // 51-75
    case flourishing // 76-100
}

enum SortOption {
    case recent, alphabetical, brand, mostWorn
}

// MARK: - Preview
struct WardrobeView_Previews: PreviewProvider {
    static var previews: some View {
        WardrobeView()
    }
}