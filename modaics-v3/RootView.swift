import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isLoading {
                LoadingView()
            } else if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else if !appState.isAuthenticated {
                AuthView()
            } else {
                MainTabView()
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Loading...")
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Welcome to Modaics")
                .font(.largeTitle)
            Button("Get Started") {
                appState.completeOnboarding()
            }
            .padding()
        }
    }
}

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Sign In") {
                // TODO: Implement auth
                appState.isAuthenticated = true
            }
            .padding()
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            DiscoveryView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
                .tag(Tab.discovery)
            
            TellStoryView()
                .tabItem {
                    Label("Tell Story", systemImage: "plus.circle.fill")
                }
                .tag(Tab.tellStory)
            
            WardrobeView()
                .tabItem {
                    Label("Wardrobe", systemImage: "square.grid.2x2")
                }
                .tag(Tab.wardrobe)
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)
        }
    }
}