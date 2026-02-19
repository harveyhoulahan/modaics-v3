import SwiftUI

// MARK: - Root View
/// Main entry point with industrial-themed navigation
struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Industrial dark blue background
            Color.industrialBackground
                .ignoresSafeArea()
            
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
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.industrialRed)
            
            Text("LOADING...")
                .font(.industrialLabelMedium)
                .foregroundColor(.industrialTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.industrialBackground)
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Logo/Title
            VStack(spacing: 16) {
                Text("MODAICS")
                    .font(.industrialDisplayLarge)
                    .foregroundColor(.industrialTextMain)
                
                Text("EVERY PIECE, A STORY")
                    .font(.industrialLabelLarge)
                    .foregroundColor(.industrialRed)
                    .tracking(4)
            }
            
            Spacer()
            
            // Get Started Button
            Button(action: {
                appState.completeOnboarding()
            }) {
                HStack(spacing: 12) {
                    Text("ENTER")
                        .font(.industrialButton)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.industrialRed)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.industrialBorderChrome, lineWidth: 1)
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.industrialBackground)
    }
}

// MARK: - Auth View
struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                Text("MODAICS")
                    .font(.industrialDisplaySmall)
                    .foregroundColor(.industrialTextMain)
                
                Text("SIGN IN")
                    .font(.industrialLabelLarge)
                    .foregroundColor(.industrialTextSecondary)
                    .tracking(2)
            }
            .padding(.top, 60)
            
            Spacer()
            
            // Form
            VStack(spacing: 20) {
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("EMAIL")
                        .font(.industrialLabelSmall)
                        .foregroundColor(.industrialTextMuted)
                    
                    TextField("", text: $email)
                        .font(.industrialBody)
                        .foregroundColor(.industrialTextMain)
                        .padding(12)
                        .background(Color.industrialSurface)
                        .overlay(
                            Rectangle()
                                .stroke(Color.industrialBorder, lineWidth: 1)
                        )
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("PASSWORD")
                        .font(.industrialLabelSmall)
                        .foregroundColor(.industrialTextMuted)
                    
                    SecureField("", text: $password)
                        .font(.industrialBody)
                        .foregroundColor(.industrialTextMain)
                        .padding(12)
                        .background(Color.industrialSurface)
                        .overlay(
                            Rectangle()
                                .stroke(Color.industrialBorder, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Sign In Button
            Button(action: {
                appState.isAuthenticated = true
            }) {
                Text("SIGN IN")
                    .font(.industrialButton)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.industrialRed)
                    .overlay(
                        Rectangle()
                            .stroke(Color.industrialBorderChrome, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.industrialBackground)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            IndustrialTabBar(
                selectedTab: $appState.selectedTab,
                onTabSelected: { tab in
                    appState.selectTab(tab)
                }
            )
        }
        .ignoresSafeArea(.keyboard)
    }
    
    @ViewBuilder
    private var tabContent: some View {
        switch appState.selectedTab {
        case .home:
            HomeView()
        case .discover:
            DiscoverView()
        case .create:
            CreateView()
        case .community:
            CommunityView()
        case .profile:
            ProfileView()
        }
    }
}

// MARK: - Industrial Tab Bar
struct IndustrialTabBar: View {
    @Binding var selectedTab: Tab
    var onTabSelected: (Tab) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(Color.industrialBorder)
                .frame(height: 1)
            
            // Tab buttons
            HStack(spacing: 0) {
                ForEach(Tab.allCases) { tab in
                    TabButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: { onTabSelected(tab) }
                    )
                }
            }
            .frame(height: 60)
            .background(Color.industrialSurface)
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.icon : tab.inactiveIcon)
                    .font(.system(size: tab.isSpecial ? 28 : 22, weight: .medium))
                
                if !tab.isSpecial {
                    Text(tab.label)
                        .font(.industrialLabelSmall)
                }
            }
            .foregroundColor(isSelected ? .industrialRed : .industrialTextMuted)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                isSelected ? Color.industrialRed.opacity(0.1) : Color.clear
            )
        }
    }
}