import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            if appState.isLoading {
                SplashView()
            } else if !appState.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else if !appState.isAuthenticated {
                AuthGateView()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isLoading)
        .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var navigationState = NavigationState()
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.warmSand
                .ignoresSafeArea()
            
            TabView(selection: $appState.selectedTab) {
                // Discovery Tab
                DiscoveryView()
                    .tabItem {
                        Image(systemName: Tab.discovery.icon)
                        Text(Tab.discovery.rawValue)
                    }
                    .tag(Tab.discovery)
                
                // Tell Story Tab (Center - Prominent)
                TellStoryView()
                    .tabItem {
                        Image(systemName: Tab.tellStory.icon)
                        Text(Tab.tellStory.rawValue)
                    }
                    .tag(Tab.tellStory)
                
                // Wardrobe Tab
                WardrobeView()
                    .tabItem {
                        Image(systemName: Tab.wardrobe.icon)
                        Text(Tab.wardrobe.rawValue)
                    }
                    .tag(Tab.wardrobe)
                
                // Profile Tab
                ProfileView()
                    .tabItem {
                        Image(systemName: Tab.profile.icon)
                        Text(Tab.profile.rawValue)
                    }
                    .tag(Tab.profile)
            }
            .accentColor(DesignSystem.Colors.terracotta)
        }
        .environmentObject(navigationState)
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return }
        
        switch host {
        case "garment":
            if let id = components.path.split(separator: "/").last {
                appState.deepLinkTarget = .garment(id: String(id))
                appState.selectedTab = .discovery
            }
        case "story":
            if let id = components.path.split(separator: "/").last {
                appState.deepLinkTarget = .story(id: String(id))
                appState.selectedTab = .discovery
            }
        case "user":
            if let id = components.path.split(separator: "/").last {
                appState.deepLinkTarget = .userProfile(id: String(id))
                appState.selectedTab = .profile
            }
        case "wardrobe":
            appState.deepLinkTarget = .wardrobe
            appState.selectedTab = .wardrobe
        default:
            break
        }
    }
}

// MARK: - Navigation State
class NavigationState: ObservableObject {
    @Published var discoveryPath = NavigationPath()
    @Published var wardrobePath = NavigationPath()
    @Published var profilePath = NavigationPath()
    
    func navigateToGarment(_ id: String, from tab: Tab) {
        switch tab {
        case .discovery:
            discoveryPath.append(NavigationDestination.garment(id: id))
        case .wardrobe:
            wardrobePath.append(NavigationDestination.garment(id: id))
        default:
            break
        }
    }
    
    func navigateToStory(_ id: String) {
        discoveryPath.append(NavigationDestination.story(id: id))
    }
}

// MARK: - Navigation Destination
enum NavigationDestination: Hashable {
    case garment(id: String)
    case story(id: String)
    case userProfile(id: String)
    case settings
    case addGarment
    case editGarment(id: String)
}

// MARK: - Placeholder Views
struct DiscoveryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        NavigationStack(path: $navigationState.discoveryPath) {
            DiscoveryContentView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .garment(let id):
                        GarmentDetailView(garmentId: id)
                    case .story(let id):
                        StoryDetailView(storyId: id)
                    case .userProfile(let id):
                        UserProfileView(userId: id)
                    default:
                        EmptyView()
                    }
                }
        }
    }
}

struct DiscoveryContentView: View {
    @StateObject private var viewModel = ServiceLocator.shared.discoveryViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.large) {
                // Header
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Discover")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(DesignSystem.Colors.charcoal)
                    
                    Text("Stories woven into what we wear")
                        .font(DesignSystem.Typography.bodyLarge)
                        .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Content based on state
                if viewModel.isLoading {
                    LoadingView()
                } else if let error = viewModel.error {
                    ErrorView(error: error, retryAction: viewModel.refresh)
                } else {
                    // Trending Stories
                    TrendingStoriesSection(stories: viewModel.trendingStories)
                    
                    // Recently Added
                    RecentGarmentsSection(garments: viewModel.recentGarments)
                    
                    // Curated Collections
                    CollectionsSection(collections: viewModel.collections)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .background(DesignSystem.Colors.warmSand)
    }
}

struct TellStoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var showStoryComposer = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.xlarge) {
                Spacer()
                
