import SwiftUI
import Combine

// MARK: - Edit Profile Form
public struct EditProfileForm {
    var displayName: String = ""
    var username: String = ""
    var bio: String = ""
    var location: String = ""
    var aesthetic: ModaicsAesthetic? = nil
    var styleDescriptors: [String] = []
    var favoriteColors: [String] = []
    var sizePreferences: [ModaicsSizePreference] = []
    var openToTrade: Bool = true
    var preferredExchangeTypes: [ModaicsExchangeType] = []
    var shippingPreference: ModaicsShippingPreference = .domestic
    var avatarImage: UIImage? = nil
    var coverImage: UIImage? = nil
}

// MARK: - Profile Header View Model
@MainActor
public class ProfileHeaderViewModel: ObservableObject {
    @Published public var user: ModaicsUser
    @Published public var isEditing: Bool = false
    @Published public var showSettings: Bool = false
    @Published public var showMembershipUpgrade: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var editForm: EditProfileForm = EditProfileForm()
    
    public init(user: ModaicsUser? = nil) {
        self.user = user ?? Self.createMockUser()
        self.editForm = EditProfileForm(
            displayName: self.user.displayName,
            username: self.user.username,
            bio: self.user.bio,
            location: self.user.location?.city ?? "",
            aesthetic: self.user.aesthetic,
            styleDescriptors: self.user.styleDescriptors,
            favoriteColors: self.user.favoriteColors,
            sizePreferences: self.user.sizePreferences,
            openToTrade: self.user.openToTrade,
            preferredExchangeTypes: self.user.preferredExchangeTypes,
            shippingPreference: self.user.shippingPreference
        )
    }
    
    private static func createMockUser() -> ModaicsUser {
        ModaicsUser(
            displayName: "Harvey Houlahan",
            username: "harveyh",
            bio: "Sustainable fashion enthusiast and vintage collector. Building the future of circular fashion at Modaics.",
            styleDescriptors: ["Vintage", "Minimalist", "Earth Tones"],
            aesthetic: .vintage,
            sizePreferences: [],
            favoriteColors: [],
            openToTrade: true,
            preferredExchangeTypes: [.sellOrTrade],
            rating: 4.8,
            ratingCount: 23,
            followerCount: 147,
            followingCount: 89,
            totalCarbonSavingsKg: 47.2,
            totalWaterSavingsLiters: 8100,
            itemsCirculated: 12,
            location: ModaicsLocation(city: "Melbourne", country: "Australia"),
            shippingPreference: .domestic,
            email: "harvey@modaics.com",
            isEmailVerified: true,
            tier: .free,
            ecoPoints: 500
        )
    }
    
    public func loadProfile() async {
        isLoading = true
        // Simulate API call
        try? await Task.sleep(nanoseconds: 500_000_000)
        isLoading = false
    }
    
    public func saveProfile() async -> Bool {
        isLoading = true
        
        // Validate required fields
        guard !editForm.displayName.isEmpty else {
            isLoading = false
            return false
        }
        
        guard editForm.username.count >= 3 else {
            isLoading = false
            return false
        }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 800_000_000)
        
        // Update user with form data
        var updatedUser = user
        updatedUser.displayName = editForm.displayName
        updatedUser.username = editForm.username
        updatedUser.bio = editForm.bio
        updatedUser.location = editForm.location.isEmpty ? nil : ModaicsLocation(
            city: editForm.location,
            country: "Australia"
        )
        updatedUser.aesthetic = editForm.aesthetic
        updatedUser.styleDescriptors = editForm.styleDescriptors
        updatedUser.favoriteColors = editForm.favoriteColors
        updatedUser.sizePreferences = editForm.sizePreferences
        updatedUser.openToTrade = editForm.openToTrade
        updatedUser.preferredExchangeTypes = editForm.preferredExchangeTypes
        updatedUser.shippingPreference = editForm.shippingPreference
        
        user = updatedUser
        isLoading = false
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        return true
    }
    
    public func signOut() {
        // Would call auth service
        print("Signing out...")
    }
    
    public func deleteAccount() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
        // Would call API to delete account
    }
    
    public func upgradeMembership(to tier: ModaicsUserTier) async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        var updatedUser = user
        updatedUser.tier = tier
        user = updatedUser
        
        isLoading = false
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    public var isPremium: Bool {
        user.tier == .premium || user.tier == .atelier
    }
    
    public var isAtelier: Bool {
        user.tier == .atelier
    }
    
    public var tierBadgeText: String {
        switch user.tier {
        case .free: return ""
        case .premium: return "PRO"
        case .atelier: return "ATELIER"
        }
    }
    
    public var joinedDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return "Joined \(formatter.string(from: user.joinedAt))"
    }
}
