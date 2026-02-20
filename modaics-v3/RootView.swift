import SwiftUI

// MARK: - Root View
struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color.warmOffWhite.ignoresSafeArea()
            
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
            Text("modaics")
                .font(.editorialDisplayMedium(28))
                .foregroundColor(.nearBlack)
            
            ProgressView()
                .scaleEffect(1.2)
                .tint(.agedBrass)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.warmOffWhite)
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color.warmOffWhite.ignoresSafeArea()
            
            VStack(spacing: 48) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("modaics")
                        .font(.editorialDisplayMedium(36))
                        .foregroundColor(.nearBlack)
                    
                    Text("Every piece, a story")
                        .font(.bodyMedium)
                        .foregroundColor(.warmCharcoal)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        appState.completeOnboarding()
                    }) {
                        Text("Enter")
                            .font(.bodyText(15, weight: .medium))
                            .foregroundColor(.warmOffWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.nearBlack)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                    
                    Button(action: {}) {
                        Text("Sign in")
                            .font(.bodyText(15, weight: .medium))
                            .foregroundColor(.nearBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.nearBlack.opacity(0.3), lineWidth: 1)
                            )
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
            Color.warmOffWhite.ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("modaics")
                        .font(.editorialDisplayMedium(24))
                        .foregroundColor(.nearBlack)
                    
                    Text("Sign in")
                        .font(.bodyMedium)
                        .foregroundColor(.warmCharcoal)
                }
                .padding(.top, 60)
                
                Spacer()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.uiLabelSmall)
                            .foregroundColor(.warmCharcoal)
                        
                        TextField("", text: $email)
                            .font(.bodyMedium)
                            .foregroundColor(.nearBlack)
                            .padding(14)
                            .background(Color.ivory)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.warmDivider, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.uiLabelSmall)
                            .foregroundColor(.warmCharcoal)
                        
                        SecureField("", text: $password)
                            .font(.bodyMedium)
                            .foregroundColor(.nearBlack)
                            .padding(14)
                            .background(Color.ivory)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.warmDivider, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button(action: {
                    appState.isAuthenticated = true
                }) {
                    Text("Sign in")
                        .font(.bodyText(15, weight: .medium))
                        .foregroundColor(.warmOffWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.nearBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
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
                    WardrobeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $appState.selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar (Editorial Style)
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack(spacing: 0) {
            // Thin top border
            Rectangle()
                .fill(Color.warmDivider)
                .frame(height: 0.5)
            
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
            .background(Color.warmOffWhite)
        }
    }
}

// MARK: - Tab Button (Editorial Style)
struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.editorialSpring) {
                scale = 0.9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.editorialSpring) {
                    scale = 1.0
                }
            }
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.icon : tab.inactiveIcon)
                    .font(.system(size: tab == .create ? 24 : 20, weight: .regular))
                    .foregroundColor(isSelected ? .nearBlack : .mutedGray)
                    .scaleEffect(scale)
                
                if tab != .create {
                    Text(tab.label)
                        .font(.tabLabel)
                        .foregroundColor(isSelected ? .nearBlack : .mutedGray)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Placeholder Views (Editorial Style)
struct DiscoveryPlaceholderView: View {
    var body: some View {
        ZStack {
            Color.warmOffWhite.ignoresSafeArea()
            Text("Discover")
                .font(.editorialMedium)
                .foregroundColor(.nearBlack)
        }
    }
}

struct CreatePlaceholderView: View {
    var body: some View {
        ZStack {
            Color.warmOffWhite.ignoresSafeArea()
            Text("List a piece")
                .font(.editorialMedium)
                .foregroundColor(.nearBlack)
        }
    }
}

struct CommunityPlaceholderView: View {
    var body: some View {
        ZStack {
            Color.warmOffWhite.ignoresSafeArea()
            Text("Community")
                .font(.editorialMedium)
                .foregroundColor(.nearBlack)
        }
    }
}

struct WardrobePlaceholderView: View {
    var body: some View {
        ZStack {
            Color.warmOffWhite.ignoresSafeArea()
            Text("Wardrobe")
                .font(.editorialMedium)
                .foregroundColor(.nearBlack)
        }
    }
}
