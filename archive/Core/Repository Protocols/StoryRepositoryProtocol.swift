import Foundation

// MARK: - StoryRepositoryProtocol
/// Repository protocol for story data operations
/// Handles CRUD operations and specialized queries for stories
public protocol StoryRepositoryProtocol: Sendable {
    
    // MARK: - CRUD Operations
    
    /// Get stories for a specific garment
    func getStories(for garmentId: UUID) async throws -> [Story]
    
    /// Create a new story
    func createStory(_ story: Story) async throws -> Story
    
    /// Delete a story by ID
    func deleteStory(id: UUID) async throws
}
