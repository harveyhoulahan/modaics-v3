import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showSettings = false
    @State private var showEditProfile = false
    
    let isOwnProfile: Bool
    let userId: String?
    
    init(userId: String? = nil) {
        self.userId = userId
        self.isOwnProfile = userId == nil
    }
    
    var body: some View {
        ZStack {
            // Industrial dark blue background
            Color(red: 0.08, green: 0.12, blue: 0.18)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header with settings button
                    headerBar
                    
                    // User header section
                    userHeaderSection
                    
                    // Stats row
                    statsSection
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.horizontal, 20)
                    
                    // Sustainability stats
                    sustainabilitySection
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.horizontal, 20)
                    
                    // Wardrobe preview
                    wardrobeSection
                }
            }
        }
        .onAppear {
            viewModel.loadProfile(userId: userId)
            viewModel.loadWardrobe(userId: userId)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
    }
    
    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            if !isOwnProfile {
                Button(action: { /* Dismiss */ }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            if isOwnProfile {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            } else {
                Menu {
                    Button("Report User", role: .destructive) {}
                    Button("Block User", role: .destructive) {}
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    // MARK: - User Header Section
    private var userHeaderSection: some View {
        VStack(spacing: 20) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(red: 0.15, green: 0.20, blue: 0.28))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.85, green: 0.20, blue: 0.15), lineWidth: 3)
                    )
                
                if let avatar = viewModel.user.avatar {
                    Image(avatar)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 114, height: 114)
                        .clipShape(Circle())
                } else {
                    Text(viewModel.initials)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                if viewModel.user.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color(red: 0.85, green: 0.20, blue: 0.15))
                        .font(.system(size: 24))
                        .background(Circle().fill(Color(red: 0.08, green: 0.12, blue: 0.18)))
                        .offset(x: 40, y: 40)
                }
            }
            
            // Name and Username
            VStack(spacing: 6) {
                Text(viewModel.user.displayName)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("@\(viewModel.user.username)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.6))
            }
            
            // Bio
            if !viewModel.user.bio.isEmpty {
                Text(viewModel.user.bio)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineLimit(3)
            }
            
            // Location
            if !viewModel.user.location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))
                    Text(viewModel.user.location)
                        .font(.system(size: 12, design: .monospaced))
                }
                .foregroundColor(Color.white.opacity(0.5))
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                if isOwnProfile {
                    Button(action: { showEditProfile = true }) {
                        Text("EDIT PROFILE")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(red: 0.85, green: 0.20, blue: 0.15))
                            )
                    }
                    
                    Button(action: { /* Share profile */ }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                } else {
                    Button(action: { viewModel.toggleFollow() }) {
                        Text(viewModel.isFollowing ? "FOLLOWING" : "FOLLOW")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(viewModel.isFollowing ? .white : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(viewModel.isFollowing ? Color.clear : Color(red: 0.85, green: 0.20, blue: 0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(viewModel.isFollowing ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
                                    )
                            )
                    }
                    
                    Button(action: { /* Message */ }) {
                        Text("MESSAGE")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(value: viewModel.user.itemsSold, label: "SOLD")
            StatItem(value: viewModel.user.itemsBought, label: "BOUGHT")
            StatItem(value: viewModel.user.followers, label: "FOLLOWERS")
            StatItem(value: viewModel.user.following, label: "FOLLOWING")
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Sustainability Section
    private var sustainabilitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(Color(red: 0.40, green: 0.75, blue: 0.40))
                Text("SUSTAINABILITY IMPACT")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.6))
                Spacer()
            }
            
            HStack(spacing: 20) {
                SustainabilityCard(
                    icon: "cloud.co2.fill",
                    value: viewModel.sustainabilityStats.co2Saved,
                    unit: "kg",
                    label: "CO₂ SAVED",
                    color: Color(red: 0.40, green: 0.75, blue: 0.40)
                )
                
                SustainabilityCard(
                    icon: "drop.fill",
                    value: viewModel.sustainabilityStats.waterSaved,
                    unit: "L",
                    label: "WATER SAVED",
                    color: Color(red: 0.20, green: 0.60, blue: 0.90)
                )
                
                SustainabilityCard(
                    icon: "tshirt.fill",
                    value: viewModel.sustainabilityStats.itemsRecirculated,
                    unit: "",
                    label: "ITEMS RECIRCULATED",
                    color: Color(red: 0.85, green: 0.65, blue: 0.20)
                )
            }
        }
        .padding(20)
    }
    
    // MARK: - Wardrobe Section
    private var wardrobeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("WARDROBE")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.6))
                
                Spacer()
                
                Button(action: { /* See all */ }) {
                    Text("SEE ALL →")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.20, blue: 0.15))
                }
            }
            
            if viewModel.wardrobeItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "hanger")
                        .font(.system(size: 40))
                        .foregroundColor(Color.white.opacity(0.3))
                    Text("No items yet")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, minHeight: 150)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(viewModel.wardrobeItems.prefix(6)) { item in
                        WardrobeItemCell(item: item)
                    }
                }
            }
        }
        .padding(20)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Sustainability Card
struct SustainabilityCard: View {
    let icon: String
    let value: Int
    let unit: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }
            
            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.12, green: 0.16, blue: 0.24))
        )
    }
}

// MARK: - Wardrobe Item Cell
struct WardrobeItemCell: View {
    let item: WardrobeItem
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Placeholder for item image
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.15, green: 0.20, blue: 0.28))
                .aspectRatio(0.8, contentMode: .fit)
                .overlay(
                    Image(systemName: item.imageName)
                        .font(.system(size: 32))
                        .foregroundColor(Color.white.opacity(0.3))
                )
            
            // Price badge
            if item.isForSale {
                Text("$")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(red: 0.85, green: 0.20, blue: 0.15))
                    .cornerRadius(2)
                    .padding(6)
            }
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.12, blue: 0.18)
                    .ignoresSafeArea()
                
                Form {
                    Section("PROFILE PHOTO") {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.15, green: 0.20, blue: 0.28))
                                    .frame(width: 100, height: 100)
                                
                                Text(viewModel.initials)
                                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .listRowBackground(Color(red: 0.12, green: 0.16, blue: 0.24))
                    }
                    
                    Section("INFORMATION") {
                        TextField("Display Name", text: $viewModel.user.displayName)
                        TextField("Username", text: $viewModel.user.username)
                        TextField("Bio", text: $viewModel.user.bio)
                        TextField("Location", text: $viewModel.user.location)
                    }
                    .listRowBackground(Color(red: 0.12, green: 0.16, blue: 0.24))
                    
                    Section {
                        Button("Save Changes", role: .none) {
                            viewModel.saveProfile()
                            dismiss()
                        }
                        .foregroundColor(Color(red: 0.85, green: 0.20, blue: 0.15))
                    }
                    .listRowBackground(Color(red: 0.12, green: 0.16, blue: 0.24))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileView()
                .previewDisplayName("Own Profile")
            
            ProfileView(userId: "user_002")
                .previewDisplayName("Other User Profile")
        }
    }
}