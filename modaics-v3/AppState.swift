import SwiftUI
import Combine

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    @Published var isLoading: Bool = false
    @Published var selectedTab: Tab = .home
    
    init() {
        // TODO: Check actual auth state when Firebase is added
        isAuthenticated = false
        hasCompletedOnboarding = false
        isLoading = false
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    func selectTab(_ tab: Tab) {
        selectedTab = tab
    }
}

// MARK: - Tab Enumeration
enum Tab: String, CaseIterable, Identifiable {
    case home = "Home"
    case discover = "Discover"
    case create = "Create"
    case community = "Community"
    case profile = "Wardrobe"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .discover: return "magnifyingglass"
        case .create: return "plus.circle.fill"
        case .community: return "person.3.fill"
        case .profile: return "square.grid.2x2"
        }
    }
}