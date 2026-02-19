import SwiftUI
import Combine

// MARK: - WardrobeViewModel
/// ViewModel for managing the wardrobe view state and data
/// Handles loading, adding, and removing garments
@MainActor
public final class WardrobeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var garments: [ModaicsGarment] = []
    @Published public var wardrobe: ModaicsWardrobe?
    @Published public var isLoading: Bool = false
    @Published public var error: WardrobeError?
    @Published public var sortBy: SortOption = .recent
    
    // MARK: - Computed Properties
    public var garmentCount: Int {
        garments.count
    }
    
    public var estimatedValue: String {
        let total = garments.reduce(Decimal(0)) { $0 + ($1.listingPrice ?? $1.originalPrice ?? 0) }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: total as NSDecimalNumber) ?? "$0"
    }
    
    public var sustainabilityScore: Int {
        // Calculate based on garment count and sustainable materials
        let baseScore = min(garments.count * 5, 50)
        let sustainableBonus = garments.filter { garment in
            garment.materials.contains { $0.isSustainable }
        }.count * 3
        return min(baseScore + sustainableBonus, 100)
    }
    
    public var carbonSavedKg: Double {
        // Approximate: 8.5kg CO2 saved per secondhand garment
        Double(garments.count) * 8.5
    }
    
    public var waterSavedLiters: Double {
        // Approximate: 2,400L saved per secondhand garment vs new
        Double(garments.count) * 2400
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let wardrobeService: WardrobeServiceProtocol
    
    // MARK: - Initialization
    public init(wardrobeService: WardrobeServiceProtocol = MockWardrobeService()) {
        self.wardrobeService = wardrobeService
        
        // React to sort changes
        $sortBy
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.sortGarments()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Load the wardrobe data
    public func loadWardrobe() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            await fetchWardrobeData()
            isLoading = false
        }
    }
    
    /// Refresh the wardrobe data
    public func refresh() async {
        isLoading = true
        error = nil
        await fetchWardrobeData()
        isLoading = false
    }
    
    /// Add a garment to the wardrobe
    public func addGarment(_ garment: ModaicsGarment) async {
        isLoading = true
        
        do {
            let addedGarment = try await wardrobeService.addGarment(garment)
            garments.append(addedGarment)
            sortGarments()
        } catch {
            self.error = .failedToAddGarment
        }
        
        isLoading = false
    }
    
    /// Remove a garment from the wardrobe
    public func removeGarment(_ garmentId: UUID) async {
        isLoading = true
        
        do {
            try await wardrobeService.removeGarment(garmentId)
            garments.removeAll { $0.id == garmentId }
        } catch {
            self.error = .failedToRemoveGarment
        }
        
        isLoading = false
    }
    
    /// Clear any error state
    public func clearError() {
        error = nil
    }
    
    // MARK: - Private Methods
    
    private func fetchWardrobeData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadGarments() }
            group.addTask { await self.loadWardrobeStats() }
        }
    }
    
    private func loadGarments() async {
        do {
            let fetchedGarments = try await wardrobeService.getGarments()
            garments = fetchedGarments
            sortGarments()
        } catch {
            self.error = .failedToLoadGarments
        }
    }
    
    private func loadWardrobeStats() async {
        do {
            let fetchedWardrobe = try await wardrobeService.getWardrobe()
            wardrobe = fetchedWardrobe
        } catch {
            // Non-critical, don't show error
        }
    }
    
    private func sortGarments() {
        switch sortBy {
        case .recent:
            garments.sort { $0.createdAt > $1.createdAt }
        case .alphabetical:
            garments.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .brand:
            garments.sort { ($0.brand?.name ?? "") < ($1.brand?.name ?? "") }
        case .condition:
            let conditionOrder: [ModaicsCondition] = [
                .newWithTags, .newWithoutTags, .excellent, .veryGood,
                .good, .fair, .vintage, .needsRepair
            ]
            garments.sort { garment1, garment2 in
                guard let index1 = conditionOrder.firstIndex(of: garment1.condition),
                      let index2 = conditionOrder.firstIndex(of: garment2.condition) else {
                    return false
                }
                return index1 < index2
            }
        }
    }
}

// MARK: - Sort Option
public enum SortOption: String, CaseIterable, Identifiable {
    case recent = "recent"
    case alphabetical = "alphabetical"
    case brand = "brand"
    case condition = "condition"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .recent: return "Recently Added"
        case .alphabetical: return "Alphabetical"
        case .brand: return "Brand"
        case .condition: return "Condition"
        }
    }
}

