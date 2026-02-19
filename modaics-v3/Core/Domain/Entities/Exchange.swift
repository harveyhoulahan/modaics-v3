import Foundation

// MARK: - Exchange
/// Represents a buy, sell, or trade transaction between users
/// The core transactional unit of the Modaics platform
public struct Exchange: Identifiable, Codable, Hashable {
    public let id: UUID
    
    // MARK: - Participants
    
    /// User initiating the exchange (buyer or trade proposer)
    public var initiatorId: UUID
    
    /// User receiving the exchange request (seller)
    public var recipientId: UUID
    
    // MARK: - Items
    
    /// The main garment being exchanged
    public var garmentId: UUID
    
    /// For trades: what the initiator is offering in return
    public var offeredGarmentIds: [UUID]
    
    /// For cash sales: the agreed price
    public var agreedPrice: Decimal?
    
    /// Currency for the transaction
    public var currency: String
    
    // MARK: - Exchange Details
    
    /// Type of exchange
    public var type: ExchangeType
    
    /// Current status of the exchange
    public var status: ExchangeStatus
    
    /// Stage in the exchange lifecycle
    public var stage: ExchangeStage
    
    /// Any special conditions or notes
    public var conditions: String?
    
    // MARK: - Negotiation
    
    /// Counter offers made
    public var offers: [Offer]
    
    /// Current active offer
    public var currentOfferId: UUID?
    
    /// Negotiation history messages
    public var messages: [ExchangeMessage]
    
    // MARK: - Logistics
    
    /// Shipping method selected
    public var shippingMethod: ShippingMethod?
    
    /// Tracking information
    public var trackingInfo: TrackingInfo?
    
    /// Shipping address
    public var shippingAddress: Address?
    
    /// Who pays for shipping
    public var shippingPaidBy: ShippingPayer
    
    /// Estimated delivery date
    public var estimatedDelivery: Date?
    
    // MARK: - Timeline
    
    /// When the exchange was initiated
    public var initiatedAt: Date
    
    /// When it was accepted/completed
    public var completedAt: Date?
    
    /// When payment was made
    public var paidAt: Date?
    
    /// When item was shipped
    public var shippedAt: Date?
    
    /// When item was received
    public var receivedAt: Date?
    
    /// Last activity timestamp
    public var updatedAt: Date
    
    // MARK: - Review & Resolution
    
    /// Ratings left by participants
    public var reviews: [Review]
    
    /// Dispute status if any
    public var dispute: Dispute?
    
    /// Cancellation reason if cancelled
    public var cancellationReason: String?
    
    /// Platform fee charged
    public var platformFee: Decimal
    
    /// Total amount paid including fees
    public var totalAmount: Decimal?
    
    public init(
        id: UUID = UUID(),
        initiatorId: UUID,
        recipientId: UUID,
        garmentId: UUID,
        offeredGarmentIds: [UUID] = [],
        agreedPrice: Decimal? = nil,
        currency: String = "USD",
        type: ExchangeType,
        status: ExchangeStatus = .pending,
        stage: ExchangeStage = .inquiry,
        conditions: String? = nil,
        offers: [Offer] = [],
        currentOfferId: UUID? = nil,
        messages: [ExchangeMessage] = [],
        shippingMethod: ShippingMethod? = nil,
        trackingInfo: TrackingInfo? = nil,
        shippingAddress: Address? = nil,
        shippingPaidBy: ShippingPayer = .buyer,
        estimatedDelivery: Date? = nil,
        initiatedAt: Date = Date(),
        completedAt: Date? = nil,
        paidAt: Date? = nil,
        shippedAt: Date? = nil,
        receivedAt: Date? = nil,
        updatedAt: Date = Date(),
        reviews: [Review] = [],
        dispute: Dispute? = nil,
        cancellationReason: String? = nil,
        platformFee: Decimal = 0,
        totalAmount: Decimal? = nil
    ) {
        self.id = id
        self.initiatorId = initiatorId
        self.recipientId = recipientId
        self.garmentId = garmentId
        self.offeredGarmentIds = offeredGarmentIds
        self.agreedPrice = agreedPrice
        self.currency = currency
        self.type = type
        self.status = status
        self.stage = stage
        self.conditions = conditions
        self.offers = offers
        self.currentOfferId = currentOfferId
        self.messages = messages
        self.shippingMethod = shippingMethod
        self.trackingInfo = trackingInfo
        self.shippingAddress = shippingAddress
        self.shippingPaidBy = shippingPaidBy
        self.estimatedDelivery = estimatedDelivery
        self.initiatedAt = initiatedAt
        self.completedAt = completedAt
        self.paidAt = paidAt
        self.shippedAt = shippedAt
        self.receivedAt = receivedAt
        self.updatedAt = updatedAt
        self.reviews = reviews
        self.dispute = dispute
        self.cancellationReason = cancellationReason
        self.platformFee = platformFee
        self.totalAmount = totalAmount
    }
}

