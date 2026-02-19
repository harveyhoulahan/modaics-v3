import SwiftUI
import Combine

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    @Published var isLoading: Bool = false
    @Published var selectedTab: Tab = .discovery
    
    init() {
        // TODO: Check actual auth state when Firebase is added
        isAuthenticated = false
        hasCompletedOnboarding = false
        isLoading = false
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

// MARK: - Tab Enumeration
enum Tab: String, CaseIterable {
    case discovery = "Discover"
    case tellStory = "Tell Story"
    case wardrobe = "Wardrobe"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .discovery: return "magnifyingglass"
        case .tellStory: return "plus.circle.fill"
        case .wardrobe: return "square.grid.2x2"
        case .profile: return "person"
        }
    }
    
    var isCenter: Bool {
        return self == .tellStory
    }
}