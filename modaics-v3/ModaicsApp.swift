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
                .preferredColorScheme(.dark)
        }
    }
    
    private func configureAppearance() {
        // Set dark mode as default
        UITraitCollection.current = UITraitCollection(traitsFrom: [
            UITraitCollection.current,
            UITraitCollection(userInterfaceStyle: .dark)
        ])
        
        // Navigation bar appearance - transparent with dark green styling
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = UIColor(Color.modaicsBackground)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.sageWhite),
            .font: UIFont.monospacedSystemFont(ofSize: 17, weight: .medium)
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.sageWhite),
            .font: UIFont.monospacedSystemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
}