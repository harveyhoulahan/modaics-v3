import SwiftUI

// MARK: - Profile Header View
public struct ProfileHeaderView: View {
    @ObservedObject public var viewModel: ProfileHeaderViewModel
    @State private var showFollowersSheet = false
    @State private var showFollowingSheet = false
    
    public init(viewModel: ProfileHeaderViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Cover Image Area
            coverImageArea
            
            // Profile Info
            profileInfoSection
                .padding(.horizontal, 20)
                .padding(.top, 50)
        }
        .background(Color.modaicsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .sheet(isPresented: $viewModel.isEditing) {
            EditProfileView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showFollowersSheet) {
            FollowersSheet(count: viewModel.user.followerCount, type: .followers)
        }
        .sheet(isPresented: $showFollowingSheet) {
            FollowersSheet(count: viewModel.user.followingCount, type: .following)
        }
    }
    
    // MARK: - Cover Image Area
    private var coverImageArea: some View {
        ZStack {
            // Cover background
            if let coverURL = viewModel.user.coverImageURL {
                AsyncImage(url: coverURL) { phase in
                    switch phase {
                    case .empty:
                        coverGradient
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        coverGradient
                    @unknown default:
                        coverGradient
                    }
                }
            } else {
                coverGradient
            }
        }
        .frame(height: 140)
        .clipped()
        .overlay(alignment: .topTrailing) {
            // Action buttons
            HStack(spacing: 12) {
                Button(action: { viewModel.showSettings = true }) {
                    Image(systemName: "gear")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.luxeGold)
                        .frame(width: 36, height: 36)
                        .background(Color.modaicsBackground.opacity(0.8))
                        .clipShape(Circle())
                }
                
                Button(action: { viewModel.isEditing = true }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.sageWhite)
                        .frame(width: 36, height: 36)
                        .background(Color.modaicsBackground.opacity(0.8))
                        .clipShape(Circle())
                }
            }
            .padding(12)
        }
        .overlay(alignment: .bottomLeading) {
            // Avatar
            avatarView
                .offset(x: 20, y: 40)
        }
    }
    
    private var coverGradient: some View {
        LinearGradient(
            colors: [.modaicsPrimary, .modaicsBackground],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Avatar View
    private var avatarView: some View {
        ZStack {
            // Avatar circle
            if let avatarURL = viewModel.user.avatarURL {
                AsyncImage(url: avatarURL) { phase in
                    switch phase {
                    case .empty:
                        avatarPlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        avatarPlaceholder
                    @unknown default:
                        avatarPlaceholder
                    }
                }
            } else {
                avatarPlaceholder
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.modaicsSurface, lineWidth: 3)
        )
        .overlay(
            Circle()
                .stroke(viewModel.isPremium ? Color.luxeGold : Color.clear, lineWidth: 2)
        )
    }
    
    private var avatarPlaceholder: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.modaicsPrimary, .luxeGold.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(String(viewModel.user.displayName.prefix(1).uppercased()))
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.sageWhite)
        }
    }
    
    // MARK: - Profile Info Section
    private var profileInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name and Tier
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.user.displayName)
                        .font(.forestHeadlineMedium)
                        .foregroundColor(.sageWhite)
                    
                    HStack(spacing: 8) {
                        Text("@\(viewModel.user.username)")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                        
                        if !viewModel.tierBadgeText.isEmpty {
                            Text(viewModel.tierBadgeText)
                                .font(.forestCaptionSmall)
                                .fontWeight(.bold)
                                .foregroundColor(.modaicsBackground)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.luxeGold)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                Spacer()
                
                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.luxeGold)
                    
                    Text(String(format: "%.1f", viewModel.user.rating))
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageWhite)
                    
                    Text("(\(viewModel.user.ratingCount))")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageMuted)
                }
            }
            
            // Bio
            if !viewModel.user.bio.isEmpty {
                Text(viewModel.user.bio)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageWhite)
                    .lineLimit(3)
            } else {
                Text("Tap to add a bio")
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageMuted)
                    .italic()
            }
            
            // Location and Joined Date
            HStack(spacing: 16) {
                if let location = viewModel.user.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 12))
                            .foregroundColor(.luxeGold)
                        Text("\(location.city), \(location.country)")
                            .font(.forestCaptionSmall)
                            .foregroundColor(.sageMuted)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.luxeGold)
                    Text(viewModel.joinedDateText)
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageMuted)
                }
            }
            
            // Follow Counts
            HStack(spacing: 24) {
                Button(action: { showFollowingSheet = true }) {
                    HStack(spacing: 4) {
                        Text("\(viewModel.user.followingCount)")
                            .font(.forestBodyMedium)
                            .fontWeight(.bold)
                            .foregroundColor(.sageWhite)
                        Text("Following")
                            .font(.forestCaptionSmall)
                            .foregroundColor(.sageMuted)
                    }
                }
                
                Button(action: { showFollowersSheet = true }) {
                    HStack(spacing: 4) {
                        Text("\(viewModel.user.followerCount)")
                            .font(.forestBodyMedium)
                            .fontWeight(.bold)
                            .foregroundColor(.sageWhite)
                        Text("Followers")
                            .font(.forestCaptionSmall)
                            .foregroundColor(.sageMuted)
                    }
                }
            }
            .padding(.top, 4)
            
            // Style Descriptors
            if !viewModel.user.styleDescriptors.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.user.styleDescriptors, id: \.self) { descriptor in
                        Text(descriptor.uppercased())
                            .font(.forestCaptionSmall)
                            .foregroundColor(.sageWhite)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.modaicsSurfaceHighlight)
                            .clipShape(Capsule())
                    }
                    
                    if let aesthetic = viewModel.user.aesthetic {
                        Text(aesthetic.rawValue.uppercased())
                            .font(.forestCaptionSmall)
                            .foregroundColor(.luxeGold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.clear)
                            .overlay(
                                Capsule()
                                    .stroke(Color.luxeGold, lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }
}

// MARK: - Followers Sheet
private struct FollowersSheet: View {
    let count: Int
    let type: FollowerType
    @Environment(\.dismiss) private var dismiss
    
    enum FollowerType {
        case followers, following
        
        var title: String {
            switch self {
            case .followers: return "Followers"
            case .following: return "Following"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "person.2")
                        .font(.system(size: 60))
                        .foregroundColor(.sageSubtle)
                    
                    Text("\(count) \(type.title)")
                        .font(.forestHeadlineMedium)
                        .foregroundColor(.sageWhite)
                    
                    Text("Coming soon")
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageMuted)
                    
                    Spacer()
                }
            }
            .navigationTitle(type.title.uppercased())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.forestCaptionMedium)
                        .foregroundColor(.luxeGold)
                }
            }
        }
    }
}

// MARK: - Preview
struct ProfileHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileHeaderView(viewModel: ProfileHeaderViewModel())
            .preferredColorScheme(.dark)
    }
}
