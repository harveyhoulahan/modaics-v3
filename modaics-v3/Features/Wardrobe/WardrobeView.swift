import SwiftUI
import Combine

// MARK: - WardrobeView (Dark Green Porsche)
/// "My Wardrobe" — the user's personal collection view
/// Displays their garments in a grid with stats and actions
public struct WardrobeView: View {
    @StateObject private var viewModel = WardrobeViewModel()
    @State private var showingAddGarment = false
    @State private var selectedGarment: ModaicsGarment?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Dark green background
            Color.modaicsBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header with title and stats
                    headerSection
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    // Stats row
                    statsSection
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    
                    // Garments grid
                    garmentsSection
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    Spacer(minLength: 48)
                }
            }
        }
        .sheet(isPresented: $showingAddGarment) {
            AddGarmentPlaceholderView()
        }
        .onAppear {
            viewModel.loadWardrobe()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    @State private var showProfile = false
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("MY WARDROBE")
                    .font(.forestDisplaySmall)
                    .foregroundColor(.sageWhite)
                    .tracking(2)
                
                Text("\(viewModel.garmentCount) PIECES CURATED")
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageMuted)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Add Garment Button
                Button(action: { showingAddGarment = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("ADD")
                            .font(.forestCaptionLarge)
                    }
                    .foregroundColor(.modaicsBackground)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.luxeGold)
                    .cornerRadius(8)
                }
                
                // Profile Button
                Button(action: { showProfile = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.modaicsPrimary, .luxeGold.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(Color.luxeGold.opacity(0.5), lineWidth: 1)
                            )
                        
                        Text("H")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.sageWhite)
                    }
                }
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatItem(
                value: "\(viewModel.garmentCount)",
                label: "GARMENTS",
                icon: "hanger",
                color: .luxeGold
            )
            
            StatItem(
                value: viewModel.estimatedValue,
                label: "EST. VALUE",
                icon: "dollarsign.circle",
                color: .emerald
            )
            
            StatItem(
                value: "\(viewModel.sustainabilityScore)",
                label: "ECO SCORE",
                icon: "leaf",
                color: .modaicsFern
            )
            
            StatItem(
                value: String(format: "%.1f", viewModel.carbonSavedKg),
                label: "KG CO₂ SAVED",
                icon: "arrow.down.circle",
                color: .modaicsMoss
            )
        }
        .padding(16)
        .background(Color.modaicsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
        )
    }
    
    // MARK: - Garments Section
    private var garmentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("YOUR COLLECTION")
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageWhite)
                    .tracking(1)
                
                Spacer()
                
                // Sort menu
                Menu {
                    Button("Recently Added") { viewModel.sortBy = .recent }
                    Button("Alphabetical") { viewModel.sortBy = .alphabetical }
                    Button("Brand") { viewModel.sortBy = .brand }
                    Button("Condition") { viewModel.sortBy = .condition }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 14, weight: .medium))
                        Text("SORT")
                            .font(.forestCaptionSmall)
                    }
                    .foregroundColor(.luxeGold)
                }
            }
            
            if viewModel.isLoading {
                // Loading state
                LoadingGridView()
                    .frame(height: 300)
            } else if viewModel.garments.isEmpty {
                // Empty state
                EmptyStateView(
                    icon: "hanger",
                    title: "YOUR WARDROBE IS WAITING",
                    message: "Start building your collection by adding pieces with stories to tell."
                )
                .frame(maxWidth: .infinity, minHeight: 300)
            } else {
                // Garments grid
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(viewModel.garments) { garment in
                        GarmentTile(
                            garment: garment,
                            onTap: { selectedGarment = garment },
                            onRemove: {
                                Task {
                                    await viewModel.removeGarment(garment.id)
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Stat Item (Dark Green Porsche)
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
            
            Text(label)
                .font(.forestCaptionSmall)
                .foregroundColor(.sageMuted)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Garment Tile (Dark Green Porsche)
struct GarmentTile: View {
    let garment: ModaicsGarment
    let onTap: () -> Void
    let onRemove: () -> Void
    @State private var showingRemoveConfirmation = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.modaicsSurface)
                    .aspectRatio(3/4, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
                    )
                
                // Placeholder image or icon
                VStack(spacing: 8) {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 32))
                        .foregroundColor(.sageSubtle)
                    
                    Text(garment.title.uppercased())
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageWhite)
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                }
                
                // Condition badge
                VStack {
                    HStack {
                        Spacer()
                        Text(conditionAbbreviation)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.modaicsBackground)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(conditionColor)
                            .cornerRadius(4)
                    }
                    .padding(6)
                    
                    Spacer()
                }
                
                // Listed indicator
                if garment.isListed {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "tag.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.luxeGold)
                                .padding(6)
                        }
                    }
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive, action: {
                showingRemoveConfirmation = true
            }) {
                Label("Remove", systemImage: "trash")
            }
        }
        .alert("Remove Garment?", isPresented: $showingRemoveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive, action: onRemove)
        } message: {
            Text("This will remove '\(garment.title)' from your wardrobe.")
        }
    }
    
    private var categoryIcon: String {
        switch garment.category {
        case .tops: return "tshirt"
        case .bottoms: return "minus.rectangle"
        case .dresses: return "person"
        case .outerwear: return "jacket"
        case .activewear: return "figure.walk"
        case .loungewear: return "bed.double"
        case .formal: return "person.fill"
        case .accessories: return "eyeglasses"
        case .shoes: return "shoe"
        case .jewelry: return "diamond"
        case .bags: return "handbag"
        case .vintage: return "clock.arrow.circlepath"
        case .other: return "questionmark.square"
        }
    }
    
    private var conditionAbbreviation: String {
        switch garment.condition {
        case .newWithTags: return "NWT"
        case .newWithoutTags: return "NWOT"
        case .excellent: return "EXC"
        case .veryGood: return "VG"
        case .good: return "GD"
        case .fair: return "FAIR"
        case .vintage: return "VINT"
        case .needsRepair: return "REPAIR"
        }
    }
    
    private var conditionColor: Color {
        switch garment.condition {
        case .newWithTags, .newWithoutTags:
            return .modaicsSage
        case .excellent, .veryGood:
            return .modaicsEmerald
        case .good, .fair:
            return .modaicsOlive
        case .vintage:
            return .luxeGold
        case .needsRepair:
            return .modaicsWarning
        }
    }
}

// MARK: - Loading Grid View
struct LoadingGridView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.luxeGold)
                Spacer()
            }
            Spacer()
        }
        .background(Color.modaicsSurface.opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.sageSubtle)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageWhite)
                    .tracking(1)
                
                Text(message)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding()
    }
}

// MARK: - Add Garment Placeholder View
struct AddGarmentPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.luxeGold)
                    
                    Text("ADD A NEW GARMENT")
                        .font(.forestHeadlineMedium)
                        .foregroundColor(.sageWhite)
                        .tracking(2)
                    
                    Text("Take photos, tell its story, and add it to your wardrobe.")
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 64)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("DONE") {
                        dismiss()
                    }
                    .font(.forestCaptionLarge)
                    .foregroundColor(.luxeGold)
                }
            }
        }
    }
}

// MARK: - Preview
struct WardrobeView_Previews: PreviewProvider {
    static var previews: some View {
        WardrobeView()
            .preferredColorScheme(.dark)
    }
}