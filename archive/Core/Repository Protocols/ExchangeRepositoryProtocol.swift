import Foundation

// MARK: - ExchangeRepositoryProtocol
/// Repository protocol for exchange/transaction operations
/// Handles buy, sell, and trade transactions between users
public protocol ExchangeRepositoryProtocol: Sendable {
    
    // MARK: - CRUD Operations
    
    /// Get an exchange by ID
    func get(by id: UUID) async throws -> Exchange
    
    /// Get multiple exchanges by IDs
    func get(ids: [UUID]) async throws -> [Exchange]
    
    /// Create a new exchange
    func create(_ exchange: Exchange) async throws -> Exchange
    
    /// Update an exchange
    func update(_ exchange: Exchange) async throws -> Exchange
    
    /// Delete an exchange (rare, usually for admin)
    func delete(id: UUID) async throws
    
    // MARK: - User Exchanges
    
    /// Get all exchanges where user is the initiator
    func getInitiatedBy(userId: UUID) async throws -> [Exchange]
    
    /// Get all exchanges where user is the recipient
    func getReceivedBy(userId: UUID) async throws -> [Exchange]
    
    /// Get all exchanges involving a user (either side)
    func getAllFor(userId: UUID) async throws -> [Exchange]
    
    /// Get paginated exchanges for a user
    func getAllFor(userId: UUID, page: Int, limit: Int) async throws -> PaginatedResult<Exchange>
    
    /// Get exchanges filtered by status
    func getFor(userId: UUID, status: ExchangeStatus) async throws -> [Exchange]
    
    // MARK: - Status Management
    
    /// Accept an exchange
    func accept(exchangeId: UUID) async throws -> Exchange
    
    /// Decline an exchange
    func decline(exchangeId: UUID, reason: String?) async throws -> Exchange
    
    /// Cancel an exchange
    func cancel(exchangeId: UUID, reason: String?) async throws -> Exchange
    
    /// Mark exchange as completed
    func complete(exchangeId: UUID) async throws -> Exchange
    
    /// Update exchange stage
    func updateStage(exchangeId: UUID, to stage: ExchangeStage) async throws -> Exchange
    
    // MARK: - Offer Management
    
    /// Add a new offer to an exchange
    func addOffer(exchangeId: UUID, offer: Offer) async throws -> Exchange
    
    /// Accept an offer
    func acceptOffer(exchangeId: UUID, offerId: UUID) async throws -> Exchange
    
    /// Decline an offer
    func declineOffer(exchangeId: UUID, offerId: UUID, reason: String?) async throws -> Exchange
    
    /// Get offer history for an exchange
    func getOffers(exchangeId: UUID) async throws -> [Offer]
    
    // MARK: - Messaging
    
    /// Add a message to an exchange
    func addMessage(exchangeId: UUID, message: ExchangeMessage) async throws -> Exchange
    
    /// Get messages for an exchange
    func getMessages(exchangeId: UUID) async throws -> [ExchangeMessage]
    
    /// Mark messages as read
    func markMessagesAsRead(exchangeId: UUID, userId: UUID) async throws
    
    /// Get unread message count for a user
    func getUnreadCount(userId: UUID) async throws -> Int
    
    // MARK: - Logistics
    
    /// Update shipping method
    func updateShipping(exchangeId: UUID, method: ShippingMethod, paidBy: ShippingPayer) async throws -> Exchange
    
    /// Add tracking information
    func addTracking(exchangeId: UUID, trackingInfo: TrackingInfo) async throws -> Exchange
    
    /// Update shipping address
    func updateShippingAddress(exchangeId: UUID, address: Address) async throws -> Exchange
    
    // MARK: - Reviews
    
    /// Add a review to a completed exchange
    func addReview(exchangeId: UUID, review: Review) async throws -> Exchange
    
    /// Get reviews for an exchange
    func getReviews(exchangeId: UUID) async throws -> [Review]
    
    /// Get reviews for a user (as seller)
    func getReviewsForSeller(userId: UUID, page: Int, limit: Int) async throws -> PaginatedResult<Review>
    
    /// Get reviews by a user (as buyer)
    func getReviewsByBuyer(userId: UUID, page: Int, limit: Int) async throws -> PaginatedResult<Review>
    
    /// Get average rating for a user
    func getAverageRating(userId: UUID) async throws -> Double
    
    // MARK: - Disputes
    
    /// Open a dispute
    func openDispute(exchangeId: UUID, dispute: Dispute) async throws -> Exchange
    
    /// Update dispute status
    func updateDispute(exchangeId: UUID, resolution: DisputeResolution) async throws -> Exchange
    
    /// Get disputes for a user
    func getDisputes(userId: UUID) async throws -> [Exchange]
    
    // MARK: - Statistics
    
    /// Get transaction statistics for a user
    func getStatistics(userId: UUID) async throws -> ExchangeStatistics
    
    /// Get total sales amount for a user
    func getTotalSales(userId: UUID) async throws -> Decimal
    
    /// Get total purchases amount for a user
    func getTotalPurchases(userId: UUID) async throws -> Decimal
    
    /// Get exchange count by status
    func getCountByStatus(userId: UUID) async throws -> [ExchangeStatus: Int]
    
    // MARK: - Active Exchanges
    
    /// Check if a user has any active exchanges for a garment
    func hasActiveExchange(garmentId: UUID) async throws -> Bool
    
    /// Get active exchange for a garment if any
    func getActiveExchangeFor(garmentId: UUID) async throws -> Exchange?
    
    /// Get exchanges requiring attention (pending, payment needed, etc.)
    func getRequiringAttention(userId: UUID) async throws -> [Exchange]
}

// MARK: - Statistics Type

public struct ExchangeStatistics: Codable, Hashable, Sendable {
    public var totalSales: Decimal
    public var totalPurchases: Decimal
    public var totalTrades: Int
    public var completedExchanges: Int
    public var cancelledExchanges: Int
    public var averageRating: Double
    public var ratingCount: Int
    public var totalFeesPaid: Decimal
    public var totalFeesSaved: Decimal
    public var itemsSold: Int
    public var itemsBought: Int
    public var itemsTraded: Int
    
    public init(
        totalSales: Decimal = 0,
        totalPurchases: Decimal = 0,
        totalTrades: Int = 0,
        completedExchanges: Int = 0,
        cancelledExchanges: Int = 0,
        averageRating: Double = 0,
        ratingCount: Int = 0,
        totalFeesPaid: Decimal = 0,
        totalFeesSaved: Decimal = 0,
        itemsSold: Int = 0,
        itemsBought: Int = 0,
        itemsTraded: Int = 0
    ) {
        self.totalSales = totalSales
        self.totalPurchases = totalPurchases
        self.totalTrades = totalTrades
        self.completedExchanges = completedExchanges
        self.cancelledExchanges = cancelledExchanges
        self.averageRating = averageRating
        self.ratingCount = ratingCount
        self.totalFeesPaid = totalFeesPaid
        self.totalFeesSaved = totalFeesSaved
        self.itemsSold = itemsSold
        self.itemsBought = itemsBought
        self.itemsTraded = itemsTraded
    }
}