// MARK: - Supporting Types

public enum ExchangeStatus: String, Codable, CaseIterable, Hashable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case cancelled = "cancelled"
    case completed = "completed"
    case disputed = "disputed"
    case expired = "expired"
}

public enum ExchangeStage: String, Codable, CaseIterable, Hashable {
    case inquiry = "inquiry"
    case negotiating = "negotiating"
    case accepted = "accepted"
    case paymentPending = "payment_pending"
    case paymentReceived = "payment_received"
    case preparing = "preparing"
    case shipped = "shipped"
    case inTransit = "in_transit"
    case delivered = "delivered"
    case reviewPending = "review_pending"
    case completed = "completed"
}

public struct Offer: Identifiable, Codable, Hashable {
    public let id: UUID
    public var amount: Decimal?
    public var offeredGarmentIds: [UUID]
    public var message: String
    public var proposedBy: UUID
    public var proposedAt: Date
    public var status: OfferStatus
    public var expiresAt: Date?
    
    public init(
        id: UUID = UUID(),
        amount: Decimal? = nil,
        offeredGarmentIds: [UUID] = [],
        message: String = "",
        proposedBy: UUID,
        proposedAt: Date = Date(),
        status: OfferStatus = .pending,
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.amount = amount
        self.offeredGarmentIds = offeredGarmentIds
        self.message = message
        self.proposedBy = proposedBy
        self.proposedAt = proposedAt
        self.status = status
        self.expiresAt = expiresAt
    }
}

public enum OfferStatus: String, Codable, CaseIterable, Hashable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case countered = "countered"
    case expired = "expired"
}

public struct ExchangeMessage: Identifiable, Codable, Hashable {
    public let id: UUID
    public var senderId: UUID
    public var content: String
    public var sentAt: Date
    public var isRead: Bool
    public var attachments: [MessageAttachment]
    
    public init(
        id: UUID = UUID(),
        senderId: UUID,
        content: String,
        sentAt: Date = Date(),
        isRead: Bool = false,
        attachments: [MessageAttachment] = []
    ) {
        self.id = id
        self.senderId = senderId
        self.content = content
        self.sentAt = sentAt
        self.isRead = isRead
        self.attachments = attachments
    }
}

public struct MessageAttachment: Identifiable, Codable, Hashable {
    public let id: UUID
    public var type: AttachmentType
    public var url: URL
    public var thumbnailURL: URL?
    
    public init(id: UUID = UUID(), type: AttachmentType, url: URL, thumbnailURL: URL? = nil) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnailURL = thumbnailURL
    }
}

public enum AttachmentType: String, Codable, CaseIterable, Hashable {
    case image = "image"
    case video = "video"
    case document = "document"
}

public struct ShippingMethod: Codable, Hashable, Identifiable {
    public let id: UUID
    public var name: String
    public var carrier: String
    public var estimatedDays: ClosedRange<Int>
    public var cost: Decimal
    
    public init(id: UUID = UUID(), name: String, carrier: String, estimatedDays: ClosedRange<Int>, cost: Decimal) {
        self.id = id
        self.name = name
        self.carrier = carrier
        self.estimatedDays = estimatedDays
        self.cost = cost
    }
}

public struct TrackingInfo: Codable, Hashable, Identifiable {
    public let id: UUID
    public var carrier: String
    public var trackingNumber: String
    public var url: URL?
    public var status: String?
    public var lastUpdate: Date?
    public var events: [TrackingEvent]
    
    public init(
        id: UUID = UUID(),
        carrier: String,
        trackingNumber: String,
        url: URL? = nil,
        status: String? = nil,
        lastUpdate: Date? = nil,
        events: [TrackingEvent] = []
    ) {
        self.id = id
        self.carrier = carrier
        self.trackingNumber = trackingNumber
        self.url = url
        self.status = status
        self.lastUpdate = lastUpdate
        self.events = events
    }
}

