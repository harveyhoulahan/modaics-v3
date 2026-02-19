import SwiftUI

// MARK: - Sustainability Badge
public enum SustainabilityBadge: String, CaseIterable, Codable {
    case seedling = "Seedling"
    case circulator = "Circulator"
    case localShopper = "Local Shopper"
    case storyTeller = "Story Teller"
    case ecoWarrior = "Eco Warrior"
    case swapStar = "Swap Star"
    case eventGoer = "Event Goer"
    case zeroWaste = "Zero Waste"
    case mentor = "Mentor"
    case collector100 = "Collector 100"
    case carbonNeutral = "Carbon Neutral"
    case communityPillar = "Community Pillar"
    
    public var icon: String {
        switch self {
        case .seedling: return "leaf.fill"
        case .circulator: return "arrow.3.trianglepath"
        case .localShopper: return "mappin.and.ellipse"
        case .storyTeller: return "book.fill"
        case .ecoWarrior: return "globe"
        case .swapStar: return "arrow.left.arrow.right"
        case .eventGoer: return "calendar"
        case .zeroWaste: return "trash.slash.fill"
        case .mentor: return "person.2.fill"
        case .collector100: return "number.square.fill"
        case .carbonNeutral: return "cloud.sun.fill"
        case .communityPillar: return "building.columns.fill"
        }
    }
    
    public var description: String {
        switch self {
        case .seedling: return "List your first item"
        case .circulator: return "Circulate 5 items in the marketplace"
        case .localShopper: return "Make 3 local purchases"
        case .storyTeller: return "Write 5 garment stories"
        case .ecoWarrior: return "Earn 1000 eco points"
        case .swapStar: return "Complete 10 successful swaps"
        case .eventGoer: return "Attend 5 community events"
        case .zeroWaste: return "Maintain a 100% sustainable wardrobe"
        case .mentor: return "Help 10 new users get started"
        case .collector100: return "Add 100 items to your wardrobe"
        case .carbonNeutral: return "Offset 100kg of CO₂"
        case .communityPillar: return "Make 50 community posts"
        }
    }
    
    public var threshold: Int {
        switch self {
        case .seedling: return 1
        case .circulator: return 5
        case .localShopper: return 3
        case .storyTeller: return 5
        case .ecoWarrior: return 1000
        case .swapStar: return 10
        case .eventGoer: return 5
        case .zeroWaste: return 100
        case .mentor: return 10
        case .collector100: return 100
        case .carbonNeutral: return 100
        case .communityPillar: return 50
        }
    }
    
    public var color: Color {
        switch self {
        case .seedling: return .modaicsEco
        case .circulator: return .natureTeal
        case .localShopper: return .luxeGold
        case .storyTeller: return .modaicsSage
        case .ecoWarrior: return .modaicsEmerald
        case .swapStar: return .modaicsMoss
        case .eventGoer: return .modaicsOlive
        case .zeroWaste: return .modaicsFern
        case .mentor: return .luxeGoldBright
        case .collector100: return .modaicsChrome
        case .carbonNeutral: return .modaicsEco
        case .communityPillar: return .modaicsAluminum
        }
    }
}

// MARK: - Sustainability View Model
@MainActor
public class SustainabilityViewModel: ObservableObject {
    @Published public var ecoPoints: Int = 0
    @Published public var waterSavedLiters: Double = 0
    @Published public var carbonSavedKg: Double = 0
    @Published public var itemsCirculated: Int = 0
    @Published public var earnedBadges: Set<SustainabilityBadge> = []
    @Published public var badgeProgress: [SustainabilityBadge: Double] = [:]
    @Published public var monthlyChange: (water: Double, carbon: Double, items: Int) = (0, 0, 0)
    @Published public var isLoading: Bool = false
    
    public var nextMilestone: Int {
        let milestones = [250, 500, 1000, 2500, 5000, 10000]
        return milestones.first { $0 > ecoPoints } ?? 10000
    }
    
    public var pointsToNext: Int {
        nextMilestone - ecoPoints
    }
    
    public var progressPercentage: Double {
        Double(ecoPoints) / Double(nextMilestone)
    }
    
    public init() {
        loadMockData()
    }
    
    private func loadMockData() {
        ecoPoints = 500
        waterSavedLiters = 8100
        carbonSavedKg = 47.2
        itemsCirculated = 12
        earnedBadges = [.seedling, .circulator, .localShopper]
        monthlyChange = (water: 12, carbon: 8, items: 5)
        
        // Calculate badge progress
        for badge in SustainabilityBadge.allCases {
            if earnedBadges.contains(badge) {
                badgeProgress[badge] = 1.0
            } else {
                // Mock progress calculation
                badgeProgress[badge] = Double.random(in: 0.2...0.8)
            }
        }
    }
    
    public func loadStats(for userId: String) async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        loadMockData()
        isLoading = false
    }
    
    public func checkBadgeEligibility() {
        // Check each badge threshold
        for badge in SustainabilityBadge.allCases {
            switch badge {
            case .seedling:
                if itemsCirculated >= 1 { earnedBadges.insert(badge) }
            case .circulator:
                if itemsCirculated >= 5 { earnedBadges.insert(badge) }
            case .ecoWarrior:
                if ecoPoints >= 1000 { earnedBadges.insert(badge) }
            default:
                break
            }
        }
    }
    
    public func calculateCircularityScore() -> Int {
        // 0-100 composite score based on various factors
        let pointsScore = min(ecoPoints / 100, 30)
        let itemsScore = min(itemsCirculated * 2, 40)
        let carbonScore = min(Int(carbonSavedKg) / 2, 30)
        return min(pointsScore + itemsScore + carbonScore, 100)
    }
}