// MARK: - Wardrobe Error
public enum WardrobeError: LocalizedError, Equatable {
    case failedToLoadGarments
    case failedToLoadWardrobe
    case failedToAddGarment
    case failedToRemoveGarment
    case networkError
    
    public var errorDescription: String? {
        switch self {
        case .failedToLoadGarments:
            return "Couldn't load your garments"
        case .failedToLoadWardrobe:
            return "Couldn't load your wardrobe"
        case .failedToAddGarment:
            return "Couldn't add the garment"
        case .failedToRemoveGarment:
            return "Couldn't remove the garment"
        case .networkError:
            return "Please check your connection"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .failedToLoadGarments, .failedToLoadWardrobe, .networkError:
            return "Pull down to refresh or try again later."
        case .failedToAddGarment:
            return "Please try again. If the problem persists, check your connection."
        case .failedToRemoveGarment:
            return "The garment may have already been removed."
        }
    }
}

// MARK: - Wardrobe Service Protocol
public protocol WardrobeServiceProtocol {
    func getGarments() async throws -> [ModaicsGarment]
    func getWardrobe() async throws -> ModaicsWardrobe
    func addGarment(_ garment: ModaicsGarment) async throws -> ModaicsGarment
    func removeGarment(_ garmentId: UUID) async throws
    func updateGarment(_ garment: ModaicsGarment) async throws -> ModaicsGarment
}

// MARK: - Mock Wardrobe Service
public final class MockWardrobeService: WardrobeServiceProtocol {
    private var mockGarments: [ModaicsGarment] = []
    private let currentUserId = UUID()
    
    public init() {
        self.mockGarments = createMockGarments()
    }
    
