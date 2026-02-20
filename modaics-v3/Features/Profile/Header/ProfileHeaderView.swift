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
                .stroke(Color.warmDivider, lineWidth: 0.5)
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
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.nearBlack)
                        .frame(width: 36, height: 36)
                        .background(Color.ivory.opacity(0.9))
                        .clipShape(Circle())
                }
                
                Button(action: { viewModel.isEditing = true }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.nearBlack)
                        .frame(width: 36, height: 36)
                        .background(Color.ivory.opacity(0.9))
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
                .stroke(Color.warmDivider, lineWidth: 1)
        )
    }
    
    private var avatarPlaceholder: some View {
        ZStack {
            Circle()
                .fill(Color.modaicsSurfaceHighlight)
            
            Text(String(viewModel.user.displayName.prefix(1).uppercased()))
                .font(.bodyText(32, weight: .medium))
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
                        .font(.bodyText(20, weight: .medium))
                        .foregroundColor(.sageWhite)
                    
                    // Membership text - simple, not gold, not ALL CAPS
                    Text("Free member")
                        .font(.bodyText(14))
                        .foregroundColor(.warmCharcoal)
                }
                
                Spacer()
                
                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.agedBrass)
                    
                    Text(String(format: "%.1f", viewModel.user.rating))
                        .font(.bodyText(12, weight: .medium))
                        .foregroundColor(.sageWhite)
                    
                    Text("(\(viewModel.user.ratingCount))")
                        .font(.bodyText(11))
                        .foregroundColor(.sageMuted)
                }
            }
            
            // Simple stats text - NO icon boxes
            Text("\(viewModel.user.itemsCirculated) pieces · \(viewModel.user.followingCount) saved")
                .font(.bodyText(13))
                .foregroundColor(.sageMuted)
            
            // Bio
            if !viewModel.user.bio.isEmpty {
                Text(viewModel.user.bio)
                    .font(.bodyText(14))
                    .foregroundColor(.sageWhite)
                    .lineLimit(3)
            } else {
                Text("Tap to add a bio")
                    .font(.bodyText(14))
                    .foregroundColor(.sageMuted)
                    .italic()
            }
            
            // Location and Joined Date
            HStack(spacing: 16) {
                if let location = viewModel.user.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 12))
                            .foregroundColor(.agedBrass)
                        Text("\(location.city), \(location.country)")
                            .font(.bodyText(11))
                            .foregroundColor(.sageMuted)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.agedBrass)
                    Text(viewModel.joinedDateText)
                        .font(.bodyText(11))
                        .foregroundColor(.sageMuted)
                }
            }
            
            // Follow Counts
            HStack(spacing: 24) {
                Button(action: { showFollowingSheet = true }) {
                    HStack(spacing: 4) {
                        Text("\(viewModel.user.followingCount)")
                            .font(.bodyText(14, weight: .medium))
                            .foregroundColor(.sageWhite)
                        Text("Following")
                            .font(.bodyText(12))
                            .foregroundColor(.sageMuted)
                    }
                }
                
                Button(action: { showFollowersSheet = true }) {
                    HStack(spacing: 4) {
                        Text("\(viewModel.user.followerCount)")
                            .font(.bodyText(14, weight: .medium))
                            .foregroundColor(.sageWhite)
                        Text("Followers")
                            .font(.bodyText(12))
                            .foregroundColor(.sageMuted)
                    }
                }
            }
            .padding(.top, 4)
            
            // Style Descriptors - simplified, no gold accents
            if !viewModel.user.styleDescriptors.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.user.styleDescriptors, id: \.self) { descriptor in
                        Text(descriptor)
                            .font(.bodyText(11))
                            .foregroundColor(.sageWhite)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.modaicsSurfaceHighlight)
                            .clipShape(Capsule())
                    }
                    
                    if let aesthetic = viewModel.user.aesthetic {
                        Text(aesthetic.rawValue)
                            .font(.bodyText(11))
                            .foregroundColor(.agedBrass)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.clear)
                            .overlay(
                                Capsule()
                                    .stroke(Color.agedBrass.opacity(0.5), lineWidth: 0.5)
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
                        .font(.bodyText(18, weight: .medium))
                        .foregroundColor(.sageWhite)
                    
                    Text("Coming soon")
                        .font(.bodyText(14))
                        .foregroundColor(.sageMuted)
                    
                    Spacer()
                }
            }
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.bodyText(12, weight: .medium))
                        .foregroundColor(.agedBrass)
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
