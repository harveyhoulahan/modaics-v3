import SwiftUI
import Combine

@main
struct ModaicsApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
    
    private func configureAppearance() {
        // Tab bar appearance - warm sand background
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.modaicsWarmSand)
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.modaicsStone)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.modaicsStone)
        ]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.modaicsTerracotta)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.modaicsTerracotta)
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(Color.modaicsWarmSand)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.modaicsCharcoal),
            .font: UIFont(name: "PlayfairDisplay-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
}