    public func getGarments() async throws -> [ModaicsGarment] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000)
        return mockGarments
    }
    
    public func getWardrobe() async throws -> ModaicsWardrobe {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return ModaicsWardrobe(
            id: UUID(),
            ownerId: currentUserId,
            name: "My Wardrobe",
            description: "Curated with intention",
            garmentIds: mockGarments.map(\.id),
            totalItems: mockGarments.count,
            listedItems: mockGarments.filter(\.isListed).count,
            estimatedValue: mockGarments.reduce(Decimal(0)) { $0 + ($1.listingPrice ?? 0) },
            originalValue: mockGarments.reduce(Decimal(0)) { $0 + ($1.originalPrice ?? 0) },
            savingsValue: 0,
            carbonSavedKg: Double(mockGarments.count) * 8.5,
            waterSavedLiters: Double(mockGarments.count) * 2400,
            itemsCirculated: mockGarments.filter { !$0.previousOwnerIds.isEmpty }.count
        )
    }
    
    public func addGarment(_ garment: ModaicsGarment) async throws -> ModaicsGarment {
        try await Task.sleep(nanoseconds: 600_000_000)
        mockGarments.append(garment)
        return garment
    }
    
    public func removeGarment(_ garmentId: UUID) async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
        mockGarments.removeAll { $0.id == garmentId }
    }
    
    public func updateGarment(_ garment: ModaicsGarment) async throws -> ModaicsGarment {
        try await Task.sleep(nanoseconds: 400_000_000)
        if let index = mockGarments.firstIndex(where: { $0.id == garment.id }) {
            mockGarments[index] = garment
        }
        return garment
    }
    
    // MARK: - Mock Data
    private func createMockGarments() -> [ModaicsGarment] {
        let storyId = UUID()
        
        return [
            ModaicsGarment(
                title: "Vintage Denim Jacket",
                description: "A classic vintage Levi's jacket with authentic wear patterns",
                storyId: storyId,
                condition: .vintage,
                originalPrice: 150.00,
                listingPrice: 85.00,
                category: .outerwear,
                colors: [ModaicsGarmentColor(name: "Indigo", hex: "#4B5563")],
                materials: [ModaicsMaterial(name: "Cotton", percentage: 100, isSustainable: true)],
                size: ModaicsSize(label: "M", system: .us),
                ownerId: currentUserId,
                isListed: true,
                exchangeType: .sellOrTrade,
                createdAt: Date().addingTimeInterval(-2592000)
            ),
            ModaicsGarment(
                title: "Cashmere Sweater",
                description: "Soft heather grey cashmere, barely worn",
                storyId: storyId,
                condition: .excellent,
                originalPrice: 295.00,
                listingPrice: 150.00,
                category: .tops,
                colors: [ModaicsGarmentColor(name: "Heather Grey", hex: "#9CA3AF")],
                materials: [ModaicsMaterial(name: "Cashmere", percentage: 100, isSustainable: false)],
                size: ModaicsSize(label: "M", system: .us),
                ownerId: currentUserId,
                isListed: false,
                createdAt: Date().addingTimeInterval(-1728000)
            ),
            ModaicsGarment(
                title: "Silk Blouse",
                description: "Elegant cream silk blouse with mother of pearl buttons",
                storyId: storyId,
                condition: .excellent,
                originalPrice: 180.00,
                category: .tops,
                colors: [ModaicsGarmentColor(name: "Cream", hex: "#F5F5DC")],
                materials: [
                    ModaicsMaterial(name: "Silk", percentage: 95, isSustainable: true),
                    ModaicsMaterial(name: "Mother of Pearl", percentage: 5, isSustainable: true)
                ],
                size: ModaicsSize(label: "S", system: .us),
                ownerId: currentUserId,
                previousOwnerIds: [UUID()],
                isListed: true,
                exchangeType: .sell,
                createdAt: Date().addingTimeInterval(-864000)
            ),
            ModaicsGarment(
                title: "Wool Coat",
                description: "Classic camel wool coat, timeless silhouette",
                storyId: storyId,
                condition: .veryGood,
                originalPrice: 450.00,
                listingPrice: 280.00,
                category: .outerwear,
                colors: [ModaicsGarmentColor(name: "Camel", hex: "#C19A6B")],
                materials: [ModaicsMaterial(name: "Wool", percentage: 80, isSustainable: true)],
                size: ModaicsSize(label: "M", system: .us),
                ownerId: currentUserId,
                previousOwnerIds: [UUID()],
                isListed: false,
                createdAt: Date().addingTimeInterval(-432000)
            ),
            ModaicsGarment(
                title: "Linen Trousers",
                description: "Relaxed beige linen trousers, perfect for summer",
                storyId: storyId,
                condition: .good,
                originalPrice: 120.00,
                listingPrice: 45.00,
                category: .bottoms,
                colors: [ModaicsGarmentColor(name: "Beige", hex: "#F5F5DC")],
                materials: [ModaicsMaterial(name: "Linen", percentage: 100, isSustainable: true)],
                size: ModaicsSize(label: "32", system: .us),
                ownerId: currentUserId,
                isListed: true,
                exchangeType: .sellOrTrade,
                createdAt: Date().addingTimeInterval(-345600)
            ),
            ModaicsGarment(
                title: "Pleated Midi Skirt",
                description: "Forest green pleated skirt with subtle sheen",
                storyId: storyId,
                condition: .excellent,
                originalPrice: 95.00,
                category: .bottoms,
                colors: [ModaicsGarmentColor(name: "Forest Green", hex: "#228B22")],
                materials: [ModaicsMaterial(name: "Polyester", percentage: 100, isSustainable: false)],
                size: ModaicsSize(label: "M", system: .us),
                ownerId: currentUserId,
                isListed: false,
                createdAt: Date().addingTimeInterval(-259200)
            ),
            ModaicsGarment(
                title: "Leather Ankle Boots",
                description: "Black leather ankle boots, barely worn",
                storyId: storyId,
                condition: .veryGood,
                originalPrice: 250.00,
                listingPrice: 120.00,
                category: .shoes,
                colors: [ModaicsGarmentColor(name: "Black", hex: "#000000")],
                materials: [ModaicsMaterial(name: "Leather", percentage: 100, isSustainable: false)],
                size: ModaicsSize(label: "38", system: .eu),
                ownerId: currentUserId,
                previousOwnerIds: [UUID()],
                isListed: true,
                exchangeType: .trade,
                createdAt: Date().addingTimeInterval(-172800)
            ),
            ModaicsGarment(
                title: "Cotton T-Shirt",
                description: "Organic cotton basic tee in white",
                storyId: storyId,
                condition: .good,
                originalPrice: 35.00,
                category: .tops,
                colors: [ModaicsGarmentColor(name: "White", hex: "#FFFFFF")],
                materials: [ModaicsMaterial(name: "Organic Cotton", percentage: 100, isSustainable: true)],
                size: ModaicsSize(label: "M", system: .us),
                ownerId: currentUserId,
                isListed: false,
                createdAt: Date().addingTimeInterval(-86400)
            )
        ]
    }
}

// MARK: - Preview Support
extension WardrobeViewModel {
    /// Creates a preview instance with mock data
    static func preview() -> WardrobeViewModel {
        let viewModel = WardrobeViewModel()
        viewModel.garments = MockWardrobeService().createMockGarments()
        return viewModel
    }
    
    /// Creates a preview instance with empty wardrobe
    static func previewEmpty() -> WardrobeViewModel {
        WardrobeViewModel()
    }
}
