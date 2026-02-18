import SwiftUI

// MARK: - Discovery Supporting Views
struct TrendingStoriesSection: View {
    let stories: [Story]
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            HStack {
                Text("Trending Stories")
                    .font(DesignSystem.Typography.sectionTitle)
                    .foregroundColor(DesignSystem.Colors.charcoal)
                
                Spacer()
                
                NavigationLink(destination: AllStoriesView()) {
                    Text("See All")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.terracotta)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(stories.prefix(5)) { story in
                        StoryCard(story: story)
                            .onTapGesture {
                                navigationState.navigateToStory(story.id)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct StoryCard: View {
    let story: Story
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Placeholder for story image
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Colors.terracotta.opacity(0.2))
                .frame(width: 200, height: 140)
                .overlay(
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundColor(DesignSystem.Colors.terracotta.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(DesignSystem.Typography.cardTitle)
                    .foregroundColor(DesignSystem.Colors.charcoal)
                    .lineLimit(2)
                
                Text(story.content.prefix(60) + "...")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.stone)
                    .lineLimit(2)
            }
        }
        .frame(width: 200)
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Colors.paper)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(
            color: DesignSystem.Shadows.small.color,
            radius: DesignSystem.Shadows.small.radius,
            x: DesignSystem.Shadows.small.x,
            y: DesignSystem.Shadows.small.y
        )
    }
}

struct RecentGarmentsSection: View {
    let garments: [Garment]
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Recently Added")
                .font(DesignSystem.Typography.sectionTitle)
                .foregroundColor(DesignSystem.Colors.charcoal)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignSystem.Spacing.medium) {
                ForEach(garments.prefix(4)) { garment in
                    GarmentGridItem(garment: garment)
                        .onTapGesture {
                            navigationState.navigateToGarment(garment.id, from: appState.selectedTab)
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct GarmentGridItem: View {
    let garment: Garment
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Placeholder for garment image
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Colors.terracotta.opacity(0.15))
                .aspectRatio(1, contentMode: .fill)
                .overlay(
                    Image(systemName: "hanger")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.terracotta.opacity(0.5))
                )
            
            Text(garment.name)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.charcoal)
                .lineLimit(1)
            
            Text(garment.category)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.stone)
        }
    }
}

struct CollectionsSection: View {
    let collections: [Collection]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Curated Collections")
                .font(DesignSystem.Typography.sectionTitle)
                .foregroundColor(DesignSystem.Colors.charcoal)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(collections) { collection in
                        CollectionCard(collection: collection)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CollectionCard: View {
    let collection: Collection
    
    var body: some View {
        ZStack {
            // Placeholder background
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Colors.terracotta.opacity(0.2))
                .frame(width: 160, height: 200)
            
            // Content overlay
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.title)
                        .font(DesignSystem.Typography.cardTitle)
                        .foregroundColor(.white)
                    
                    Text("\(collection.garmentCount) garments")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(width: 160, height: 200)
            .cornerRadius(DesignSystem.CornerRadius.large)
        }
    }
}

// MARK: - Wardrobe Supporting Views
struct WardrobeGridView: View {
    let garments: [Garment]
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var appState: AppState
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.medium) {
            ForEach(garments) { garment in
                WardrobeItem(garment: garment)
                    .onTapGesture {
                        navigationState.navigateToGarment(garment.id, from: .wardrobe)
                    }
            }
        }
        .padding(.horizontal)
    }
}

struct WardrobeItem: View {
    let garment: Garment
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            // Image placeholder
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Colors.paper)
                .aspectRatio(0.8, contentMode: .fit)
                .overlay(
                    Group {
                        if let firstImage = garment.images.first {
                            // Would load actual image here
                            Image(systemName: "photo.fill")
                                .font(.largeTitle)
                                .foregroundColor(DesignSystem.Colors.terracotta.opacity(0.3))
                        } else {
                            Image(systemName: "hanger")
                                .font(.title2)
                                .foregroundColor(DesignSystem.Colors.terracotta.opacity(0.5))
                        }
                    }
                )
            
            Text(garment.name)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.charcoal)
                .lineLimit(1)
        }
    }
}

// MARK: - Placeholder Destination Views
struct GarmentDetailView: View {
    let garmentId: String
    @StateObject private var viewModel: GarmentDetailViewModel
    
