import SwiftUI
import Combine

// MARK: - Discovery View State

public enum DiscoveryViewState: Equatable {
    case loading
    case loaded([Garment])
    case empty
    case error(String)
    
    public static func == (lhs: DiscoveryViewState, rhs: DiscoveryViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.empty, .empty): return true
        case (.error(let lhsMsg), .error(let rhsMsg)): return lhsMsg == rhsMsg
        case (.loaded(let lhsGarments), .loaded(let rhsGarments)):
            return lhsGarments.map(\.id) == rhsGarments.map(\.id)
        default: return false
        }
    }
}

// MARK: - Discovery View Model

@MainActor
public class DiscoveryViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published public var state: DiscoveryViewState = .loading
    @Published public var selectedTab: DiscoveryTab = .forYou
    @Published public var selectedGarment: Garment?
    @Published public var isLoadingMore = false
    @Published public var hasMoreContent = true
    
    // MARK: - Private Properties
    
    private let discoverUseCase: DiscoverGarmentsUseCaseProtocol?
    private var currentPage = 1
    private var currentGarments: [Garment] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(discoverUseCase: DiscoverGarmentsUseCaseProtocol? = nil) {
        self.discoverUseCase = discoverUseCase
    }
    
    // MARK: - Public Methods
    
    public func loadGarments() async {
        state = .loading
        currentPage = 1
        currentGarments = []
        
        await fetchGarments()
    }
    
    public func loadMore() async {
        guard !isLoadingMore && hasMoreContent else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        await fetchGarments(append: true)
        
        isLoadingMore = false
    }
    
    public func selectTab(_ tab: DiscoveryTab) {
        selectedTab = tab
        Task {
            await loadGarments()
        }
    }
    
    public func selectGarment(_ garment: Garment) {
        selectedGarment = garment
    }
    
    public func toggleFavorite(_ garment: Garment) {
        // In real implementation, would call favorite use case
        print("Toggle favorite for: \(garment.title)")
    }
    
    public func refresh() async {
        await loadGarments()
    }
    
    // MARK: - Private Methods
    
    private func fetchGarments(append: Bool = false) async {
        // Check if we have a real use case
        if let useCase = discoverUseCase {
            await fetchFromUseCase(useCase, append: append)
        } else {
            // Use sample data for preview/development
            await fetchSampleData(append: append)
        }
    }
    
    private func fetchFromUseCase(_ useCase: DiscoverGarmentsUseCaseProtocol, append: Bool) async {
        let input = DiscoverGarmentsInput(
            userId: nil, // Current user
            discoveryType: selectedTab.discoveryType,
            page: currentPage,
            limit: 20
        )
        
        do {
            let output = try await useCase.execute(input: input)
            
            if append {
                currentGarments.append(contentsOf: output.garments)
            } else {
                currentGarments = output.garments
            }
            
            hasMoreContent = output.hasMore
            
            if currentGarments.isEmpty {
                state = .empty
            } else {
                state = .loaded(currentGarments)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    private func fetchSampleData(append: Bool) async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let sampleGarments = [
            Garment.sample,
            Garment.sampleDress,
            Garment.sampleVintageCoat,
            Garment.sampleLinenShirt,
            Garment.sampleWoolSweater
        ]
        
        if append {
            currentGarments.append(contentsOf: sampleGarments)
        } else {
            currentGarments = sampleGarments
        }
        
        hasMoreContent = currentPage < 3
        
        if currentGarments.isEmpty {
            state = .empty
        } else {
            state = .loaded(currentGarments)
        }
    }
}

// MARK: - Preview Helpers

extension DiscoveryViewModel {
    static func preview() -> DiscoveryViewModel {
        let vm = DiscoveryViewModel()
        vm.state = .loaded([
            .sample,
            .sampleDress,
            .sampleVintageCoat,
            .sampleLinenShirt,
            .sampleWoolSweater
        ])
        return vm
    }
    
    static func previewEmpty() -> DiscoveryViewModel {
        let vm = DiscoveryViewModel()
        vm.state = .empty
        return vm
    }
    
    static func previewLoading() -> DiscoveryViewModel {
        DiscoveryViewModel()
    }
    
    static func previewError() -> DiscoveryViewModel {
        let vm = DiscoveryViewModel()
        vm.state = .error("Network connection failed")
        return vm
    }
}

// MARK: - Sample Data Extensions

extension Garment {
    static let sampleVintageCoat = Garment(
        title: "Camel Wool Overcoat",
        description: "A timeless camel overcoat in heavyweight wool. Single-breasted with notch lapels.",
        story: Story(
            narrative: "My grandfather wore this coat for twenty years through London winters. The lining has been repaired twice, the buttons replaced once, but the wool still holds its shape beautifully.",
            provenance: "Savile Row, London - 1980s",
            whySelling: "Too warm for my current climate, deserves to see more winters"
        ),
        condition: .vintage,
        suggestedPrice: 340.00,
        category: .outerwear,
        styleTags: ["classic", "vintage", "wool", "timeless"],
        colors: [Color(name: "Camel", hex: "#C19A6B")],
        materials: [Material(name: "Wool", percentage: 100)],
        brand: Brand(name: "Burberry", isLuxury: true),
        size: Size(label: "42R", system: .us),
        era: .eighties,
        ownerId: UUID(),
        isListed: true,
        exchangeType: .sell
    )
    
    static let sampleLinenShirt = Garment(
        title: "Oversized Linen Shirt",
        description: "Relaxed fit linen shirt in natural oatmeal. Perfect for Mediterranean summers.",
        story: Story(
            narrative: "Found this in a small atelier in Lisbon. The fabric is from a family-run mill in Porto that has been weaving linen for five generations.",
            provenance: "Lisbon, Portugal"
        ),
        condition: .excellent,
        suggestedPrice: 85.00,
        category: .tops,
        styleTags: ["minimal", "summer", "natural"],
        colors: [Color(name: "Oatmeal", hex: "#E6DCC8")],
        materials: [Material(name: "Linen", percentage: 100, isSustainable: true)],
        brand: Brand(name: "Atelier M", isSustainable: true),
        size: Size(label: "L", system: .us),
        ownerId: UUID(),
        isListed: true,
        exchangeType: .sellOrTrade
    )
    
    static let sampleWoolSweater = Garment(
        title: "Hand-Knit Fisherman Sweater",
        description: "Traditional Aran knit in undyed cream wool. Cable patterns tell the story of Irish fishing families.",
        story: Story(
            narrative: "Each cable pattern has meaning - the honeycomb represents hard work, the diamond marks success. My grandmother taught me to read these patterns before she taught me to read books.",
            provenance: "Aran Islands, Ireland - Handmade",
            whySelling: "Passing it on to someone who will appreciate the craftsmanship"
        ),
        condition: .veryGood,
        suggestedPrice: 165.00,
        category: .tops,
        styleTags: ["handmade", "heritage", "wool", "cozy"],
        colors: [Color(name: "Cream", hex: "#F5F0E8")],
        materials: [Material(name: "Wool", percentage: 100, isSustainable: true)],
        size: Size(label: "M", system: .us),
        era: .contemporary,
        ownerId: UUID(),
        isListed: true,
        exchangeType: .trade
    )
}