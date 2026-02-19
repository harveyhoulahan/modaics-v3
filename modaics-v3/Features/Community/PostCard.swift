import SwiftUI

struct PostCard: View {
    let post: CommunityPost
    let onLike: () -> Void
    let onComment: () -> Void
    
    // Industrial Design Colors
    private let backgroundColor = Color(red: 0.10, green: 0.12, blue: 0.18)
    private let accentRed = Color(red: 0.85, green: 0.20, blue: 0.18)
    private let borderColor = Color(red: 0.20, green: 0.22, blue: 0.28)
    private let textPrimary = Color.white
    private let textSecondary = Color(white: 0.6)
    private let textTertiary = Color(white: 0.4)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(post.user.isBrand ? accentRed.opacity(0.2) : borderColor)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: post.user.avatar)
                        .font(.system(size: 20))
                        .foregroundColor(post.user.isBrand ? accentRed : textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(post.user.name.uppercased())
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundColor(textPrimary)
                        
                        if post.user.isBrand {
                            Text("BRAND")
                                .font(.system(.caption2, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(accentRed)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(accentRed.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(timeAgo(from: post.timestamp))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(textTertiary)
                }
                
                Spacer()
                
                // More options
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(textSecondary)
                        .rotationEffect(.degrees(90))
                }
            }
            
            // Content
            Text(post.content)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(textPrimary)
                .lineSpacing(4)
            
            // Images
            if !post.images.isEmpty {
                imageGrid
            }
            
            // Actions
            HStack(spacing: 20) {
                // Like Button
                Button(action: onLike) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(post.isLiked ? accentRed : textSecondary)
                        
                        Text("\(post.likes)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(post.isLiked ? accentRed : textSecondary)
                    }
                }
                
                // Comment Button
                Button(action: onComment) {
                    HStack(spacing: 6) {
                        Image(systemName: "message")
                            .font(.system(size: 16))
                            .foregroundColor(textSecondary)
                        
                        Text("\(post.comments)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(textSecondary)
                    }
                }
                
                Spacer()
                
                // Share Button
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                        .foregroundColor(textSecondary)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
        .cornerRadius(12)
    }
    
    private var imageGrid: some View {
        Group {
            if post.images.count == 1 {
                // Single image
                RoundedRectangle(cornerRadius: 8)
                    .fill(borderColor)
                    .frame(height: 240)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(textTertiary)
                    )
            } else if post.images.count == 2 {
                // Two images
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(borderColor)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(textTertiary)
                            )
                    }
                }
                .frame(height: 180)
            } else {
                // Three or more images
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(borderColor)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(textTertiary)
                            )
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(borderColor)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(textTertiary)
                            )
                    }
                    .frame(height: 120)
                    
                    if post.images.count > 2 {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(borderColor)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 24))
                                        .foregroundColor(textTertiary)
                                )
                            
                            if post.images.count > 3 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(borderColor)
                                    
                                    Text("+\(post.images.count - 3)")
                                        .font(.system(.headline, design: .monospaced))
                                        .foregroundColor(textPrimary)
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(borderColor)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.system(size: 24))
                                            .foregroundColor(textTertiary)
                                    )
                            }
                        }
                        .frame(height: 120)
                    }
                }
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview
struct PostCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.06, green: 0.08, blue: 0.14)
                .ignoresSafeArea()
            
            PostCard(
                post: CommunityPost(
                    id: UUID(),
                    user: User(id: UUID(), name: "VintageFinds", avatar: "person.circle.fill", isBrand: false),
                    content: "Just found this incredible 1960s Type II jacket at the flea market. The fades on this are unreal!",
                    images: ["jacket1", "jacket2"],
                    likes: 247,
                    comments: 42,
                    timestamp: Date().addingTimeInterval(-3600),
                    isLiked: false,
                    isSketchbook: false
                ),
                onLike: {},
                onComment: {}
            )
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
