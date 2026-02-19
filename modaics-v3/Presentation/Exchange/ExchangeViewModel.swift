import SwiftUI
import Combine

// MARK: - Exchange ViewModel
/// Connects the Exchange UI to the ExchangeGarmentUseCase
@MainActor
class ExchangeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var recentExchanges: [ExchangeActivity] = []
    @Published var userGarments: [Garment] = []
    @Published var availableGarments: [Garment] = []
    @Published var isLoading = false
    @Published var error: ExchangeError?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let exchangeUseCase: ExchangeGarmentUseCaseProtocol
    
    // MARK: - Initialization
    init(exchangeUseCase: ExchangeGarmentUseCaseProtocol = MockExchangeGarmentUseCase()) {
        self.exchangeUseCase = exchangeUseCase
    }
    
    // MARK: - Public Methods
    
    /// Load recent exchange activity for the current user
    func loadRecentExchanges() {
        isLoading = true
        
        Task {
            do {
                let exchanges = try await exchangeUseCase.getRecentActivity()
                self.recentExchanges = exchanges
                
                // Also load garments
                await loadGarments()
            } catch {
                self.error = .failedToLoadActivity
            }
            
            isLoading = false
        }
    }
    
    /// Load user's wardrobe for selling and trade options
    private func loadGarments() async {
        do {
            let garments = try await exchangeUseCase.getUserGarments()
            self.userGarments = garments
            
            let available = try await exchangeUseCase.getAvailableGarments()
            self.availableGarments = available
        } catch {
            self.error = .failedToLoadGarments
        }
    }
    
    /// Initiate a purchase transaction
    func initiatePurchase(garmentId: UUID, paymentMethod: PaymentMethod, handoffNote: String?) async throws -> ExchangeTransaction {
        isLoading = true
        defer { isLoading = false }
        
        return try await exchangeUseCase.purchaseGarment(
            garmentId: garmentId,
            paymentMethodId: paymentMethod.id,
            handoffNote: handoffNote
        )
    }
    
    /// List a garment for sale
    func listGarment(garmentId: UUID, price: Decimal, handoffNote: String?) async throws -> GarmentListing {
        isLoading = true
        defer { isLoading = false }
        
        return try await exchangeUseCase.createListing(
            garmentId: garmentId,
            price: price,
            handoffNote: handoffNote
        )
    }
    
    /// Propose a trade
    func proposeTrade(offeredGarmentId: UUID, requestedGarmentId: UUID, message: String?) async throws -> TradeOffer {
        isLoading = true
        defer { isLoading = false }
        
        return try await exchangeUseCase.proposeTrade(
            offeredGarmentId: offeredGarmentId,
            requestedGarmentId: requestedGarmentId,
            message: message
        )
    }
    
    /// Cancel an ongoing transaction
    func cancelTransaction(_ transactionId: UUID) async throws {
        try await exchangeUseCase.cancelTransaction(transactionId)
    }
    
    /// Refresh all exchange data
    func refresh() async {
        isLoading = true
        await loadGarments()
        do {
            let exchanges = try await exchangeUseCase.getRecentActivity()
            self.recentExchanges = exchanges
        } catch {
            self.error = .failedToLoadActivity
        }
        isLoading = false
    }
    
    // MARK: - Helper Methods
    
    func clearError() {
        error = nil
    }
}

// MARK: - ViewModel Exchange Error
enum ViewModelExchangeError: LocalizedError {
    case failedToLoadActivity
    case failedToLoadGarments
    case transactionFailed
    case insufficientFunds
    case garmentUnavailable
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .failedToLoadActivity:
            return "Couldn't load your recent activity"
        case .failedToLoadGarments:
            return "Couldn't load garments"
        case .transactionFailed:
            return "Transaction couldn't be completed"
        case .insufficientFunds:
            return "Payment could not be processed"
        case .garmentUnavailable:
            return "This item is no longer available"
        case .networkError:
            return "Please check your connection and try again"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .failedToLoadActivity, .failedToLoadGarments, .networkError:
            return "Pull down to refresh or try again later."
        case .transactionFailed, .insufficientFunds:
            return "Please check your payment details and try again."
        case .garmentUnavailable:
            return "This item may have been claimed by someone else. Browse for similar pieces."
        }
    }
}

// MARK: - ViewModel Use Case Protocol
protocol ExchangeViewModelUseCaseProtocol {
    func getRecentActivity() async throws -> [ExchangeActivity]
    func getUserGarments() async throws -> [Garment]
    func getAvailableGarments() async throws -> [Garment]
    func purchaseGarment(garmentId: UUID, paymentMethodId: String, handoffNote: String?) async throws -> ExchangeTransaction
    func createListing(garmentId: UUID, price: Decimal, handoffNote: String?) async throws -> GarmentListing
    func proposeTrade(offeredGarmentId: UUID, requestedGarmentId: UUID, message: String?) async throws -> TradeOffer
    func cancelTransaction(_ transactionId: UUID) async throws
}

