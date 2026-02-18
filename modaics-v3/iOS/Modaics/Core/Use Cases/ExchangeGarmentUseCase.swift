import Foundation

// MARK: - ExchangeGarmentUseCase
/// Use case for initiating and managing garment exchanges
/// Handles buy, sell, and trade transactions
public protocol ExchangeGarmentUseCaseProtocol: Sendable {
    func execute(input: ExchangeInput) async throws -> ExchangeOutput
}

// MARK: - Input/Output Types

public struct ExchangeInput: Sendable {
    public let action: ExchangeAction
    public let userId: UUID
    
    public init(action: ExchangeAction, userId: UUID) {
        self.action = action
        self.userId = userId
    }
}

public enum ExchangeAction: Sendable {
    case initiatePurchase(InitiatePurchaseInput)
    case initiateTrade(InitiateTradeInput)
    case makeOffer(MakeOfferInput)
    case acceptOffer(offerId: UUID, exchangeId: UUID)
    case declineOffer(offerId: UUID, exchangeId: UUID, reason: String?)
    case counterOffer(offerId: UUID, exchangeId: UUID, counterOffer: MakeOfferInput)
    case sendMessage(exchangeId: UUID, message: String)
    case acceptExchange(exchangeId: UUID)
    case declineExchange(exchangeId: UUID, reason: String?)
    case cancelExchange(exchangeId: UUID, reason: String?)
    case markAsPaid(exchangeId: UUID)
    case markAsShipped(exchangeId: UUID, trackingInfo: TrackingInfo?)
    case markAsReceived(exchangeId: UUID)
    case addReview(exchangeId: UUID, review: ReviewInput)
    case openDispute(exchangeId: UUID, reason: DisputeReason, description: String)
    case updateShippingAddress(exchangeId: UUID, address: Address)
}

public struct InitiatePurchaseInput: Sendable {
    public let garmentId: UUID
    public let offeredPrice: Decimal?
    public let message: String?
    
    public init(garmentId: UUID, offeredPrice: Decimal? = nil, message: String? = nil) {
        self.garmentId = garmentId
        self.offeredPrice = offeredPrice
        self.message = message
    }
}

public struct InitiateTradeInput: Sendable {
    public let theirGarmentId: UUID
    public let yourGarmentIds: [UUID]
    public let cashDifference: Decimal?
    public let message: String?
    
    public init(
        theirGarmentId: UUID,
        yourGarmentIds: [UUID],
        cashDifference: Decimal? = nil,
        message: String? = nil
    ) {
        self.theirGarmentId = theirGarmentId
        self.yourGarmentIds = yourGarmentIds
        self.cashDifference = cashDifference
        self.message = message
    }
}

public struct MakeOfferInput: Sendable {
    public let amount: Decimal?
    public let offeredGarmentIds: [UUID]
    public let message: String
    
    public init(
        amount: Decimal? = nil,
        offeredGarmentIds: [UUID] = [],
        message: String = ""
    ) {
        self.amount = amount
        self.offeredGarmentIds = offeredGarmentIds
        self.message = message
    }
}

public struct ReviewInput: Sendable {
    public let rating: Int
    public let comment: String
    public let tags: [ReviewTag]
    
    public init(rating: Int, comment: String, tags: [ReviewTag] = []) {
        self.rating = rating
        self.comment = comment
        self.tags = tags
    }
}

public struct ExchangeOutput: Sendable {
    public let exchange: Exchange
    public let garment: Garment?
    public let otherParty: User?
    public let status: ExchangeStatus
    public let nextAction: NextAction?
    public let message: String?
    
    public init(
        exchange: Exchange,
        garment: Garment? = nil,
        otherParty: User? = nil,
        status: ExchangeStatus,
        nextAction: NextAction? = nil,
        message: String? = nil
    ) {
        self.exchange = exchange
        self.garment = garment
        self.otherParty = otherParty
        self.status = status
        self.nextAction = nextAction
        self.message = message
    }
}

public struct NextAction: Sendable {
    public let actor: UUID
    public let actionType: NextActionType
    public let description: String
    public let deadline: Date?
    
    public init(
        actor: UUID,
        actionType: NextActionType,
        description: String,
        deadline: Date? = nil
    ) {
        self.actor = actor
        self.actionType = actionType
        self.description = description
        self.deadline = deadline
    }
}

public enum NextActionType: Sendable {
    case awaitResponse
    case makePayment
    case shipItem
    case confirmReceipt
    case leaveReview
    case respondToDispute
    case none
}

// MARK: - Implementation

public final class ExchangeGarmentUseCase: ExchangeGarmentUseCaseProtocol {
    private let exchangeRepository: ExchangeRepositoryProtocol
    private let garmentRepository: GarmentRepositoryProtocol
    private let pricingService: PricingGuidanceServiceProtocol
    
