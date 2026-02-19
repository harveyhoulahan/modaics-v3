import SwiftUI
import Combine

@main
struct ModaicsApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        configureIndustrialAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
    
    private func configureIndustrialAppearance() {
        // Navigation bar - transparent with industrial styling
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = UIColor(Color.industrialBackground)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.industrialTextMain),
            .font: UIFont.monospacedSystemFont(ofSize: 17, weight: .medium)
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.industrialTextMain),
            .font: UIFont.monospacedSystemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        // Tab bar - industrial dark styling
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.industrialSurface)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Remove default back button text
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .font: UIFont.monospacedSystemFont(ofSize: 0, weight: .medium)
        ], for: .normal)
    }
}