import SwiftUI

// MARK: - DiscoveryView
// Editorial layout for garment discovery - Kinfolk magazine aesthetic
// Warm sand background, asymmetric layouts, generous margins
// NOT a grid - flowing editorial feel

public struct DiscoveryView: View {
    @StateObject private var viewModel: DiscoveryViewModel
    
    public init(viewModel: DiscoveryViewModel = DiscoveryViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: MosaicLayout.sectionSpacing) {
                // Header
                headerView
                    .padding(.top, MosaicLayout.marginGenerous)
                
                // Discovery Type Selector
                discoveryTypeSelector
                
                // Content
                switch viewModel.state {
                case .loading:
                    loadingView
                case .empty:
                    emptyView
                case .error(let message):
                    errorView(message: message)
                case .loaded(let garments):
                    editorialContent(garments: garments)
                }
            }
        }
        .background(MosaicColors.backgroundPrimary)
        .ignoresSafeArea(edges: .bottom)
        .task {
            await viewModel.loadGarments()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: MosaicLayout.tightSpacing) {
            Text("Discover")
                .font(MosaicTypography.display)
                .foregroundColor(MosaicColors.textPrimary)
            
            Text("Curated garments with stories worth telling")
                .font(MosaicTypography.bodyLarge)
                .foregroundColor(MosaicColors.textSecondary)
                .lineSpacing(6)
        }
        .padding(.horizontal, MosaicLayout.marginGenerous)
        .padding(.leading, MosaicLayout.marginGenerous / 2)
    }
    
    // MARK: - Discovery Type Selector
    
    private var discoveryTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MosaicLayout.itemSpacing) {
                ForEach(DiscoveryTab.allCases) { tab in
                    DiscoveryTabButton(
                        title: tab.title,
                        isSelected: viewModel.selectedTab == tab
                    ) {
                        viewModel.selectTab(tab)
                    }
                }
            }
            .padding(.horizontal, MosaicLayout.marginGenerous)
        }
    }
    
    // MARK: - Editorial Content
    
    private func editorialContent(garments: [Garment]) -> some View {
        ForEach(Array(garments.enumerated()), id: \.element.id) { index, garment in
            GarmentCard(
                garment: garment,
                layout: editorialLayout(for: index),
                onTap: {
                    viewModel.selectGarment(garment)
                },
                onFavorite: {
                    viewModel.toggleFavorite(garment)
                }
            )
            .padding(.horizontal, MosaicLayout.margin)
            .offset(x: editorialOffset(for: index))
        }
    }
    
    // MARK: - Editorial Layout Helpers
    
    private func editorialLayout(for index: Int) -> GarmentCardLayout {
        let layouts: [GarmentCardLayout] = [
            .featured,      // Large, full-width
            .compactLeft,   // Image left, text right
            .compactRight,  // Image right, text left
            .minimal,       // Small, centered
        ]
        return layouts[index % layouts.count]
    }
    
    private func editorialOffset(for index: Int) -> CGFloat {
        // Create asymmetric, flowing feel
        switch index % 4 {
        case 0: return 0
        case 1: return 20
        case 2: return -12
        case 3: return 8
        default: return 0
        }
    }
    
    // MARK: - Loading State
    
    private var loadingView: some View {
        VStack(spacing: MosaicLayout.groupSpacing) {
            ForEach(0..<3) { index in
                RoundedRectangle(cornerRadius: MosaicLayout.cornerRadius)
                    .fill(MosaicColors.oatmeal)
                    .frame(height: 300)
                    .padding(.horizontal, MosaicLayout.margin)
                    .offset(x: editorialOffset(for: index))
                    .shimmer()
            }
        }
        .padding(.top, MosaicLayout.groupSpacing)
    }
    
    // MARK: - Empty State
    
    private var emptyView: some View {
        VStack(spacing: MosaicLayout.groupSpacing) {
            Spacer()
                .frame(height: 60)
            
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(MosaicColors.terracotta.opacity(0.5))
            
            Text("No garments found")
                .font(MosaicTypography.headline2)
                .foregroundColor(MosaicColors.textPrimary)
            
            Text("Check back soon for new arrivals")
                .font(MosaicTypography.body)
                .foregroundColor(MosaicColors.textSecondary)
            
            Spacer()
        }
        .padding(.horizontal, MosaicLayout.marginGenerous)
    }
    
    // MARK: - Error State
    
    private func errorView(message: String) -> some View {
        VStack(spacing: MosaicLayout.groupSpacing) {
            Spacer()
                .frame(height: 60)
            
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 48))
                .foregroundColor(MosaicColors.burntSienna)
            
            Text("Something went wrong")
                .font(MosaicTypography.headline2)
                .foregroundColor(MosaicColors.textPrimary)
            
            Text(message)
                .font(MosaicTypography.body)
                .foregroundColor(MosaicColors.textSecondary)
                .multilineTextAlignment(.center)
            
            MosaicButton("Try Again", style: .primary) {
                Task {
                    await viewModel.loadGarments()
                }
            }
            .padding(.top, MosaicLayout.itemSpacing)
            
            Spacer()
        }
        .padding(.horizontal, MosaicLayout.marginGenerous)
    }
}

// MARK: - Discovery Tab

enum DiscoveryTab: CaseIterable, Identifiable {
    case forYou
    case newArrivals
    case trending
    case styleMatches
    
    var id: String { title }
    
    var title: String {
        switch self {
        case .forYou: return "For You"
        case .newArrivals: return "New"
        case .trending: return "Trending"
        case .styleMatches: return "Matches"
        }
    }
    
    var discoveryType: DiscoveryType {
        switch self {
        case .forYou: return .personalizedFeed
        case .newArrivals: return .newArrivals
        case .trending: return .trending
        case .styleMatches: return .styleMatches
        }
    }
}

// MARK: - Discovery Tab Button

struct DiscoveryTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MosaicTypography.label)
                .foregroundColor(isSelected ? MosaicColors.cream : MosaicColors.textPrimary)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    Capsule()
                        .fill(isSelected ? MosaicColors.terracotta : MosaicColors.cream)
                )
                .overlay(
                    Capsule()
                        .stroke(MosaicColors.border, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            MosaicColors.cream.opacity(0.5),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Preview

#Preview {
    DiscoveryView(viewModel: DiscoveryViewModel.preview())
}

#Preview("Empty") {
    DiscoveryView(viewModel: DiscoveryViewModel.previewEmpty())
}

#Preview("Loading") {
    DiscoveryView(viewModel: DiscoveryViewModel.previewLoading())
}