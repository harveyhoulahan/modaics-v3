import Foundation
import SwiftUI

// MARK: - Consumer Sketchbook ViewModel
@MainActor
public class ConsumerSketchbookViewModel: ObservableObject {
    @Published public var sketchbook: Sketchbook? = nil
    @Published public var posts: [SketchbookPost] = []
    @Published public var membership: SketchbookMembership? = nil
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var showUnlockSheet: Bool = false
    
    public init() {
        // Load mock data
        loadMockData()
    }
    
    public var visiblePosts: [SketchbookPost] {
        guard let membership = membership, membership.status == .active else {
            return posts.filter { $0.visibility == .public }
        }
        return posts
    }
    
    public var hasLockedContent: Bool {
        posts.contains { $0.visibility == .membersOnly } && membership?.status != .active
    }
    
    public var lockedPostCount: Int {
        posts.filter { $0.visibility == .membersOnly }.count
    }
    
    private func loadMockData() {
        // In real app, this would fetch from API
        posts = SketchbookPost.mockPosts
    }
    
    public func loadSketchbook(brandId: String) async {
        isLoading = true
        // API call would go here
        sketchbook = Sketchbook.mockSketchbooks.first { $0.brandId == brandId }
        await loadPosts()
        isLoading = false
    }
    
    public func loadPosts() async {
        // API call would go here
        if let sketchbook = sketchbook {
            posts = SketchbookPost.mockPosts.filter { $0.sketchbookId == sketchbook.id }
        }
    }
    
    public func checkMembership() async {
        // API call would go here
        // For mock, randomly assign membership status
        membership = nil // Simulate non-member
    }
    
    public func requestMembership() async {
        // API call would go here
        membership = SketchbookMembership(
            id: 1,
            sketchbookId: sketchbook?.id ?? 1,
            userId: "user-001",
            status: .pending
        )
    }
    
    public func joinSketchbook() async {
        // For auto-approve sketchbooks
        membership = SketchbookMembership(
            id: 1,
            sketchbookId: sketchbook?.id ?? 1,
            userId: "user-001",
            status: .active,
            joinedAt: Date()
        )
    }
    
    public func toggleReaction(for post: SketchbookPost) {
        // Toggle reaction locally
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].reactionCount += 1
        }
    }
    
    public func voteInPoll(post: SketchbookPost, optionId: String) {
        // Record vote locally
        guard post.pollClosesAt == nil || post.pollClosesAt! > Date() else { return }
        
        if let postIndex = posts.firstIndex(where: { $0.id == post.id }),
           let optionIndex = posts[postIndex].pollOptions?.firstIndex(where: { $0.id == optionId }) {
            posts[postIndex].pollOptions?[optionIndex].voteCount += 1
        }
    }
}