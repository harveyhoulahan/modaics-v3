import SwiftUI
import Combine

// MARK: - WardrobeView
/// "My Wardrobe" — the user's personal collection view
/// Displays their garments in a grid with stats and actions
public struct WardrobeView: View {
    @StateObject private var viewModel = WardrobeViewModel()
    @State private var showingAddGarment = false
    @State private var selectedGarment: ModaicsGarment?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Warm sand background
            Color.modaicsWarmSand
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header with title and stats
                    headerSection
                        .padding(.horizontal, ModaicsLayout.large)
                        .padding(.top, ModaicsLayout.medium)
                    
                    // Stats row
                    statsSection
                        .padding(.horizontal, ModaicsLayout.large)
                        .padding(.top, ModaicsLayout.large)
                    
                    // Garments grid
                    garmentsSection
                        .padding(.horizontal, ModaicsLayout.large)
                        .padding(.top, ModaicsLayout.xlarge)
                    
                    Spacer(minLength: ModaicsLayout.xxlarge)
                }
            }
        }
        .sheet(isPresented: $showingAddGarment) {
            AddGarmentPlaceholderView()
        }
        .onAppear {
            viewModel.loadWardrobe()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: ModaicsLayout.tightSpacing) {
                Text("My Wardrobe")
                    .font(.modaicsDisplaySmall)
                    .foregroundColor(.modaicsTextPrimary)
                
                Text("\(viewModel.garmentCount) pieces curated with intention")
                    .font(.modaicsBodyRegular)
                    .foregroundColor(.modaicsTextSecondary)
            }
            
            Spacer()
            
            // Add Garment Button
            Button(action: { showingAddGarment = true }) {
                HStack(spacing: ModaicsLayout.xsmall) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Add")
                        .font(.modaicsButton)
                }
                .foregroundColor(.white)
                .padding(.horizontal, ModaicsLayout.medium)
                .padding(.vertical, ModaicsLayout.small)
                .background(Color.modaicsTerracotta)
                .cornerRadius(ModaicsLayout.cornerRadius)
            }
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: ModaicsLayout.large) {
            StatItem(
                value: "\(viewModel.garmentCount)",
                label: "Garments",
                icon: "hanger"
            )
            
            StatItem(
                value: viewModel.estimatedValue,
                label: "Est. Value",
                icon: "dollarsign.circle"
            )
            
            StatItem(
                value: "\(viewModel.sustainabilityScore)",
                label: "Eco Score",
                icon: "leaf"
            )
            
            StatItem(
                value: "\(viewModel.carbonSavedKg, specifier: "%g")",
                label: "kg CO₂ Saved",
                icon: "arrow.down.circle"
            )
        }
        .padding(ModaicsLayout.medium)
        .background(Color.modaicsPaper)
        .cornerRadius(ModaicsLayout.cornerRadius)
        .modaicsShadowSmall()
    }
    
    // MARK: - Garments Section
    private var garmentsSection: some View {
        VStack(alignment: .leading, spacing: ModaicsLayout.large) {
            HStack {
                Text("Your Collection")
                    .font(.modaicsHeadingSemiBold)
                    .foregroundColor(.modaicsTextPrimary)
                
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
                        Text("Sort")
                            .font(.modaicsCaption)
                    }
                    .foregroundColor(.modaicsTerracotta)
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
                    title: "Your wardrobe is waiting",
                    message: "Start building your collection by adding pieces with stories to tell."
                )
                .frame(maxWidth: .infinity, minHeight: 300)
            } else {
                // Garments grid
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: ModaicsLayout.small)
                    ],
                    spacing: ModaicsLayout.small
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

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: ModaicsLayout.xsmall) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.modaicsTerracotta)
            
            Text(value)
                .font(.modaicsBodySemiBold)
                .foregroundColor(.modaicsTextPrimary)
            
            Text(label)
                .font(.modaicsFinePrint)
                .foregroundColor(.modaicsTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Garment Tile
struct GarmentTile: View {
    let garment: ModaicsGarment
    let onTap: () -> Void
    let onRemove: () -> Void
    @State private var showingRemoveConfirmation = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: ModaicsLayout.cornerRadius)
                    .fill(Color.modaicsCream)
                    .aspectRatio(3/4, contentMode: .fit)
                
                // Placeholder image or icon
                VStack(spacing: ModaicsLayout.small) {
                    Image(systemName: categoryIcon)
                        .font(.system(size: 32))
                        .foregroundColor(.modaicsStone)
                    
                    Text(garment.title)
                        .font(.modaicsCaption)
                        .foregroundColor(.modaicsTextPrimary)
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                }
                
                // Condition badge
                VStack {
                    HStack {
                        Spacer()
                        Text(conditionAbbreviation)
                            .font(.modaicsMicro)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(conditionColor)
                            .cornerRadius(4)
                    }
                    .padding(ModaicsLayout.xsmall)
                    
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
                                .foregroundColor(.modaicsTerracotta)
                                .padding(ModaicsLayout.xsmall)
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: ModaicsLayout.cornerRadius)
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
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
            return .modaicsDeepOlive
        case .good, .fair:
            return .modaicsOchre
        case .vintage:
            return .modaicsTerracotta
        case .needsRepair:
            return .modaicsRust
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
                ModaicsLoadingIndicator()
                    .scaleEffect(1.5)
                Spacer()
            }
            Spacer()
        }
        .background(Color.modaicsPaper.opacity(0.5))
        .cornerRadius(ModaicsLayout.cornerRadius)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: ModaicsLayout.large) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.modaicsStone)
            
            VStack(spacing: ModaicsLayout.small) {
                Text(title)
                    .font(.modaicsHeadingSemiBold)
                    .foregroundColor(.modaicsTextPrimary)
                
                Text(message)
                    .font(.modaicsBodyRegular)
                    .foregroundColor(.modaicsTextSecondary)
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
            VStack(spacing: ModaicsLayout.large) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.modaicsTerracotta)
                
                Text("Add a New Garment")
                    .font(.modaicsHeadingSemiBold)
                    .foregroundColor(.modaicsTextPrimary)
                
                Text("Take photos, tell its story, and add it to your wardrobe.")
                    .font(.modaicsBodyRegular)
                    .foregroundColor(.modaicsTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, ModaicsLayout.xxlarge)
            .navigationTitle("Add Garment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct WardrobeView_Previews: PreviewProvider {
    static var previews: some View {
        WardrobeView()
    }
}
