import SwiftUI
import Combine

// MARK: - Wardrobe ViewModel
/// Connects the Wardrobe UI to the BuildWardrobeUseCase
@MainActor
class WardrobeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var garments: [Garment] = []
    @Published var collections: [GarmentCollection] = []
    @Published var communityConnections: [CommunityConnection] = []
    @Published var sustainabilityScore: SustainabilityScore = SustainabilityScore(rating: 0, level: .seedling)
    @Published var isLoading = false
    @Published var error: WardrobeError?
    @Published var sortBy: SortOption = .recent
    
    // MARK: - Computed Properties
    var totalGarments: Int { garments.count }
    
    var uniqueBrands: Int {
        Set(garments.map { $0.brand?.name ?? "Unknown" }).count
    }
    
    var waterSaved: Int {
        // Approximate: 2,400L saved per secondhand garment vs new
        garments.count * 2400
    }
    
    var co2Prevented: Double {
        // Approximate: 8.5kg CO2 saved per secondhand garment
        Double(garments.count) * 8.5
    }
    
    var garmentsRecirculated: Int {
        // Garments that were previously owned
        garments.filter { !$0.previousOwnerIds.isEmpty }.count
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let wardrobeUseCase: BuildWardrobeUseCaseProtocol
    
    // MARK: - Initialization
    init(wardrobeUseCase: BuildWardrobeUseCaseProtocol = MockBuildWardrobeUseCase()) {
        self.wardrobeUseCase = wardrobeUseCase
        
        // React to sort changes
        $sortBy
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.sortGarments()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Load the complete wardrobe data
    func loadWardrobe() {
        isLoading = true
        
        Task {
            await fetchAllWardrobeData()
            isLoading = false
        }
    }
    
    /// Refresh all wardrobe data
    func refresh() async {
        isLoading = true
        await fetchAllWardrobeData()
        isLoading = false
    }
    
    /// Create a new collection
    func createNewCollection() {
        // Navigate to collection creation
        // This would typically trigger a navigation event or sheet presentation
    }
    
    /// Show all community connections
    func showAllConnections() {
        // Navigate to full community connections view
    }
    
    /// Add a garment to the wardrobe
    func addGarment(_ garment: Garment) async throws {
        let addedGarment = try await wardrobeUseCase.addGarment(garment)
        garments.append(addedGarment)
        sortGarments()
        await updateSustainabilityScore()
    }
    
    /// Remove a garment from the wardrobe
    func removeGarment(_ garmentId: UUID) async throws {
        try await wardrobeUseCase.removeGarment(garmentId)
        garments.removeAll { $0.id == garmentId }
        await updateSustainabilityScore()
    }
    
    /// Create a new collection
    func createCollection(name: String, garments: [UUID]) async throws -> GarmentCollection {
        let collection = try await wardrobeUseCase.createCollection(name: name, garmentIds: garments)
        collections.append(collection)
        return collection
    }
    
    /// Add garment to collection
    func addToCollection(garmentId: UUID, collectionId: UUID) async throws {
        try await wardrobeUseCase.addToCollection(garmentId: garmentId, collectionId: collectionId)
        // Refresh collections
        await loadCollections()
    }
    
    // MARK: - Private Methods
    
    private func fetchAllWardrobeData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadGarments() }
            group.addTask { await self.loadCollections() }
            group.addTask { await self.loadCommunityConnections() }
            group.addTask { await self.loadSustainabilityScore() }
        }
    }
    
    private func loadGarments() async {
        do {
            let fetchedGarments = try await wardrobeUseCase.getGarments()
            garments = fetchedGarments
            sortGarments()
        } catch {
            self.error = .failedToLoadGarments
        }
    }
    
    private func loadCollections() async {
        do {
            let fetchedCollections = try await wardrobeUseCase.getCollections()
            collections = fetchedCollections
        } catch {
            self.error = .failedToLoadCollections
        }
    }
    
    private func loadCommunityConnections() async {
        do {
            let connections = try await wardrobeUseCase.getCommunityConnections()
            communityConnections = connections
        } catch {
            // Non-critical error, don't show
        }
    }
    
    private func loadSustainabilityScore() async {
        do {
            let score = try await wardrobeUseCase.getSustainabilityScore()
            sustainabilityScore = score
        } catch {
            // Use default score if loading fails
            sustainabilityScore = SustainabilityScore(rating: 50, level: .growing)
        }
    }
    
    private func updateSustainabilityScore() async {
        await loadSustainabilityScore()
    }
    
    private func sortGarments() {
        switch sortBy {
        case .recent:
            // Sort by date added
            garments.sort { $0.createdAt > $1.createdAt }
        case .alphabetical:
            garments.sort { $0.title < $1.title }
        case .brand:
            garments.sort { ($0.brand?.name ?? "") < ($1.brand?.name ?? "") }
        case .mostWorn:
            // Would sort by wear count
            break
        }
    }
    
    // MARK: - Error Handling
    func clearError() {
        error = nil
    }
}