// MARK: - Response Models
struct ExchangeTransaction: Identifiable {
    let id: UUID
    let garmentId: UUID
    let amount: Decimal
    let status: TransactionStatus
    let createdAt: Date
    let handoffNote: String?
}

struct GarmentListing: Identifiable {
    let id: UUID
    let garmentId: UUID
    let price: Decimal
    let status: ListingStatus
    let createdAt: Date
}

struct TradeOffer: Identifiable {
    let id: UUID
    let offeredGarmentId: UUID
    let requestedGarmentId: UUID
    let status: TradeStatus
    let message: String?
    let createdAt: Date
}

enum TransactionStatus {
    case pending, processing, completed, failed, cancelled
}

enum ListingStatus {
    case active, reserved, sold, expired
}

enum TradeStatus {
    case pending, accepted, declined, completed, cancelled
}

// MARK: - Mock Use Case
class MockExchangeGarmentUseCase: ExchangeGarmentUseCaseProtocol {
    func getRecentActivity() async throws -> [ExchangeActivity] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return [
            ExchangeActivity(
                garmentName: "Vintage Wool Coat",
                mode: .buy,
                status: .delivered,
                date: Date().addingTimeInterval(-86400)
            ),
            ExchangeActivity(
                garmentName: "Silk Blouse",
                mode: .sell,
                status: .confirmed,
                date: Date().addingTimeInterval(-172800)
            ),
            ExchangeActivity(
                garmentName: "Linen Trousers",
                mode: .trade,
                status: .pending,
                date: Date().addingTimeInterval(-259200)
            )
        ]
    }
    
    func getUserGarments() async throws -> [Garment] {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return [
            Garment(
                title: "Cashmere Sweater",
                description: "Soft cashmere",
                story: Story.sampleMinimal,
                condition: .excellent,
                category: .tops,
                size: Size(label: "M", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Denim Jacket",
                description: "Classic denim",
                story: Story.sampleMinimal,
                condition: .vintage,
                category: .outerwear,
                size: Size(label: "L", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Pleated Skirt",
                description: "Elegant skirt",
                story: Story.sampleMinimal,
                condition: .excellent,
                category: .bottoms,
                size: Size(label: "S", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Wool Trousers",
                description: "Warm trousers",
                story: Story.sampleMinimal,
                condition: .good,
                category: .bottoms,
                size: Size(label: "32", system: .us),
                ownerId: UUID()
            )
        ]
    }
    
    func getAvailableGarments() async throws -> [Garment] {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return [
            Garment(
                title: "Trench Coat",
                description: "Classic trench",
                story: Story.sampleMinimal,
                condition: .excellent,
                category: .outerwear,
                size: Size(label: "M", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Knit Cardigan",
                description: "Cozy knit",
                story: Story.sampleMinimal,
                condition: .veryGood,
                category: .tops,
                size: Size(label: "S", system: .us),
                ownerId: UUID()
            ),
            Garment(
                title: "Leather Boots",
                description: "Quality leather",
                story: Story.sampleMinimal,
                condition: .excellent,
                category: .shoes,
                size: Size(label: "42", system: .eu),
                ownerId: UUID()
            ),
            Garment(
                title: "Canvas Tote",
                description: "Sturdy tote",
                story: Story.sampleMinimal,
                condition: .good,
                category: .bags,
                size: Size(label: "One Size", system: .oneSize),
                ownerId: UUID()
            )
        ]
    }
    
    func purchaseGarment(garmentId: UUID, paymentMethodId: String, handoffNote: String?) async throws -> ExchangeTransaction {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return ExchangeTransaction(
            id: UUID(),
            garmentId: garmentId,
            amount: 150.00,
            status: .completed,
            createdAt: Date(),
            handoffNote: handoffNote
        )
    }
    
    func createListing(garmentId: UUID, price: Decimal, handoffNote: String?) async throws -> GarmentListing {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        return GarmentListing(
            id: UUID(),
            garmentId: garmentId,
            price: price,
            status: .active,
            createdAt: Date()
        )
    }
    
    func proposeTrade(offeredGarmentId: UUID, requestedGarmentId: UUID, message: String?) async throws -> TradeOffer {
        try await Task.sleep(nanoseconds: 600_000_000)
        
        return TradeOffer(
            id: UUID(),
            offeredGarmentId: offeredGarmentId,
            requestedGarmentId: requestedGarmentId,
            status: .pending,
            message: message,
            createdAt: Date()
        )
    }
    
    func cancelTransaction(_ transactionId: UUID) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }
}