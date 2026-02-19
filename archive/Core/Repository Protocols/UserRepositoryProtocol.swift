import Foundation

// MARK: - UserRepositoryProtocol
/// Repository protocol for user data operations
/// Handles user profile, authentication-related data, and user preferences
public protocol UserRepositoryProtocol: Sendable {
    
    // MARK: - Current User
    
    /// Get the currently authenticated user
    func getCurrentUser() async throws -> User
    
    /// Update the current user's profile
    func updateUser(_ user: User) async throws -> User
    
    /// Get a specific user by ID
    func getUser(id: UUID) async throws -> User
}
