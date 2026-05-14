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
        // Navigation bar appearance - transparent with dark green styling
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = UIColor(Color.canvas)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.inkPrimary),
            .font: UIFont.systemFont(ofSize: 17, weight: .medium)
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.inkPrimary),
            .font: UIFont.systemFont(ofSize: 34, weight: .semibold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
}