    public init(
        exchangeRepository: ExchangeRepositoryProtocol,
        garmentRepository: GarmentRepositoryProtocol,
        pricingService: PricingGuidanceServiceProtocol
    ) {
        self.exchangeRepository = exchangeRepository
        self.garmentRepository = garmentRepository
        self.pricingService = pricingService
    }
    
    public func execute(input: ExchangeInput) async throws -> ExchangeOutput {
        switch input.action {
        case .initiatePurchase(let purchaseInput):
            return try await initiatePurchase(input: purchaseInput, userId: input.userId)
            
        case .initiateTrade(let tradeInput):
            return try await initiateTrade(input: tradeInput, userId: input.userId)
            
        case .makeOffer(let offerInput):
            return try await makeOffer(offerInput, exchangeId: offerInput.exchangeId, userId: input.userId)
            
        case .acceptOffer(let offerId, let exchangeId):
            return try await acceptOffer(offerId: offerId, exchangeId: exchangeId, userId: input.userId)
            
        case .declineOffer(let offerId, let exchangeId, let reason):
            return try await declineOffer(offerId: offerId, exchangeId: exchangeId, reason: reason, userId: input.userId)
            
        case .counterOffer(let offerId, let exchangeId, let counterOffer):
            return try await counterOffer(offerId: offerId, exchangeId: exchangeId, counterOffer: counterOffer, userId: input.userId)
            
        case .sendMessage(let exchangeId, let message):
            return try await sendMessage(exchangeId: exchangeId, message: message, userId: input.userId)
            
        case .acceptExchange(let exchangeId):
            return try await acceptExchange(exchangeId: exchangeId, userId: input.userId)
            
        case .declineExchange(let exchangeId, let reason):
            return try await declineExchange(exchangeId: exchangeId, reason: reason, userId: input.userId)
            
        case .cancelExchange(let exchangeId, let reason):
            return try await cancelExchange(exchangeId: exchangeId, reason: reason, userId: input.userId)
            
        case .markAsPaid(let exchangeId):
            return try await markAsPaid(exchangeId: exchangeId, userId: input.userId)
            
        case .markAsShipped(let exchangeId, let trackingInfo):
            return try await markAsShipped(exchangeId: exchangeId, trackingInfo: trackingInfo, userId: input.userId)
            
        case .markAsReceived(let exchangeId):
            return try await markAsReceived(exchangeId: exchangeId, userId: input.userId)
            
        case .addReview(let exchangeId, let reviewInput):
            return try await addReview(exchangeId: exchangeId, reviewInput: reviewInput, userId: input.userId)
            
        case .openDispute(let exchangeId, let reason, let description):
            return try await openDispute(exchangeId: exchangeId, reason: reason, description: description, userId: input.userId)
            
        case .updateShippingAddress(let exchangeId, let address):
            return try await updateShippingAddress(exchangeId: exchangeId, address: address, userId: input.userId)
        }
    }
    
    // MARK: - Private Methods
    
    private func initiatePurchase(input: InitiatePurchaseInput, userId: UUID) async throws -> ExchangeOutput {
        // Get the garment
        let garment = try await garmentRepository.get(by: input.garmentId)
        
        // Validate it's listed for sale
        guard garment.isListed, garment.exchangeType == .sell || garment.exchangeType == .sellOrTrade else {
            throw ExchangeError.garmentNotAvailable
        }
        
        // Can't buy your own item
        guard garment.ownerId != userId else {
            throw ExchangeError.cannotExchangeWithSelf
        }
        
        // Check if already has active exchange
        if try await exchangeRepository.hasActiveExchange(garmentId: garment.id) {
            throw ExchangeError.garmentAlreadyInExchange
        }
        
        // Validate price if offering different amount
        if let offeredPrice = input.offeredPrice {
            let guidance = try await pricingService.getPricingGuidance(for: garment)
            if offeredPrice < guidance.suggestedMinimumPrice {
                throw ExchangeError.offerTooLow(minimum: guidance.suggestedMinimumPrice)
            }
        }
        
        // Create exchange
        let exchange = Exchange(
            initiatorId: userId,
            recipientId: garment.ownerId,
            garmentId: garment.id,
            agreedPrice: input.offeredPrice ?? garment.listingPrice,
            currency: "USD",
            type: .sell,
            status: .pending,
            stage: .inquiry
        )
        
        let createdExchange = try await exchangeRepository.create(exchange)
        
        // Add initial message if provided
        if let message = input.message, !message.isEmpty {
            let exchangeMessage = ExchangeMessage(senderId: userId, content: message)
            _ = try await exchangeRepository.addMessage(exchangeId: createdExchange.id, message: exchangeMessage)
        }
        
        let nextAction = NextAction(
            actor: garment.ownerId,
            actionType: .awaitResponse,
            description: "Waiting for seller to respond to your purchase request"
        )
        
        return ExchangeOutput(
            exchange: createdExchange,
            garment: garment,
            status: .pending,
            nextAction: nextAction,
            message: "Purchase request sent successfully"
        )
    }
    