public struct TrackingEvent: Codable, Hashable, Identifiable {
    public let id: UUID
    public var description: String
    public var location: String?
    public var timestamp: Date
    public var status: String
    
    public init(id: UUID = UUID(), description: String, location: String? = nil, timestamp: Date, status: String) {
        self.id = id
        self.description = description
        self.location = location
        self.timestamp = timestamp
        self.status = status
    }
}

public struct Address: Codable, Hashable, Identifiable {
    public let id: UUID
    public var name: String
    public var line1: String
    public var line2: String?
    public var city: String
    public var state: String?
    public var postalCode: String
    public var country: String
    public var phone: String?
    public var isDefault: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        line1: String,
        line2: String? = nil,
        city: String,
        state: String? = nil,
        postalCode: String,
        country: String,
        phone: String? = nil,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.phone = phone
        self.isDefault = isDefault
    }
}

public enum ShippingPayer: String, Codable, CaseIterable, Hashable {
    case seller = "seller"
    case buyer = "buyer"
    case split = "split"
}

public struct Review: Identifiable, Codable, Hashable {
    public let id: UUID
    public var authorId: UUID
    public var rating: Int // 1-5
    public var comment: String
    public var createdAt: Date
    public var exchangeId: UUID
    public var tags: [ReviewTag]
    
    public init(
        id: UUID = UUID(),
        authorId: UUID,
        rating: Int,
        comment: String,
        createdAt: Date = Date(),
        exchangeId: UUID,
        tags: [ReviewTag] = []
    ) {
        self.id = id
        self.authorId = authorId
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
        self.exchangeId = exchangeId
        self.tags = tags
    }
}

public enum ReviewTag: String, Codable, CaseIterable, Hashable {
    case accurateDescription = "accurate_description"
    case fastShipping = "fast_shipping"
    case greatCommunication = "great_communication"
    case wellPackaged = "well_packaged"
    case itemAsDescribed = "item_as_described"
    case fairPricing = "fair_pricing"
    case wouldRecommend = "would_recommend"
}

public struct Dispute: Codable, Hashable, Identifiable {
    public let id: UUID
    public var reason: DisputeReason
    public var description: String
    public var openedAt: Date
    public var resolvedAt: Date?
    public var resolution: DisputeResolution?
    public var openedBy: UUID
    
    public init(
        id: UUID = UUID(),
        reason: DisputeReason,
        description: String,
        openedAt: Date = Date(),
        resolvedAt: Date? = nil,
        resolution: DisputeResolution? = nil,
        openedBy: UUID
    ) {
        self.id = id
        self.reason = reason
        self.description = description
        self.openedAt = openedAt
        self.resolvedAt = resolvedAt
        self.resolution = resolution
        self.openedBy = openedBy
    }
}

public enum DisputeReason: String, Codable, CaseIterable, Hashable {
    case itemNotAsDescribed = "item_not_as_described"
    case itemNotReceived = "item_not_received"
    case wrongItem = "wrong_item"
    case damagedItem = "damaged_item"
    case counterfeit = "counterfeit"
    case other = "other"
}

public enum DisputeResolution: String, Codable, CaseIterable, Hashable {
    case refundIssued = "refund_issued"
    case partialRefund = "partial_refund"
    case returnRequested = "return_requested"
    case resolvedInFavorOfSeller = "resolved_seller"
    case resolvedInFavorOfBuyer = "resolved_buyer"
}

// MARK: - Sample Data

public extension Exchange {
    static let sampleSale = Exchange(
        initiatorId: UUID(),
        recipientId: UUID(),
        garmentId: UUID(),
        agreedPrice: 250.00,
        currency: "USD",
        type: .sell,
        status: .completed,
        stage: .completed,
        initiatedAt: Date().addingTimeInterval(-86400 * 5),
        completedAt: Date(),
        platformFee: 12.50,
        totalAmount: 262.50
    )
    
    static let sampleTrade = Exchange(
        initiatorId: UUID(),
        recipientId: UUID(),
        garmentId: UUID(),
        offeredGarmentIds: [UUID()],
        currency: "USD",
        type: .trade,
        status: .accepted,
        stage: .preparing,
        messages: [
            ExchangeMessage(
                senderId: UUID(),
                content: "Hi! I'd love to trade for your leather jacket. Would you be interested in my vintage silk blouse?"
            )
        ],
        shippingMethod: ShippingMethod(name: "Standard", carrier: "UPS", estimatedDays: 3...7, cost: 15.00),
        shippingPaidBy: .split
    )
}