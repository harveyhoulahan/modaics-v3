import Foundation

// MARK: - ModaicsExchange
/// Represents a buy, sell, or trade transaction between users
public struct ModaicsExchange: Identifiable, Codable, Hashable {
    public let id: UUID
    
    public var initiatorId: UUID
    public var recipientId: UUID
    public var garmentId: UUID
    public var offeredGarmentIds: [UUID]
    public var agreedPrice: Decimal?
    public var currency: String
    
    public var type: ModaicsExchangeType
    public var status: ModaicsExchangeStatus
    public var stage: ModaicsExchangeStage
    public var conditions: String?
    
    public var offers: [ModaicsOffer]
    public var currentOfferId: UUID?
    public var messages: [ModaicsExchangeMessage]
    
    public var shippingMethod: ModaicsShippingMethod?
    public var trackingInfo: ModaicsTrackingInfo?
    public var shippingAddress: ModaicsAddress?
    public var shippingPaidBy: ModaicsShippingPayer
    public var estimatedDelivery: Date?
    
    public var initiatedAt: Date
    public var completedAt: Date?
    public var paidAt: Date?
    public var shippedAt: Date?
    public var receivedAt: Date?
    public var updatedAt: Date
    
    public var reviews: [ModaicsReview]
    public var dispute: ModaicsDispute?
    public var cancellationReason: String?
    public var platformFee: Decimal
    public var totalAmount: Decimal?
    
    public init(
        id: UUID = UUID(),
        initiatorId: UUID,
        recipientId: UUID,
        garmentId: UUID,
        offeredGarmentIds: [UUID] = [],
        agreedPrice: Decimal? = nil,
        currency: String = "USD",
        type: ModaicsExchangeType,
        status: ModaicsExchangeStatus = .pending,
        stage: ModaicsExchangeStage = .inquiry,
        conditions: String? = nil,
        offers: [ModaicsOffer] = [],
        currentOfferId: UUID? = nil,
        messages: [ModaicsExchangeMessage] = [],
        shippingMethod: ModaicsShippingMethod? = nil,
        trackingInfo: ModaicsTrackingInfo? = nil,
        shippingAddress: ModaicsAddress? = nil,
        shippingPaidBy: ModaicsShippingPayer = .buyer,
        estimatedDelivery: Date? = nil,
        initiatedAt: Date = Date(),
        completedAt: Date? = nil,
        paidAt: Date? = nil,
        shippedAt: Date? = nil,
        receivedAt: Date? = nil,
        updatedAt: Date = Date(),
        reviews: [ModaicsReview] = [],
        dispute: ModaicsDispute? = nil,
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

public enum ModaicsExchangeStatus: String, Codable, CaseIterable, Hashable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case cancelled = "cancelled"
    case completed = "completed"
    case disputed = "disputed"
    case expired = "expired"
}

public enum ModaicsExchangeStage: String, Codable, CaseIterable, Hashable {
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

public struct ModaicsOffer: Identifiable, Codable, Hashable {
    public let id: UUID
    public var amount: Decimal?
    public var offeredGarmentIds: [UUID]
    public var message: String
    public var proposedBy: UUID
    public var proposedAt: Date
    public var status: ModaicsOfferStatus
    public var expiresAt: Date?
    
    public init(
        id: UUID = UUID(),
        amount: Decimal? = nil,
        offeredGarmentIds: [UUID] = [],
        message: String = "",
        proposedBy: UUID,
        proposedAt: Date = Date(),
        status: ModaicsOfferStatus = .pending,
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

public enum ModaicsOfferStatus: String, Codable, CaseIterable, Hashable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case countered = "countered"
    case expired = "expired"
}

public struct ModaicsExchangeMessage: Identifiable, Codable, Hashable {
    public let id: UUID
    public var senderId: UUID
    public var content: String
    public var sentAt: Date
    public var isRead: Bool
    public var attachments: [ModaicsMessageAttachment]
    
    public init(
        id: UUID = UUID(),
        senderId: UUID,
        content: String,
        sentAt: Date = Date(),
        isRead: Bool = false,
        attachments: [ModaicsMessageAttachment] = []
    ) {
        self.id = id
        self.senderId = senderId
        self.content = content
        self.sentAt = sentAt
        self.isRead = isRead
        self.attachments = attachments
    }
}

public struct ModaicsMessageAttachment: Identifiable, Codable, Hashable {
    public let id: UUID
    public var type: ModaicsAttachmentType
    public var url: URL
    public var thumbnailURL: URL?
    