                // Hero Icon
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.terracotta.opacity(0.15))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(DesignSystem.Colors.terracotta.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(DesignSystem.Colors.terracotta)
                }
                
                VStack(spacing: DesignSystem.Spacing.medium) {
                    Text("Tell Your Story")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(DesignSystem.Colors.charcoal)
                    
                    Text("Every garment holds a memory.\nShare the story behind what you wear.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                Button(action: { showStoryComposer = true }) {
                    HStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: "camera.fill")
                        Text("Start Your Story")
                    }
                    .font(DesignSystem.Typography.button)
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignSystem.Spacing.xlarge)
                    .padding(.vertical, DesignSystem.Spacing.medium)
                    .background(DesignSystem.Colors.terracotta)
                    .cornerRadius(DesignSystem.CornerRadius.large)
                }
                
                Spacer()
            }
            .padding()
            .background(DesignSystem.Colors.warmSand)
            .navigationTitle("")
            .sheet(isPresented: $showStoryComposer) {
                StoryComposerView()
            }
        }
    }
}

struct WardrobeView: View {
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        NavigationStack(path: $navigationState.wardrobePath) {
            WardrobeContentView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .garment(let id):
                        GarmentDetailView(garmentId: id)
                    case .addGarment:
                        AddGarmentView()
                    case .editGarment(let id):
                        EditGarmentView(garmentId: id)
                    default:
                        EmptyView()
                    }
                }
        }
    }
}

struct WardrobeContentView: View {
    @StateObject private var viewModel = ServiceLocator.shared.wardrobeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.large) {
                // Header
                HStack {
                    Text("My Wardrobe")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(DesignSystem.Colors.charcoal)
                    
                    Spacer()
                    
                    Button(action: { viewModel.showAddGarment = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(DesignSystem.Colors.terracotta)
                    }
                }
                .padding(.horizontal)
                
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.garments.isEmpty {
                    EmptyWardrobeView()
                } else {
                    WardrobeGridView(garments: viewModel.garments)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .background(DesignSystem.Colors.warmSand)
    }
}

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        NavigationStack(path: $navigationState.profilePath) {
            ProfileContentView()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .settings:
                        SettingsView()
                    case .userProfile(let id):
                        UserProfileView(userId: id)
                    default:
                        EmptyView()
                    }
                }
        }
    }
}

struct ProfileContentView: View {
    @StateObject private var viewModel = ServiceLocator.shared.profileViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xlarge) {
                // Profile Header
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Colors.terracotta.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Text(viewModel.userInitials)
                            .font(DesignSystem.Typography.largeTitle)
                            .foregroundColor(DesignSystem.Colors.terracotta)
                    }
                    
                    // Name
                    Text(viewModel.displayName)
                        .font(DesignSystem.Typography.title)
                        .foregroundColor(DesignSystem.Colors.charcoal)
                    
                    // Stats
                    HStack(spacing: DesignSystem.Spacing.xlarge) {
                        StatView(value: viewModel.garmentCount, label: "Garments")
                        StatView(value: viewModel.storyCount, label: "Stories")
                        StatView(value: viewModel.followerCount, label: "Followers")
                    }
                }
                .padding()
                .background(DesignSystem.Colors.paper)
                .cornerRadius(DesignSystem.CornerRadius.large)
                .padding(.horizontal)
                
                // Menu Items
                VStack(spacing: 0) {
                    MenuRow(icon: "person.fill", title: "Edit Profile", action: { })
                    Divider()
                    MenuRow(icon: "gearshape.fill", title: "Settings", action: { })
                    Divider()
                    MenuRow(icon: "questionmark.circle.fill", title: "Help & Support", action: { })
                    Divider()
                    MenuRow(icon: "arrow.right.square.fill", title: "Sign Out", action: { appState.signOut() })
                }
                .background(DesignSystem.Colors.paper)
                .cornerRadius(DesignSystem.CornerRadius.large)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(DesignSystem.Colors.warmSand)
    }
}

// MARK: - Supporting Views
struct StatView: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.charcoal)
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.6))
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(DesignSystem.Colors.terracotta)
                    .frame(width: 30)
                
                Text(title)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.charcoal)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.4))
            }
            .padding()
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
                .tint(DesignSystem.Colors.terracotta)
            Text("Loading...")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.6))
                .padding(.top)
        }
        .padding(DesignSystem.Spacing.xlarge)
    }
}

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(DesignSystem.Colors.terracotta)
            
            Text("Something went wrong")
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.charcoal)
            
            Text(error.localizedDescription)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: retryAction) {
                Text("Try Again")
                    .font(DesignSystem.Typography.button)
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignSystem.Spacing.large)
                    .padding(.vertical, DesignSystem.Spacing.small)
                    .background(DesignSystem.Colors.terracotta)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
            }
            .padding(.top)
        }
        .padding(DesignSystem.Spacing.xlarge)
    }
}

struct EmptyWardrobeView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Spacer()
            
            Image(systemName: "hanger")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.terracotta.opacity(0.5))
            
            Text("Your wardrobe is empty")
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.charcoal)
            
            Text("Start building your collection by\nadding your first garment")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}