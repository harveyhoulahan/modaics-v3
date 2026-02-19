import SwiftUI
import Combine

// MARK: - Wardrobe ViewModel
/// Connects the Wardrobe UI to the BuildWardrobeUseCase
@MainActor
class WardrobeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var garments: [Garment] = []
    @Published var collections: [WardrobeCollection] = []
    @Published var communityConnections: [CommunityConnection] = []
    @Published var sustainabilityScore: SustainabilityScore = SustainabilityScore(rating: 0, level: .seedling)
    @Published var isLoading = false
    @Published var error: WardrobeError?
    @Published var sortBy: SortOption = .recent
    
    // MARK: - Computed Properties
    var totalGarments: Int { garments.count }
    
    var uniqueBrands: Int {
        Set(garments.compactMap { $0.brand?.name }).count
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
        // Garments that were previously owned or from external sources
        garments.filter { !$0.previousOwnerIds.isEmpty || $0.source != .modaics }.count
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
    func removeGarment(_ garmentId: String) async throws {
        try await wardrobeUseCase.removeGarment(garmentId)
        garments.removeAll { $0.id.uuidString == garmentId }
        await updateSustainabilityScore()
    }
    
    /// Create a new collection
    func createCollection(name: String, garments: [String]) async throws -> WardrobeCollection {
        let collection = try await wardrobeUseCase.createCollection(name: name, garmentIds: garments)
        collections.append(collection)
        return collection
    }
    
    /// Add garment to collection
    func addToCollection(garmentId: String, collectionId: String) async throws {
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

// MARK: - Sort Options
enum SortOption {
    case recent
    case alphabetical
    case brand
    case mostWorn
}

// MARK: - Wardrobe Collection
struct WardrobeCollection: Identifiable {
    let id = UUID()
    let name: String
    let garmentCount: Int
    let previewGarments: [Garment]
    let createdAt: Date
}

// MARK: - Community Connection
struct CommunityConnection: Identifiable {
    let id = UUID()
    let userName: String
    let initials: String
    let avatarColor: Color
    let description: String
    let date: Date
}

// MARK: - Sustainability Score
struct SustainabilityScore {
    let rating: Int // 0-100
    let level: SustainabilityLevel
}

enum SustainabilityLevel: String {
    case seedling = "Seedling"
    case growing = "Growing"
    case blooming = "Blooming"
    case thriving = "Thriving"
}

// MARK: - Use Case Protocol
protocol BuildWardrobeUseCaseProtocol {
    func getGarments() async throws -> [Garment]
    func getCollections() async throws -> [WardrobeCollection]
    func getCommunityConnections() async throws -> [CommunityConnection]
    func getSustainabilityScore() async throws -> SustainabilityScore
    func addGarment(_ garment: Garment) async throws -> Garment
    func removeGarment(_ garmentId: String) async throws
    func createCollection(name: String, garmentIds: [String]) async throws -> WardrobeCollection
    func addToCollection(garmentId: String, collectionId: String) async throws
}

// MARK: - Mock Use Case
class MockBuildWardrobeUseCase: BuildWardrobeUseCaseProtocol {
    func getGarments() async throws -> [Garment] {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        return [
            Garment(title: "Cashmere Sweater", description: "Soft cashmere", story: Story(narrative: "A gift from my mother", provenance: "Everlane"), condition: .excellent, category: .tops, size: Size(label: "M", system: .us), ownerId: UUID(), brand: Brand(name: "Everlane")),
            Garment(title: "Wool Coat", description: "Classic wool coat", story: Story(narrative: "Found in London", provenance: "COS"), condition: .excellent, category: .outerwear, size: Size(label: "M", system: .us), ownerId: UUID(), brand: Brand(name: "COS")),
            Garment(title: "Silk Blouse", description: "Elegant silk", story: Story(narrative: "Wedding outfit", provenance: "Reformation"), condition: .excellent, category: .tops, size: Size(label: "S", system: .us), ownerId: UUID(), brand: Brand(name: "Reformation")),
            Garment(title: "Linen Trousers", description: "Summer essential", story: Story(narrative: "Holiday purchase", provenance: "ARKET"), condition: .veryGood, category: .bottoms, size: Size(label: "32", system: .us), ownerId: UUID(), brand: Brand(name: "ARKET")),
            Garment(title: "Denim Jacket", description: "Vintage style", story: Story(narrative: "Thrift find", provenance: "Levi's"), condition: .vintage, category: .outerwear, size: Size(label: "L", system: .us), ownerId: UUID(), brand: Brand(name: "Levi's")),
            Garment(title: "Cotton T-Shirt", description: "Basic tee", story: Story(narrative: "Staple piece", provenance: "Organic Basics"), condition: .good, category: .tops, size: Size(label: "M", system: .us), ownerId: UUID(), brand: Brand(name: "Organic Basics")),
            Garment(title: "Pleated Skirt", description: "Classic pleats", story: Story(narrative: "Office wear", provenance: "Uniqlo"), condition: .excellent, category: .bottoms, size: Size(label: "M", system: .us), ownerId: UUID(), brand: Brand(name: "Uniqlo")),
            Garment(title: "Knit Cardigan", description: "Cozy knit", story: Story(narrative: "Autumn favorite", provenance: "& Other Stories"), condition: .veryGood, category: .tops, size: Size(label: "S", system: .us), ownerId: UUID(), brand: Brand(name: "& Other Stories"))
        ]
    }
    
    func getCollections() async throws -> [WardrobeCollection] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return [
            WardrobeCollection(name: "Work Essentials", garmentCount: 8, previewGarments: [], createdAt: Date().addingTimeInterval(-2592000)),
            WardrobeCollection(name: "Weekend Casual", garmentCount: 5, previewGarments: [], createdAt: Date().addingTimeInterval(-1728000)),
            WardrobeCollection(name: "Special Occasions", garmentCount: 3, previewGarments: [], createdAt: Date().addingTimeInterval(-864000))
        ]
    }
    
    func getCommunityConnections() async throws -> [CommunityConnection] {
        try await Task.sleep(nanoseconds: 400_000_000)
        
        return [
            CommunityConnection(
                userName: "Sarah Mitchell",
                initials: "SM",
                avatarColor: .orange,
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
                avatarColor: .pink,
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
    
    func removeGarment(_ garmentId: String) async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
    }
    
    func createCollection(name: String, garmentIds: [String]) async throws -> WardrobeCollection {
        try await Task.sleep(nanoseconds: 500_000_000)
        return WardrobeCollection(name: name, garmentCount: garmentIds.count, previewGarments: [], createdAt: Date())
    }
    
    func addToCollection(garmentId: String, collectionId: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
}