    private func initiateTrade(input: InitiateTradeInput, userId: UUID) async throws -> ExchangeOutput {
        // Get the target garment
        let theirGarment = try await garmentRepository.get(by: input.theirGarmentId)
        
        // Validate it's listed for trade
        guard theirGarment.isListed, theirGarment.exchangeType == .trade || theirGarment.exchangeType == .sellOrTrade else {
            throw ExchangeError.garmentNotAvailable
        }
        
        // Can't trade with yourself
        guard theirGarment.ownerId != userId else {
            throw ExchangeError.cannotExchangeWithSelf
        }
        
        // Verify user owns the offered garments
        for garmentId in input.yourGarmentIds {
            let garment = try await garmentRepository.get(by: garmentId)
            guard garment.ownerId == userId else {
                throw ExchangeError.unauthorized
            }
        }
        
        // Create exchange
        let exchange = Exchange(
            initiatorId: userId,
            recipientId: theirGarment.ownerId,
            garmentId: theirGarment.id,
            offeredGarmentIds: input.yourGarmentIds,
            agreedPrice: input.cashDifference,
            currency: "USD",
            type: .trade,
            status: .pending,
            stage: .inquiry
        )
        
        let createdExchange = try await exchangeRepository.create(exchange)
        
        // Add initial message if provided
        if let message = input.message, !message.isEmpty {
            let exchangeMessage = ExchangeMessage(senderId: userId, content: message)
            _ = try await exchangeRepository.addMessage(exchangeId: createdExchange.id, message: exchangeMessage)
        }
        
        return ExchangeOutput(
            exchange: createdExchange,
            garment: theirGarment,
            status: .pending,
            nextAction: NextAction(
                actor: theirGarment.ownerId,
                actionType: .awaitResponse,
                description: "Waiting for trade partner to respond"
            ),
            message: "Trade request sent successfully"
        )
    }
    