// MARK: - Wardrobe Error
enum WardrobeError: LocalizedError {
    case failedToLoadGarments
    case failedToLoadCollections
    case failedToAddGarment
    case failedToRemoveGarment
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .failedToLoadGarments:
            return "Couldn't load your wardrobe"
        case .failedToLoadCollections:
            return "Couldn't load your collections"
        case .failedToAddGarment:
            return "Couldn't add the garment"
        case .failedToRemoveGarment:
            return "Couldn't remove the garment"
        case .networkError:
            return "Please check your connection"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .failedToLoadGarments, .failedToLoadCollections, .networkError:
            return "Pull down to refresh or try again later."
        case .failedToAddGarment:
            return "Please try again. If the problem persists, check your connection."
        case .failedToRemoveGarment:
            return "The garment may have already been removed."
        }
    }
}

// MARK: - Wardrobe Use Case Protocol
protocol WardrobeUseCaseProtocol {
    func getGarments() async throws -> [Garment]
    func getCollections() async throws -> [GarmentCollection]
    func getCommunityConnections() async throws -> [CommunityConnection]
    func getSustainabilityScore() async throws -> SustainabilityScore
    func addGarment(_ garment: Garment) async throws -> Garment
    func removeGarment(_ garmentId: UUID) async throws
    func createCollection(name: String, garmentIds: [UUID]) async throws -> GarmentCollection
    func addToCollection(garmentId: UUID, collectionId: UUID) async throws
}

// MARK: - Mock Use Case
class MockBuildWardrobeUseCase: WardrobeUseCaseProtocol {
    func getGarments() async throws -> [Garment] {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        return [
            Garment(
                title: "Cashmere Sweater",
                description: "Soft cashmere sweater",
                story: Story.sampleMinimal,
                condition: .excellent,
                category: .tops,
                size: Size(label: "M", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Wool Coat",
                description: "Classic wool coat",
                story: Story.sampleMinimal,
                condition: .excellent,
                category: .outerwear,
                size: Size(label: "M", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Silk Blouse",
                description: "Elegant silk blouse",
                story: Story.sampleMinimal,
                condition: .excellent,
                category: .tops,
                size: Size(label: "S", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Linen Trousers",
                description: "Relaxed linen trousers",
                story: Story.sampleMinimal,
                condition: .good,
                category: .bottoms,
                size: Size(label: "32", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Denim Jacket",
                description: "Classic denim jacket",
                story: Story.sampleMinimal,
                condition: .vintage,
                category: .outerwear,
                size: Size(label: "L", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Cotton T-Shirt",
                description: "Basic cotton tee",
                story: Story.sampleMinimal,
                condition: .good,
                category: .tops,
                size: Size(label: "M", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Pleated Skirt",
                description: "Elegant pleated skirt",
                story: Story.sampleMinimal,
                condition: .veryGood,
                category: .bottoms,
                size: Size(label: "M", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Knit Cardigan",
                description: "Cozy knit cardigan",
                story: Story.sampleMinimal,
                condition: .excellent,
                category: .tops,
                size: Size(label: "S", system: .us),
                ownerId: UUID()
            )
        ]
    }
    
    func getCollections() async throws -> [GarmentCollection] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return [
            GarmentCollection(name: "Work Essentials", garmentCount: 8, previewGarments: [], createdAt: Date().addingTimeInterval(-2592000)),
            GarmentCollection(name: "Weekend Casual", garmentCount: 5, previewGarments: [], createdAt: Date().addingTimeInterval(-1728000)),
            GarmentCollection(name: "Special Occasions", garmentCount: 3, previewGarments: [], createdAt: Date().addingTimeInterval(-864000))
        ]
    }
    
    func getCommunityConnections() async throws -> [CommunityConnection] {
        try await Task.sleep(nanoseconds: 400_000_000)
        
        return [
            CommunityConnection(
                userName: "Sarah Mitchell",
                initials: "SM",
                avatarColor: .modaicsTerracotta,
                description: "Sarah shared a handoff note with her vintage wool coat",
                date: Date().addingTimeInterval(-86400)
            ),
            CommunityConnection(
                userName: "James Liu",
                initials: "JL",
                avatarColor: .blue,
                description: "You traded your denim jacket for James's linen shirt",
                date: Date().addingTimeInterval(-172800)
            ),
            CommunityConnection(
                userName: "Emma Rodriguez",
                initials: "ER",
                avatarColor: .green,
                description: "Emma discovered your listed silk blouse",
                date: Date().addingTimeInterval(-259200)
            ),
            CommunityConnection(
                userName: "Oliver Chen",
                initials: "OC",
                avatarColor: .purple,
                description: "Oliver added your cashmere sweater to their wishlist",
                date: Date().addingTimeInterval(-345600)
            ),
            CommunityConnection(
                userName: "Maya Patel",
                initials: "MP",
                avatarColor: .orange,
                description: "You and Maya have exchanged 3 pieces now!",
                date: Date().addingTimeInterval(-432000)
            )
        ]
    }
    
    func getSustainabilityScore() async throws -> SustainabilityScore {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return SustainabilityScore(rating: 72, level: .blooming)
    }
    
    func addGarment(_ garment: Garment) async throws -> Garment {
        try await Task.sleep(nanoseconds: 600_000_000)
        return garment
    }
    
    func removeGarment(_ garmentId: UUID) async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
    }
    
    func createCollection(name: String, garmentIds: [UUID]) async throws -> GarmentCollection {
        try await Task.sleep(nanoseconds: 500_000_000)
        return GarmentCollection(name: name, garmentIds: garmentIds, sortOrder: 0, createdAt: Date())
    }
    
    func addToCollection(garmentId: UUID, collectionId: UUID) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
}