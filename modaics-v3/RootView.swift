import SwiftUI

// MARK: - Root View
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

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.modaicsWarmSand.ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.modaicsTerracotta)
                
                Text("Loading...")
                    .font(.modaicsBodyRegular)
                    .foregroundColor(.modaicsCharcoal)
            }
        }
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color.modaicsWarmSand.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Modaics")
                        .font(.modaicsDisplayLarge)
                        .foregroundColor(.modaicsCharcoal)
                    
                    Text("Every piece, a story")
                        .font(.modaicsBodyLarge)
                        .foregroundColor(.modaicsTerracotta)
                }
                
                Spacer()
                
                Button(action: {
                    appState.completeOnboarding()
                }) {
                    Text("Get Started")
                        .font(.modaicsButton)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.modaicsTerracotta)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Auth View
struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color.modaicsWarmSand.ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("Modaics")
                        .font(.modaicsDisplaySmall)
                        .foregroundColor(.modaicsCharcoal)
                    
                    Text("Sign In")
                        .font(.modaicsBodyLarge)
                        .foregroundColor(.modaicsStone)
                }
                .padding(.top, 60)
                
                Spacer()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.modaicsCaption)
                            .foregroundColor(.modaicsStone)
                        
                        TextField("", text: $email)
                            .font(.modaicsBodyRegular)
                            .padding(12)
                            .background(Color.modaicsPaper)
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.modaicsCaption)
                            .foregroundColor(.modaicsStone)
                        
                        SecureField("", text: $password)
                            .font(.modaicsBodyRegular)
                            .padding(12)
                            .background(Color.modaicsPaper)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button(action: {
                    appState.isAuthenticated = true
                }) {
                    Text("Sign In")
                        .font(.modaicsButton)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.modaicsTerracotta)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            DiscoveryView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
                .tag(Tab.discover)
            
            TellStoryView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(Tab.create)
            
            // Community - Placeholder until ported
            Text("Community")
                .tabItem {
                    Label("Community", systemImage: "person.3.fill")
                }
                .tag(Tab.community)
            
            WardrobeView()
                .tabItem {
                    Label("Wardrobe", systemImage: "square.grid.2x2")
                }
                .tag(Tab.profile)
        }
        .accentColor(.modaicsTerracotta)
    }
}