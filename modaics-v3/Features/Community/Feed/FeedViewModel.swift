import Foundation
import SwiftUI
import Combine

// MARK: - FeedFilter
/// Filter options for the community feed
public enum FeedFilter: String, CaseIterable, Identifiable {
    case forYou = "For You"
    case following = "Following"
    case trending = "Trending"
    case challenges = "Challenges"
    
    public var id: String { rawValue }
    
    public var displayName: String { rawValue }
}

// MARK: - FeedViewModel
@MainActor
public class FeedViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var posts: [CommunityPost] = []
    @Published public var selectedFilter: FeedFilter = .forYou
    @Published public var isLoading: Bool = false
    @Published public var showComposeSheet: Bool = false
    @Published public var showPostDetail: Bool = false
    @Published public var selectedPost: CommunityPost? = nil
    
    // MARK: - Compose Sheet State
    @Published public var composePostType: PostType = .general
    @Published public var composeCaption: String = ""
    @Published public var composeTags: String = ""
    @Published public var composeLocation: String = ""
    @Published public var composeImages: [UIImage] = []
    @Published public var composeLinkedItem: LinkedItem? = nil
    @Published public var isComposing: Bool = false
    
    // MARK: - Search/Filter
    @Published public var searchQuery: String = ""
    
    // MARK: - Events Banner
    @Published public var upcomingEvents: [CommunityEvent] = []
    
    // MARK: - Dependencies
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init() {
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Could add search debounce here if needed
    }
    
    // MARK: - Data Loading
    public func loadPosts() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.posts = CommunityPost.mockPosts
            self?.loadUpcomingEvents()
            self?.isLoading = false
        }
    }
    
    private func loadUpcomingEvents() {
        // Get upcoming events from mock data
        upcomingEvents = CommunityEvent.mockEvents
            .filter { $0.isUpcoming }
            .sorted { $0.startDate < $1.startDate }
            .prefix(5)
            .map { $0 }
    }
    
    // MARK: - Actions
    public func selectFilter(_ filter: FeedFilter) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFilter = filter
        }
        // In a real app, this would fetch different data based on the filter
        loadPosts()
    }
    
    public func toggleLike(for post: CommunityPost) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            var updatedPost = posts[index]
            updatedPost.isLiked.toggle()
            updatedPost.likes += updatedPost.isLiked ? 1 : -1
            posts[index] = updatedPost
        }
    }
    
    public func toggleBookmark(for post: CommunityPost) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            var updatedPost = posts[index]
            updatedPost.isBookmarked.toggle()
            posts[index] = updatedPost
        }
    }
    
    public func sharePost(_ post: CommunityPost) {
        // In a real app, this would open the share sheet
        print("Sharing post: \(post.id)")
    }
    
    public func commentOnPost(_ post: CommunityPost) {
        selectedPost = post
        showPostDetail = true
    }
    
    public func openComposeSheet() {
        showComposeSheet = true
    }
    
    public func closeComposeSheet() {
        showComposeSheet = false
        resetComposeState()
    }
    
    public func createPost() {
        guard !composeCaption.isEmpty || !composeImages.isEmpty else { return }
        
        isComposing = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Create new post
            let imageURLs = self.composeImages.map { _ in
                "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600" // Placeholder
            }
            
            let tags = self.composeTags
                .split(separator: " ")
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            let newPost = CommunityPost(
                id: "post-\(UUID().uuidString.prefix(8))",
                userId: "current-user",
                username: "You",
                avatar: nil,
                postType: self.composePostType,
                caption: self.composeCaption,
                imageURLs: imageURLs,
                tags: tags,
                location: self.composeLocation.isEmpty ? nil : self.composeLocation,
                linkedItem: self.composeLinkedItem,
                createdAt: Date()
            )
            
            // Insert at top of feed
            self.posts.insert(newPost, at: 0)
            
            self.isComposing = false
            self.closeComposeSheet()
        }
    }
    
    public func resetComposeState() {
        composePostType = .general
        composeCaption = ""
        composeTags = ""
        composeLocation = ""
        composeImages = []
        composeLinkedItem = nil
    }
    
    public func addImage(_ image: UIImage) {
        guard composeImages.count < 4 else { return }
        composeImages.append(image)
    }
    
    public func removeImage(at index: Int) {
        guard index < composeImages.count else { return }
        composeImages.remove(at: index)
    }
    
    public func selectPostType(_ type: PostType) {
        composePostType = type
    }
    
    // MARK: - Computed Properties
    public var filteredPosts: [CommunityPost] {
        var filtered = posts
        
        // Apply filter
        switch selectedFilter {
        case .forYou:
            // Show all posts (algorithm would customize in real app)
            break
        case .following:
            // Would filter by followed users
            filtered = filtered.prefix(filtered.count / 2).map { $0 }
        case .trending:
            // Sort by likes
            filtered = filtered.sorted { $0.likes > $1.likes }
        case .challenges:
            filtered = filtered.filter { $0.postType == .challenge }
        }
        
        // Apply search if query exists
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            filtered = filtered.filter { post in
                post.caption.lowercased().contains(query) ||
                post.username.lowercased().contains(query) ||
                post.tags.contains { $0.lowercased().contains(query) }
            }
        }
        
        return filtered
    }
    
    public var canCreatePost: Bool {
        !composeCaption.isEmpty || !composeImages.isEmpty
    }
    
    public var composeTagsArray: [String] {
        composeTags
            .split(separator: " ")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
