import SwiftUI

// MARK: - Root View
struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            Group {
                if appState.isLoading {
                    LoadingView()
                } else if !appState.hasCompletedOnboarding {
                    OnboardingView()
                } else if !appState.isAuthenticated {
                    AuthView()
                } else {
                    MainAppView()
                }
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo
            Text("MODAICS")
                .font(.forestDisplayMedium)
                .foregroundColor(.luxeGold)
                .tracking(4)
            
            ProgressView()
                .scaleEffect(1.2)
                .tint(.luxeGold)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.modaicsBackground)
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            VStack(spacing: 48) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("MODAICS")
                        .font(.forestDisplayLarge)
                        .foregroundColor(.luxeGold)
                        .tracking(6)
                    
                    Text("EVERY PIECE, A STORY")
                        .font(.forestCaptionLarge)
                        .foregroundColor(.sageMuted)
                        .tracking(3)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        appState.completeOnboarding()
                    }) {
                        Text("ENTER")
                            .font(.forestBodyLarge)
                            .foregroundColor(.modaicsBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.luxeGold)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {}) {
                        Text("SIGN IN")
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.modaicsSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.luxeGold.opacity(0.5), lineWidth: 1)
                            )
                            .cornerRadius(8)
                    }
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
            Color.modaicsBackground.ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("MODAICS")
                        .font(.forestDisplaySmall)
                        .foregroundColor(.luxeGold)
                        .tracking(4)
                    
                    Text("SIGN IN")
                        .font(.forestCaptionLarge)
                        .foregroundColor(.sageMuted)
                        .tracking(2)
                }
                .padding(.top, 60)
                
                Spacer()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EMAIL")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                            .tracking(1)
                        
                        TextField("", text: $email)
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageWhite)
                            .padding(14)
                            .background(Color.modaicsSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                            )
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PASSWORD")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                            .tracking(1)
                        
                        SecureField("", text: $password)
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageWhite)
                            .padding(14)
                            .background(Color.modaicsSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                            )
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button(action: {
                    appState.isAuthenticated = true
                }) {
                    Text("SIGN IN")
                        .font(.forestBodyLarge)
                        .foregroundColor(.modaicsBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.luxeGold)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Main App View with Custom Tab Bar
struct MainAppView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch appState.selectedTab {
                case .home:
                    HomeView()
                case .discover:
                    DiscoverView()
                case .create:
                    UnifiedCreateView()
                case .community:
                    CommunityView()
                case .profile:
                    WardrobePlaceholderView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $appState.selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack(spacing: 0) {
            // Chrome gradient line at top
            LinearGradient(
                colors: [Color.modaicsChrome.opacity(0.3), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 1)
            
            HStack(spacing: 0) {
                ForEach(Tab.allCases) { tab in
                    TabButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                }
            }
            .frame(height: 55)
            .background(
                Color.modaicsBackground.opacity(0.95)
                    .overlay(.ultraThinMaterial)
            )
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.icon : tab.inactiveIcon)
                    .font(.system(size: tab == .create ? 28 : 22, weight: .medium))
                    .foregroundColor(isSelected ? .luxeGold : .modaicsGunmetal)
                    .scaleEffect(scale)
                
                if tab != .create {
                    Text(tab.label)
                        .font(.forestTabLabel)
                        .foregroundColor(isSelected ? .luxeGold : .modaicsGunmetal)
                        .tracking(1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Placeholder Views
struct DiscoveryPlaceholderView: View {
    var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            Text("DISCOVER")
                .font(.forestDisplaySmall)
                .foregroundColor(.sageWhite)
        }
    }
}

struct CreatePlaceholderView: View {
    var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            Text("LIST A PIECE")
                .font(.forestDisplaySmall)
                .foregroundColor(.sageWhite)
        }
    }
}

struct CommunityPlaceholderView: View {
    var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            Text("COMMUNITY")
                .font(.forestDisplaySmall)
                .foregroundColor(.sageWhite)
        }
    }
}

struct WardrobePlaceholderView: View {
    var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            Text("WARDROBE")
                .font(.forestDisplaySmall)
                .foregroundColor(.sageWhite)
        }
    }
}