    private func makeOffer(_ offerInput: MakeOfferInput, exchangeId: UUID, userId: UUID) async throws -> ExchangeOutput {
        let offer = Offer(
            amount: offerInput.amount,
            offeredGarmentIds: offerInput.offeredGarmentIds,
            message: offerInput.message,
            proposedBy: userId
        )
        
        let exchange = try await exchangeRepository.addOffer(exchangeId: exchangeId, offer: offer)
        
        let nextActor = exchange.initiatorId == userId ? exchange.recipientId : exchange.initiatorId
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            nextAction: NextAction(
                actor: nextActor,
                actionType: .awaitResponse,
                description: "Waiting for response to your offer"
            ),
            message: "Offer sent successfully"
        )
    }
    
    private func acceptOffer(offerId: UUID, exchangeId: UUID, userId: UUID) async throws -> ExchangeOutput {
        let exchange = try await exchangeRepository.acceptOffer(exchangeId: exchangeId, offerId: offerId)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            nextAction: determineNextAction(for: exchange),
            message: "Offer accepted!"
        )
    }
    
    private func declineOffer(offerId: UUID, exchangeId: UUID, reason: String?, userId: UUID) async throws -> ExchangeOutput {
        let exchange = try await exchangeRepository.declineOffer(exchangeId: exchangeId, offerId: offerId, reason: reason)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            message: "Offer declined"
        )
    }
    
    private func counterOffer(offerId: UUID, exchangeId: UUID, counterOffer: MakeOfferInput, userId: UUID) async throws -> ExchangeOutput {
        // First decline the original offer
        _ = try await exchangeRepository.declineOffer(exchangeId: exchangeId, offerId: offerId, reason: "Counter offer made")
        
        // Then create new offer
        let offer = Offer(
            amount: counterOffer.amount,
            offeredGarmentIds: counterOffer.offeredGarmentIds,
            message: counterOffer.message,
            proposedBy: userId
        )
        
        let exchange = try await exchangeRepository.addOffer(exchangeId: exchangeId, offer: offer)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            message: "Counter offer sent"
        )
    }
    
    private func sendMessage(exchangeId: UUID, message: String, userId: UUID) async throws -> ExchangeOutput {
        let exchangeMessage = ExchangeMessage(senderId: userId, content: message)
        let exchange = try await exchangeRepository.addMessage(exchangeId: exchangeId, message: exchangeMessage)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            message: "Message sent"
        )
    }
    
    private func acceptExchange(exchangeId: UUID, userId: UUID) async throws -> ExchangeOutput {
        let exchange = try await exchangeRepository.accept(exchangeId: exchangeId)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            nextAction: determineNextAction(for: exchange),
            message: "Exchange accepted!"
        )
    }
    
    private func declineExchange(exchangeId: UUID, reason: String?, userId: UUID) async throws -> ExchangeOutput {
        let exchange = try await exchangeRepository.decline(exchangeId: exchangeId, reason: reason)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            message: "Exchange declined"
        )
    }
    
    private func cancelExchange(exchangeId: UUID, reason: String?, userId: UUID) async throws -> ExchangeOutput {
        let exchange = try await exchangeRepository.cancel(exchangeId: exchangeId, reason: reason)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            message: "Exchange cancelled"
        )
    }
    
    private func markAsPaid(exchangeId: UUID, userId: UUID) async throws -> ExchangeOutput {
        let exchange = try await exchangeRepository.updateStage(exchangeId: exchangeId, to: .paymentReceived)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            nextAction: determineNextAction(for: exchange),
            message: "Payment confirmed"
        )
    }
    
    private func markAsShipped(exchangeId: UUID, trackingInfo: TrackingInfo?, userId: UUID) async throws -> ExchangeOutput {
        var exchange = try await exchangeRepository.updateStage(exchangeId: exchangeId, to: .shipped)
        
        if let tracking = trackingInfo {
            exchange = try await exchangeRepository.addTracking(exchangeId: exchangeId, trackingInfo: tracking)
        }
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            nextAction: determineNextAction(for: exchange),
            message: "Item marked as shipped"
        )
    }
    
    private func markAsReceived(exchangeId: UUID, userId: UUID) async throws -> ExchangeOutput {
        let exchange = try await exchangeRepository.updateStage(exchangeId: exchangeId, to: .delivered)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            nextAction: determineNextAction(for: exchange),
            message: "Item received! Please leave a review"
        )
    }
    
    private func addReview(exchangeId: UUID, reviewInput: ReviewInput, userId: UUID) async throws -> ExchangeOutput {
        let review = Review(
            authorId: userId,
            rating: reviewInput.rating,
            comment: reviewInput.comment,
            exchangeId: exchangeId,
            tags: reviewInput.tags
        )
        
        let exchange = try await exchangeRepository.addReview(exchangeId: exchangeId, review: review)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            message: "Review added successfully"
        )
    }
    
    private func openDispute(exchangeId: UUID, reason: DisputeReason, description: String, userId: UUID) async throws -> ExchangeOutput {
        let dispute = Dispute(
            reason: reason,
            description: description,
            openedBy: userId
        )
        
        let exchange = try await exchangeRepository.openDispute(exchangeId: exchangeId, dispute: dispute)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            nextAction: NextAction(
                actor: userId,
                actionType: .respondToDispute,
                description: "Our team will review your dispute"
            ),
            message: "Dispute opened. Our team will review and respond within 48 hours."
        )
    }
    
    private func updateShippingAddress(exchangeId: UUID, address: Address, userId: UUID) async throws -> ExchangeOutput {
        let exchange = try await exchangeRepository.updateShippingAddress(exchangeId: exchangeId, address: address)
        
        return ExchangeOutput(
            exchange: exchange,
            status: exchange.status,
            message: "Shipping address updated"
        )
    }
    
    // MARK: - Helpers
    
    private func determineNextAction(for exchange: Exchange) -> NextAction? {
        switch exchange.stage {
        case .inquiry, .negotiating:
            return NextAction(
                actor: exchange.recipientId,
                actionType: .awaitResponse,
                description: "Awaiting response"
            )
        case .accepted, .paymentPending:
            return NextAction(
                actor: exchange.initiatorId,
                actionType: .makePayment,
                description: "Payment required"
            )
        case .paymentReceived, .preparing:
            return NextAction(
                actor: exchange.recipientId,
                actionType: .shipItem,
                description: "Ship item to buyer"
            )
        case .shipped, .inTransit:
            return NextAction(
                actor: exchange.initiatorId,
                actionType: .confirmReceipt,
                description: "Confirm receipt when item arrives"
            )
        case .delivered:
            return NextAction(
                actor: exchange.initiatorId,
                actionType: .leaveReview,
                description: "Leave a review"
            )
        case .reviewPending, .completed:
            return nil
        }
    }
}

// MARK: - Extensions

extension MakeOfferInput {
    fileprivate var exchangeId: UUID { UUID() } // This would be passed differently in practice
}

public enum ExchangeError: Error {
    case garmentNotAvailable
    case garmentNotFound
    case garmentAlreadyInExchange
    case cannotExchangeWithSelf
    case unauthorized
    case offerTooLow(minimum: Decimal)
    case invalidExchangeState
    case exchangeNotFound
    case userNotFound
    case paymentFailed
    case shippingRequired
    case reviewNotAllowed
    case disputeNotAllowed
}