    public init(id: UUID = UUID(), type: ModaicsAttachmentType, url: URL, thumbnailURL: URL? = nil) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnailURL = thumbnailURL
    }
}

public enum ModaicsAttachmentType: String, Codable, CaseIterable, Hashable {
    case image = "image"
    case video = "video"
    case document = "document"
}

public struct ModaicsShippingMethod: Codable, Hashable, Identifiable {
    public let id: UUID
    public var name: String
    public var carrier: String
    public var estimatedDaysMin: Int
    public var estimatedDaysMax: Int
    public var cost: Decimal
    
    public init(id: UUID = UUID(), name: String, carrier: String, estimatedDaysMin: Int, estimatedDaysMax: Int, cost: Decimal) {
        self.id = id
        self.name = name
        self.carrier = carrier
        self.estimatedDaysMin = estimatedDaysMin
        self.estimatedDaysMax = estimatedDaysMax
        self.cost = cost
    }
}

public struct ModaicsTrackingInfo: Codable, Hashable, Identifiable {
    public let id: UUID
    public var carrier: String
    public var trackingNumber: String
    public var url: URL?
    public var status: String?
    public var lastUpdate: Date?
    public var events: [ModaicsTrackingEvent]
    
    public init(
        id: UUID = UUID(),
        carrier: String,
        trackingNumber: String,
        url: URL? = nil,
        status: String? = nil,
        lastUpdate: Date? = nil,
        events: [ModaicsTrackingEvent] = []
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

public struct ModaicsTrackingEvent: Codable, Hashable, Identifiable {
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

public struct ModaicsAddress: Codable, Hashable, Identifiable {
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

public enum ModaicsShippingPayer: String, Codable, CaseIterable, Hashable {
    case seller = "seller"
    case buyer = "buyer"
    case split = "split"
}

public struct ModaicsReview: Identifiable, Codable, Hashable {
    public let id: UUID
    public var authorId: UUID
    public var rating: Int
    public var comment: String
    public var createdAt: Date
    public var exchangeId: UUID
    public var tags: [ModaicsReviewTag]
    
    public init(
        id: UUID = UUID(),
        authorId: UUID,
        rating: Int,
        comment: String,
        createdAt: Date = Date(),
        exchangeId: UUID,
        tags: [ModaicsReviewTag] = []
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

public enum ModaicsReviewTag: String, Codable, CaseIterable, Hashable {
    case accurateDescription = "accurate_description"
    case fastShipping = "fast_shipping"
    case greatCommunication = "great_communication"
    case wellPackaged = "well_packaged"
    case itemAsDescribed = "item_as_described"
    case fairPricing = "fair_pricing"
    case wouldRecommend = "would_recommend"
}

public struct ModaicsDispute: Codable, Hashable, Identifiable {
    public let id: UUID
    public var reason: ModaicsDisputeReason
    public var description: String
    public var openedAt: Date
    public var resolvedAt: Date?
    public var resolution: ModaicsDisputeResolution?
    public var openedBy: UUID
    
    public init(
        id: UUID = UUID(),
        reason: ModaicsDisputeReason,
        description: String,
        openedAt: Date = Date(),
        resolvedAt: Date? = nil,
        resolution: ModaicsDisputeResolution? = nil,
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

public enum ModaicsDisputeReason: String, Codable, CaseIterable, Hashable {
    case itemNotAsDescribed = "item_not_as_described"
    case itemNotReceived = "item_not_received"
    case wrongItem = "wrong_item"
    case damagedItem = "damaged_item"
    case counterfeit = "counterfeit"
    case other = "other"
}

public enum ModaicsDisputeResolution: String, Codable, CaseIterable, Hashable {
    case refundIssued = "refund_issued"
    case partialRefund = "partial_refund"
    case returnRequested = "return_requested"
    case resolvedInFavorOfSeller = "resolved_seller"
    case resolvedInFavorOfBuyer = "resolved_buyer"
}