    init(garmentId: String) {
        self.garmentId = garmentId
        _viewModel = StateObject(wrappedValue: ServiceLocator.shared.garmentDetailViewModel(garmentId: garmentId))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.large) {
                if let garment = viewModel.garment {
                    // Garment header
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        // Main image placeholder
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                            .fill(DesignSystem.Colors.terracotta.opacity(0.15))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(systemName: "hanger")
                                    .font(.system(size: 60))
                                    .foregroundColor(DesignSystem.Colors.terracotta.opacity(0.5))
                            )
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text(garment.name)
                                .font(DesignSystem.Typography.largeTitle)
                                .foregroundColor(DesignSystem.Colors.charcoal)
                            
                            HStack(spacing: DesignSystem.Spacing.small) {
                                Label(garment.category, systemImage: "tag")
                                if let brand = garment.brand {
                                    Text("•")
                                    Text(brand)
                                }
                            }
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.stone)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Stories section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        Text("Stories")
                            .font(DesignSystem.Typography.sectionTitle)
                            .foregroundColor(DesignSystem.Colors.charcoal)
                            .padding(.horizontal)
                        
                        if viewModel.stories.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: DesignSystem.Spacing.small) {
                                    Image(systemName: "book.closed")
                                        .font(.title2)
                                        .foregroundColor(DesignSystem.Colors.stone)
                                    Text("No stories yet")
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(DesignSystem.Colors.stone)
                                }
                                .padding()
                                Spacer()
                            }
                        } else {
                            ForEach(viewModel.stories) { story in
                                StoryListItem(story: story)
                            }
                        }
                    }
                } else if viewModel.isLoading {
                    LoadingView()
                        .padding(.top, 100)
                }
            }
            .padding(.vertical)
        }
        .background(DesignSystem.Colors.warmSand)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StoryListItem: View {
    let story: Story
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text(story.title)
                .font(DesignSystem.Typography.cardTitle)
                .foregroundColor(DesignSystem.Colors.charcoal)
            
            Text(story.content)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.stone)
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Colors.paper)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .padding(.horizontal)
    }
}

struct StoryDetailView: View {
    let storyId: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.large) {
                Text("Story Detail")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.charcoal)
                
                Text("ID: \(storyId)")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.stone)
            }
            .padding()
        }
        .background(DesignSystem.Colors.warmSand)
    }
}

struct StoryComposerView: View {
    @StateObject private var viewModel = ServiceLocator.shared.storyComposerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.warmSand
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.large) {
                        // Title
                        TextField("Story Title", text: $viewModel.title)
                            .font(DesignSystem.Typography.title)
                            .padding()
                            .background(DesignSystem.Colors.paper)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                        
                        // Content
                        TextEditor(text: $viewModel.content)
                            .font(DesignSystem.Typography.body)
                            .frame(minHeight: 150)
                            .padding()
                            .background(DesignSystem.Colors.paper)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                        
                        // Image picker placeholder
                        VStack(alignment: .leading) {
                            Text("Photos")
                                .font(DesignSystem.Typography.sectionTitle)
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: DesignSystem.Spacing.small) {
                                    Button(action: {}) {
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                            .fill(DesignSystem.Colors.terracotta.opacity(0.1))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Image(systemName: "plus")
                                                    .foregroundColor(DesignSystem.Colors.terracotta)
                                            )
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Tell Your Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DesignSystem.Colors.charcoal)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            await viewModel.submitStory()
                            if viewModel.isSuccess {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.canSubmit || viewModel.isLoading)
                    .foregroundColor(DesignSystem.Colors.terracotta)
                }
            }
        }
    }
}

struct UserProfileView: View {
    let userId: String
    
    var body: some View {
        ScrollView {
            VStack {
                Text("User Profile")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.charcoal)
                
                Text("ID: \(userId)")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.stone)
            }
            .padding()
        }
        .background(DesignSystem.Colors.warmSand)
    }
}

struct AllStoriesView: View {
    var body: some View {
        Text("All Stories")
            .font(DesignSystem.Typography.largeTitle)
            .background(DesignSystem.Colors.warmSand)
    }
}

struct AddGarmentView: View {
    var body: some View {
        Text("Add Garment")
            .font(DesignSystem.Typography.largeTitle)
            .background(DesignSystem.Colors.warmSand)
    }
}

struct EditGarmentView: View {
    let garmentId: String
    
    var body: some View {
        Text("Edit Garment: \(garmentId)")
            .font(DesignSystem.Typography.largeTitle)
            .background(DesignSystem.Colors.warmSand)
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = ServiceLocator.shared.settingsViewModel()
    
    var body: some View {
        List {
            Section("Preferences") {
                Toggle("Push Notifications", isOn: .init(
                    get: { viewModel.notificationsEnabled },
                    set: { viewModel.updateNotifications(enabled: $0) }
                ))
                
                Toggle("Offline Mode", isOn: .init(
                    get: { viewModel.offlineModeEnabled },
                    set: { viewModel.updateOfflineMode(enabled: $0) }
                ))
            }
            
            Section("Account") {
                Button(action: { viewModel.signOut() }) {
                    Text("Sign Out")
                        .foregroundColor(DesignSystem.Colors.rust)
                }
            }
        }
        .navigationTitle("Settings")
    }
}