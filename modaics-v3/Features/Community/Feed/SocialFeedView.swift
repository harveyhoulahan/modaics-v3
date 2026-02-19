import SwiftUI

// MARK: - SocialFeedView
/// Main community feed view with collapsable header, filter pills, and post cards
public struct SocialFeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var showLocalHubBanner: Bool = true
    
    private let headerHeight: CGFloat = 110
    private let filterSelectorHeight: CGFloat = 60
    private let collapsedThreshold: CGFloat = 50
    
    private var headerCollapseProgress: CGFloat {
        min(CGFloat(1), max(CGFloat(0), scrollOffset / collapsedThreshold))
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.modaicsBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: FeedScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("feedScroll")).minY)
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    collapsableHeader
                    feedContent
                    Color.clear.frame(height: 100)
                }
            }
            .coordinateSpace(name: "feedScroll")
            .onPreferenceChange(FeedScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
            }
            .refreshable {
                viewModel.loadPosts()
            }
            
            // Floating Action Button
            floatingActionButton
        }
        .sheet(isPresented: $viewModel.showComposeSheet) {
            ComposePostSheet(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadPosts()
        }
    }
    
    // MARK: - Collapsable Header
    private var collapsableHeader: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("COMMUNITY")
                        .font(.forestDisplaySmall)
                        .foregroundColor(.sageWhite)
                        .tracking(2)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.sageMuted)
                    }
                }
                
                Text("Connect with the Modaics community")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(Color.modaicsBackground)
            .frame(height: headerHeight * (CGFloat(1) - headerCollapseProgress * CGFloat(0.5)))
            .opacity(CGFloat(1) - headerCollapseProgress)
            .clipped()
            
            filterSelector
                .frame(height: filterSelectorHeight * (CGFloat(1) - headerCollapseProgress * CGFloat(0.3)))
                .opacity(CGFloat(1) - headerCollapseProgress * CGFloat(0.5))
        }
        .background(Color.modaicsBackground)
    }
    
    // MARK: - Filter Selector
    private var filterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FeedFilter.allCases) { filter in
                    FilterPill(
                        filter: filter,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        viewModel.selectFilter(filter)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .background(Color.modaicsBackground)
    }
    
    // MARK: - Feed Content
    private var feedContent: some View {
        VStack(spacing: 16) {
            // Events Banner (For You only)
            if viewModel.selectedFilter == .forYou && !viewModel.upcomingEvents.isEmpty {
                eventsBanner
            }
            
            // Local Hub Banner
            if viewModel.selectedFilter == .forYou && showLocalHubBanner {
                localHubBanner
            }
            
            // Posts
            if viewModel.isLoading && viewModel.posts.isEmpty {
                loadingPlaceholder
            } else if viewModel.filteredPosts.isEmpty {
                emptyState
            } else {
                postsList
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Events Banner
    private var eventsBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("HAPPENING SOON")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                
                Spacer()
                
                Button(action: {
                    // Navigate to Discover tab
                    // This would typically use a navigation coordinator or tab switch
                }) {
                    HStack(spacing: 4) {
                        Text("SEE ALL")
                            .font(.forestCaptionSmall)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.luxeGold)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.upcomingEvents.prefix(5)) { event in
                        EventBannerCard(event: event)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 12)
        .background(Color.modaicsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Local Hub Banner
    private var localHubBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.luxeGold)
                        Text("MELBOURNE")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.luxeGold)
                    }
                    
                    Text("Sustainable Fashion Hub")
                        .font(.forestHeadlineMedium)
                        .foregroundColor(.sageWhite)
                }
                
                Spacer()
                
                Button(action: { showLocalHubBanner = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.sageMuted)
                }
            }
            
            HStack(spacing: 24) {
                FeedStatItem(value: "12K+", label: "Members")
                FeedStatItem(value: "156", label: "Events")
                FeedStatItem(value: "8.5K", label: "Items")
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.modaicsSurface, Color.modaicsForest.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Posts List
    private var postsList: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.filteredPosts) { post in
                CommunityPostCard(
                    post: post,
                    onLikeTapped: { viewModel.toggleLike(for: post) },
                    onCommentTapped: { viewModel.commentOnPost(post) },
                    onShareTapped: { viewModel.sharePost(post) },
                    onBookmarkTapped: { viewModel.toggleBookmark(for: post) },
                    onUserTapped: {},
                    onImageTapped: { index in
                        print("Image \(index) tapped for post \(post.id)")
                    },
                    onMoreTapped: {}
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Loading Placeholder
    private var loadingPlaceholder: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.modaicsSurface)
                    .frame(height: 400)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.sageSubtle)
            
            Text("NO POSTS YET")
                .font(.forestHeadlineMedium)
                .foregroundColor(.sageWhite)
            
            Text("Be the first to share with the community!")
                .font(.forestCaptionMedium)
                .foregroundColor(.sageMuted)
                .multilineTextAlignment(.center)
            
            Button(action: { viewModel.openComposeSheet() }) {
                Text("CREATE POST")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.modaicsBackground)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.luxeGold)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(minHeight: 400)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { viewModel.openComposeSheet() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.modaicsBackground)
                        .frame(width: 56, height: 56)
                        .background(Color.luxeGold)
                        .clipShape(Circle())
                        .shadow(color: Color.luxeGold.opacity(0.3), radius: 10, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Filter Pill
private struct FilterPill: View {
    let filter: FeedFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(filter.rawValue.uppercased())
                .font(.forestCaptionSmall)
                .foregroundColor(isSelected ? .modaicsBackground : .sageMuted)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.luxeGold : Color.modaicsSurface)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Event Banner Card
private struct EventBannerCard: View {
    let event: CommunityEvent
    
    var body: some View {
        Button(action: {
            // Navigate to event in Discover tab
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Event Image/Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(event.type.swiftColor.opacity(0.2))
                        .frame(width: 140, height: 80)
                    
                    Image(systemName: event.type.icon)
                        .font(.system(size: 32))
                        .foregroundColor(event.type.swiftColor)
                }
                
                // Event Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.forestBodySmall)
                        .foregroundColor(.sageWhite)
                        .lineLimit(1)
                    
                    Text(event.timeUntil.uppercased())
                        .font(.forestCaptionSmall)
                        .foregroundColor(.luxeGold)
                }
            }
            .frame(width: 140)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Feed Stat Item
private struct FeedStatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.forestHeadlineSmall)
                .foregroundColor(.sageWhite)
            Text(label.uppercased())
                .font(.forestCaptionSmall)
                .foregroundColor(.sageMuted)
        }
    }
}

// MARK: - Scroll Offset Preference Key
private struct FeedScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
struct SocialFeedView_Previews: PreviewProvider {
    static var previews: some View {
        SocialFeedView()
    }
}
