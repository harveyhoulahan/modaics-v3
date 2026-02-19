import SwiftUI

// MARK: - CommunityPostCard
/// Modaics-unique post card with industrial/editorial aesthetic
public struct CommunityPostCard: View {
    let post: CommunityPost
    let onLikeTapped: () -> Void
    let onCommentTapped: () -> Void
    let onShareTapped: () -> Void
    let onBookmarkTapped: () -> Void
    let onUserTapped: (() -> Void)?
    let onImageTapped: ((Int) -> Void)?
    let onMoreTapped: (() -> Void)?
    
    @State private var currentImageIndex: Int = 0
    @State private var showFullCaption: Bool = false
    @State private var isLiked: Bool = false
    @State private var likeScale: CGFloat = 1.0
    
    public init(
        post: CommunityPost,
        onLikeTapped: @escaping () -> Void,
        onCommentTapped: @escaping () -> Void,
        onShareTapped: @escaping () -> Void,
        onBookmarkTapped: @escaping () -> Void,
        onUserTapped: (() -> Void)? = nil,
        onImageTapped: ((Int) -> Void)? = nil,
        onMoreTapped: (() -> Void)? = nil
    ) {
        self.post = post
        self.onLikeTapped = onLikeTapped
        self.onCommentTapped = onCommentTapped
        self.onShareTapped = onShareTapped
        self.onBookmarkTapped = onBookmarkTapped
        self.onUserTapped = onUserTapped
        self.onImageTapped = onImageTapped
        self.onMoreTapped = onMoreTapped
        _isLiked = State(initialValue: post.isLiked)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Industrial-style header with type badge
            headerBar
            
            // Editorial image grid (not carousel)
            if !post.imageURLs.isEmpty {
                editorialImageGrid
            }
            
            // Story/Caption section
            storySection
            
            // Sustainability metrics (Modaics unique)
            if post.postType == .thriftFind || post.postType == .sustainabilityTip {
                sustainabilityBadge
            }
            
            // Actions with industrial styling
            industrialActionBar
        }
        .background(
            LinearGradient(
                colors: [Color.modaicsSurface, Color.modaicsSurface.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            Rectangle()
                .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Industrial Header Bar
    private var headerBar: some View {
        HStack(spacing: 0) {
            // Left: User with monospaced styling
            HStack(spacing: 12) {
                // Geometric avatar placeholder
                ZStack {
                    Rectangle()
                        .fill(Color.modaicsSurfaceHighlight)
                        .frame(width: 44, height: 44)
                    
                    Text(post.username.prefix(1).uppercased())
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.luxeGold)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username.uppercased())
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.sageWhite)
                    
                    Text(post.createdAt?.timeAgo().uppercased() ?? "")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.sageMuted)
                }
            }
            
            Spacer()
            
            // Right: Post type badge with industrial styling
            HStack(spacing: 6) {
                Image(systemName: post.postType.icon)
                    .font(.system(size: 12))
                Text(post.postType.rawValue.uppercased())
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
            }
            .foregroundColor(.modaicsBackground)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(hex: post.postType.color))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.modaicsBackground)
    }
    
    // MARK: - Editorial Image Grid
    private var editorialImageGrid: some View {
        let columns = post.imageURLs.count == 1 ? 1 : 2
        let layout = Array(repeating: GridItem(.flexible(), spacing: 2), count: columns)
        
        return LazyVGrid(columns: layout, spacing: 2) {
            ForEach(0..<min(post.imageURLs.count, 4), id: \.self) { index in
                if let url = URL(string: post.imageURLs[index]) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.modaicsSurfaceHighlight)
                                .overlay(
                                    ProgressView()
                                        .tint(Color.luxeGold)
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Rectangle()
                                .fill(Color.modaicsSurfaceHighlight)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.sageMuted)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .onTapGesture {
                        onImageTapped?(index)
                    }
                }
            }
        }
        .frame(height: post.imageURLs.count == 1 ? 400 : 200)
    }
    
    // MARK: - Story Section
    private var storySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Caption with editorial styling
            Text(post.caption)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.sageWhite)
                .lineLimit(showFullCaption ? nil : 3)
                .fixedSize(horizontal: false, vertical: true)
            
            if post.caption.count > 150 {
                Button(action: { withAnimation { showFullCaption.toggle() } }) {
                    Text(showFullCaption ? "LESS" : "READ MORE")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.luxeGold)
                }
            }
            
            // Tags with industrial styling
            if !post.tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(post.tags, id: \.self) { tag in
                        Text("#\(tag.uppercased())")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.sageMuted)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.modaicsSurfaceHighlight)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.luxeGold.opacity(0.3), lineWidth: 0.5)
                            )
                    }
                }
            }
            
            // Location with industrial icon
            if let location = post.location {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                        .foregroundColor(.luxeGold)
                    Text(location.uppercased())
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.sageMuted)
                }
            }
        }
        .padding(16)
    }
    
    // MARK: - Sustainability Badge (Modaics Unique)
    private var sustainabilityBadge: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.modaicsEco)
                Text("CO₂ SAVED: 2.4KG")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.modaicsEco)
            }
            
            Divider()
                .background(Color.modaicsSurfaceHighlight)
            
            HStack(spacing: 6) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.modaicsEco)
                Text("WATER: 1,800L")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.modaicsEco)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.modaicsEco.opacity(0.1))
        .overlay(
            Rectangle()
                .stroke(Color.modaicsEco.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Industrial Action Bar
    private var industrialActionBar: some View {
        HStack(spacing: 0) {
            // Like button with scale animation
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isLiked.toggle()
                    likeScale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation { likeScale = 1.0 }
                }
                onLikeTapped()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isLiked ? .luxeGold : .sageMuted)
                        .scaleEffect(likeScale)
                    
                    Text("\(post.likes + (isLiked ? 1 : 0))")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.sageMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            
            Divider()
                .background(Color.modaicsSurfaceHighlight)
            
            // Comment button
            Button(action: onCommentTapped) {
                HStack(spacing: 6) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 16))
                        .foregroundColor(.sageMuted)
                    
                    Text("\(post.comments.count)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.sageMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            
            Divider()
                .background(Color.modaicsSurfaceHighlight)
            
            // Share button
            Button(action: onShareTapped) {
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 16))
                    .foregroundColor(.sageMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            
            Divider()
                .background(Color.modaicsSurfaceHighlight)
            
            // Bookmark button
            Button(action: onBookmarkTapped) {
                Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 16))
                    .foregroundColor(post.isBookmarked ? .luxeGold : .sageMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .background(Color.modaicsBackground)
        .overlay(
            Rectangle()
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
        )
    }
}