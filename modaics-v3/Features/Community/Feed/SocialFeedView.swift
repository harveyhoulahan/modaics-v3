import SwiftUI

// MARK: - SocialFeedView
public struct SocialFeedView: View {
    @StateObject var viewModel: FeedViewModel
    @State private var selectedFilter: FeedFilter = .forYou

    public init(viewModel: FeedViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? FeedViewModel())
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.canvas.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Sub-filter underline tabs
                    filterStrip
                    Rectangle().fill(Color.hairline).frame(height: 0.5)

                    VStack(spacing: 48) {
                        // "Happening soon" events section
                        if selectedFilter == .forYou && !viewModel.upcomingEvents.isEmpty {
                            happeningSoonSection
                        }

                        // Melbourne editorial card
                        if selectedFilter == .forYou {
                            DSEditorialCard(
                                headline: "Melbourne",
                                subheadline: "Sustainable Fashion Hub",
                                ctaLabel: "Explore hub",
                                variant: .dark
                            )
                            .padding(.horizontal, 20)
                        }

                        // Posts
                        if viewModel.isLoading && viewModel.posts.isEmpty {
                            loadingSkeleton
                        } else if viewModel.filteredPosts.isEmpty {
                            emptyState
                        } else {
                            postsList
                        }
                    }
                    .padding(.top, 32)

                    Color.clear.frame(height: 120)
                }
            }
            .refreshable { viewModel.loadPosts() }

            // FAB
            Button(action: { viewModel.openComposeSheet() }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.canvas)
                    .frame(width: 52, height: 52)
                    .background(Color.inkPrimary)
                    .clipShape(Circle())
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $viewModel.showComposeSheet) {
            ComposePostSheet(viewModel: viewModel)
        }
        .onAppear { viewModel.loadPosts() }
    }

    // MARK: — Filter strip
    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(FeedFilter.allCases) { filter in
                    UnderlineFilter(filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    useBrass: true) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                            viewModel.selectFilter(filter)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color.canvas)
    }

    // MARK: — Happening soon
    private var happeningSoonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionLabel("Happening soon")
                Spacer()
                Button("See all") {}
                    .font(.labelS)
                    .foregroundColor(.brass)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.upcomingEvents.prefix(5)) { event in
                        DSEventCard(event: event, width: 240)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: — Posts list
    private var postsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.filteredPosts) { post in
                CommunityPostCard(
                    post: post,
                    onLikeTapped: { viewModel.toggleLike(for: post) },
                    onCommentTapped: { viewModel.commentOnPost(post) },
                    onShareTapped: { viewModel.sharePost(post) },
                    onBookmarkTapped: { viewModel.toggleBookmark(for: post) }
                )
                Rectangle().fill(Color.hairline).frame(height: 0.5)
            }
        }
    }

    // MARK: — Skeleton
    private var loadingSkeleton: some View {
        VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Circle().fill(Color.canvasSecond).frame(width: 32, height: 32)
                        RoundedRectangle(cornerRadius: 2).fill(Color.canvasSecond).frame(width: 120, height: 12)
                        Spacer()
                    }
                    RoundedRectangle(cornerRadius: 2).fill(Color.canvasSecond).frame(height: 200)
                    RoundedRectangle(cornerRadius: 2).fill(Color.canvasSecond).frame(height: 14)
                    RoundedRectangle(cornerRadius: 2).fill(Color.canvasSecond).frame(width: 160, height: 14)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .shimmering()

                Rectangle().fill(Color.hairline).frame(height: 0.5)
            }
        }
    }

    // MARK: — Empty state
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 60)
            Text("Nothing here yet.")
                .font(.displayS)
                .foregroundColor(.inkPrimary)
            Text("Be the first to share with the community.")
                .font(.bodyM)
                .foregroundColor(.inkMuted)
                .multilineTextAlignment(.center)
            PrimaryCTA("Create post") { viewModel.openComposeSheet() }
                .frame(width: 200)
            Spacer().frame(height: 60)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: — Shimmer helper
private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: phase - 0.3),
                            .init(color: Color.white.opacity(0.25), location: phase),
                            .init(color: .clear, location: phase + 0.3)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width)
                }
                .allowsHitTesting(false)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1.3
                }
            }
    }
}
private extension View {
    func shimmering() -> some View { modifier(ShimmerModifier()) }
}

// MARK: - Preview
struct SocialFeedView_Previews: PreviewProvider {
    static var previews: some View { SocialFeedView() }
}
