import Foundation
import Combine

// MARK: - Discovery ViewModel
@MainActor
class DiscoveryViewModel: ObservableObject {
    @Published var trendingStories: [Story] = []
    @Published var recentGarments: [Garment] = []
    @Published var collections: [WardrobeCollection] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let getDiscoveryFeedUseCase: GetDiscoveryFeedUseCaseProtocol
    private let logger: LoggerProtocol
    
    init(
        getDiscoveryFeedUseCase: GetDiscoveryFeedUseCaseProtocol,
        logger: LoggerProtocol
    ) {
        self.getDiscoveryFeedUseCase = getDiscoveryFeedUseCase
        self.logger = logger
        
        Task {
            await loadDiscoveryFeed()
        }
    }
    
    func loadDiscoveryFeed() async {
        isLoading = true
        error = nil
        
        do {
            let feed = try await getDiscoveryFeedUseCase.execute()
            self.trendingStories = feed.trendingStories
            self.recentGarments = feed.recentGarments
            self.collections = feed.collections
            logger.log("Discovery feed loaded successfully", level: .info)
        } catch {
            self.error = error
            logger.log("Failed to load discovery feed: \(error.localizedDescription)", level: .error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadDiscoveryFeed()
    }
}

// MARK: - Wardrobe ViewModel
@MainActor
class WardrobeViewModel: ObservableObject {
    @Published var garments: [Garment] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showAddGarment = false
    @Published var searchQuery = ""
    
    private let getGarmentsUseCase: GetGarmentsUseCaseProtocol
    private let createGarmentUseCase: CreateGarmentUseCaseProtocol
    private let deleteGarmentUseCase: DeleteGarmentUseCaseProtocol
    private let logger: LoggerProtocol
    
    var filteredGarments: [Garment] {
        if searchQuery.isEmpty {
            return garments
        }
        return garments.filter { garment in
            garment.title.localizedCaseInsensitiveContains(searchQuery) ||
            garment.category.rawValue.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    init(
        getGarmentsUseCase: GetGarmentsUseCaseProtocol,
        createGarmentUseCase: CreateGarmentUseCaseProtocol,
        deleteGarmentUseCase: DeleteGarmentUseCaseProtocol,
        logger: LoggerProtocol
    ) {
        self.getGarmentsUseCase = getGarmentsUseCase
        self.createGarmentUseCase = createGarmentUseCase
        self.deleteGarmentUseCase = deleteGarmentUseCase
        self.logger = logger
        
        Task {
            await loadGarments()
        }
    }
    
    func loadGarments() async {
        isLoading = true
        error = nil
        
        do {
            garments = try await getGarmentsUseCase.execute()
            logger.log("Loaded \(garments.count) garments", level: .info)
        } catch {
            self.error = error
            logger.log("Failed to load garments: \(error.localizedDescription)", level: .error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadGarments()
    }
    
    func createGarment(_ garment: Garment) async {
        do {
            let newGarment = try await createGarmentUseCase.execute(garment)
            garments.insert(newGarment, at: 0)
            logger.log("Created garment: \(newGarment.id)", level: .info)
        } catch {
            self.error = error
            logger.log("Failed to create garment: \(error.localizedDescription)", level: .error)
        }
    }
    
    func deleteGarment(id: UUID) async {
        do {
            try await deleteGarmentUseCase.execute(id: id)
            garments.removeAll { $0.id == id }
            logger.log("Deleted garment: \(id)", level: .info)
        } catch {
            self.error = error
            logger.log("Failed to delete garment: \(error.localizedDescription)", level: .error)
        }
    }
}

// MARK: - Profile ViewModel
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let getUserProfileUseCase: GetUserProfileUseCaseProtocol
    private let authService: AuthServiceProtocol
    private let logger: LoggerProtocol
    
    var displayName: String {
        user?.displayName ?? "Guest"
    }
    
    var userInitials: String {
        let name = displayName
        let components = name.split(separator: " ")
        if components.count > 1 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
    
    var garmentCount: Int {
        user?.wardrobeCount ?? 0
    }
    
    var storyCount: Int {
        0 // Not directly available on User model
    }
    
    var followerCount: Int {
        user?.followerCount ?? 0
    }
    
    init(
        getUserProfileUseCase: GetUserProfileUseCaseProtocol,
        authService: AuthServiceProtocol,
        logger: LoggerProtocol
    ) {
        self.getUserProfileUseCase = getUserProfileUseCase
        self.authService = authService
        self.logger = logger
        
        Task {
            await loadProfile()
        }
    }
    
    func loadProfile() async {
        isLoading = true
        error = nil
        
        do {
            user = try await getUserProfileUseCase.execute()
            logger.log("Profile loaded for user: \(user?.id ?? "unknown")", level: .info)
        } catch {
            self.error = error
            logger.log("Failed to load profile: \(error.localizedDescription)", level: .error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadProfile()
    }
}

// MARK: - Garment Detail ViewModel
@MainActor
class GarmentDetailViewModel: ObservableObject {
    @Published var garment: Garment?
    @Published var stories: [Story] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    let garmentId: UUID
    private let garmentRepository: GarmentRepositoryProtocol
    private let getStoriesUseCase: GetStoriesUseCaseProtocol
    private let logger: LoggerProtocol
    
    init(
        garmentId: UUID,
        garmentRepository: GarmentRepositoryProtocol,
        getStoriesUseCase: GetStoriesUseCaseProtocol,
        logger: LoggerProtocol
    ) {
        self.garmentId = garmentId
        self.garmentRepository = garmentRepository
        self.getStoriesUseCase = getStoriesUseCase
        self.logger = logger
        
        Task {
            await loadGarment()
        }
    }
    
    func loadGarment() async {
        isLoading = true
        error = nil
        
        do {
            async let garmentTask = garmentRepository.getGarment(id: garmentId)
            async let storiesTask = getStoriesUseCase.execute(for: garmentId)
            
            self.garment = try await garmentTask
            self.stories = try await storiesTask
            
            logger.log("Loaded garment: \(garmentId)", level: .info)
        } catch {
            self.error = error
            logger.log("Failed to load garment: \(error.localizedDescription)", level: .error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadGarment()
    }
}

// MARK: - Story Composer ViewModel
@MainActor
class StoryComposerViewModel: ObservableObject {
    @Published var title = ""
    @Published var content = ""
    @Published var selectedGarmentId: UUID?
    @Published var selectedImages: [UIImage] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isSuccess = false
    
    private let createStoryUseCase: CreateStoryUseCaseProtocol
    private let uploadImageUseCase: UploadImageUseCaseProtocol
    private let garmentRepository: GarmentRepositoryProtocol
    private let logger: LoggerProtocol
    
    var canSubmit: Bool {
        !title.isEmpty && !content.isEmpty && selectedGarmentId != nil
    }
    
    init(
        createStoryUseCase: CreateStoryUseCaseProtocol,
        uploadImageUseCase: UploadImageUseCaseProtocol,
        garmentRepository: GarmentRepositoryProtocol,
        logger: LoggerProtocol
    ) {
        self.createStoryUseCase = createStoryUseCase
        self.uploadImageUseCase = uploadImageUseCase
        self.garmentRepository = garmentRepository
        self.logger = logger
    }
    
    func submitStory() async {
        isLoading = true
        error = nil
        
        do {
            // Create story using Core Domain model
            let story = Story(
                narrative: content,
                provenance: title,
                memories: [],
                whySelling: nil
            )
            
            _ = try await createStoryUseCase.execute(story)
            isSuccess = true
            logger.log("Story created successfully", level: .info)
            
        } catch {
            self.error = error
            logger.log("Failed to create story: \(error.localizedDescription)", level: .error)
        }
        
        isLoading = false
    }
}

// MARK: - Settings ViewModel
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled = true
    @Published var offlineModeEnabled = false
    @Published var isLoading = false
    
    private let authService: AuthServiceProtocol
    private let logger: LoggerProtocol
    
    init(
        authService: AuthServiceProtocol,
        logger: LoggerProtocol
    ) {
        self.authService = authService
        self.logger = logger
        
        // Load saved settings
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        offlineModeEnabled = UserDefaults.standard.bool(forKey: "offlineModeEnabled")
    }
    
    func updateNotifications(enabled: Bool) {
        notificationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "notificationsEnabled")
        logger.log("Notifications \(enabled ? "enabled" : "disabled")", level: .info)
    }
    
    func updateOfflineMode(enabled: Bool) {
        offlineModeEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "offlineModeEnabled")
        logger.log("Offline mode \(enabled ? "enabled" : "disabled")", level: .info)
    }
    
    func signOut() {
        do {
            try authService.signOut()
            logger.log("User signed out", level: .info)
        } catch {
            logger.log("Failed to sign out: \(error.localizedDescription)", level: .error)
        }
    }
}