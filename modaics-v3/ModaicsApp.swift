import SwiftUI
import Combine
import UserNotifications

@main
struct ModaicsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    
    init() {
        // Configure appearance
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
        }
    }
    
    private func configureAppearance() {
        // Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(DesignSystem.Colors.warmSand)
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(DesignSystem.Colors.terracotta.opacity(0.6))
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.Colors.terracotta.opacity(0.6))
        ]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(DesignSystem.Colors.terracotta)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.Colors.terracotta)
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(DesignSystem.Colors.warmSand)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.Colors.charcoal),
            .font: UIFont(name: "PlayfairDisplay-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    @Published var isLoading: Bool = true
    @Published var selectedTab: Tab = .discovery
    @Published var deepLinkTarget: DeepLinkTarget?
    
    init() {
        checkAuthenticationStatus()
        checkOnboardingStatus()
    }
    
    private func checkAuthenticationStatus() {
        // TODO: Implement with real auth service when Firebase is added
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.isLoading = false
        }
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func signOut() {
        // TODO: Implement with real auth service when Firebase is added
        isAuthenticated = false
    }
}

// MARK: - Deep Link Target
enum DeepLinkTarget: Equatable {
    case garment(id: UUID)
    case story(id: UUID)
    case userProfile(id: UUID)
    case wardrobe
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