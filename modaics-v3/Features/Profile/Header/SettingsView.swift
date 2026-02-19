import SwiftUI

// MARK: - Settings View
public struct SettingsView: View {
    @ObservedObject public var viewModel: ProfileHeaderViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSignOutConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteFinalConfirmation = false
    
    public init(viewModel: ProfileHeaderViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Account Section
                        SettingsSection(title: "Account") {
                            VStack(spacing: 0) {
                                // Email Row
                                SettingsRow {
                                    HStack {
                                        Text("Email")
                                            .font(.forestBodyMedium)
                                            .foregroundColor(.sageWhite)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 6) {
                                            Text(viewModel.user.email)
                                                .font(.forestCaptionMedium)
                                                .foregroundColor(.sageMuted)
                                            
                                            if viewModel.user.isEmailVerified {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.modaicsEco)
                                            }
                                        }
                                    }
                                }
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                // Change Password
                                SettingsNavigationRow(title: "Change Password")
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                // Linked Accounts
                                SettingsNavigationRow(title: "Linked Accounts")
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                // Membership
                                Button(action: { viewModel.showMembershipUpgrade = true }) {
                                    HStack {
                                        Text("Membership")
                                            .font(.forestBodyMedium)
                                            .foregroundColor(.sageWhite)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 6) {
                                            Text(viewModel.user.tier.rawValue.capitalized)
                                                .font(.forestCaptionMedium)
                                                .foregroundColor(.sageMuted)
                                            
                                            Image(systemName: "arrow.up.circle.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(.luxeGold)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            .background(Color.modaicsSurface)
                            .cornerRadius(12)
                        }
                        .sheet(isPresented: $viewModel.showMembershipUpgrade) {
                            MembershipUpgradeView(viewModel: viewModel)
                        }
                        
                        // Notifications Section
                        SettingsSection(title: "Notifications") {
                            VStack(spacing: 0) {
                                ToggleRow(
                                    title: "Push Notifications",
                                    isOn: .constant(true)
                                )
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                ToggleRow(
                                    title: "New Matches",
                                    isOn: .constant(true)
                                )
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                ToggleRow(
                                    title: "Messages",
                                    isOn: .constant(true)
                                )
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                ToggleRow(
                                    title: "Price Drops",
                                    isOn: .constant(true)
                                )
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                ToggleRow(
                                    title: "New Arrivals",
                                    isOn: .constant(false)
                                )
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                ToggleRow(
                                    title: "Exchange Updates",
                                    isOn: .constant(true)
                                )
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                ToggleRow(
                                    title: "Email Notifications",
                                    isOn: .constant(false)
                                )
                            }
                            .background(Color.modaicsSurface)
                            .cornerRadius(12)
                        }
                        
                        // Privacy Section
                        SettingsSection(title: "Privacy") {
                            VStack(spacing: 0) {
                                ToggleRow(
                                    title: "Public Profile",
                                    isOn: .constant(true)
                                )
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                ToggleRow(
                                    title: "Show Wardrobe",
                                    isOn: .constant(true)
                                )
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                ToggleRow(
                                    title: "Show Location",
                                    isOn: .constant(false)
                                )
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                ToggleRow(
                                    title: "Allow Messages",
                                    isOn: .constant(true)
                                )
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                ToggleRow(
                                    title: "Show Activity Status",
                                    isOn: .constant(true)
                                )
                            }
                            .background(Color.modaicsSurface)
                            .cornerRadius(12)
                        }
                        
                        // Preferences Section
                        SettingsSection(title: "Preferences") {
                            VStack(spacing: 0) {
                                SettingsNavigationRow(title: "Currency", value: "AUD")
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                SettingsNavigationRow(title: "Size System", value: "AU")
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                ToggleRow(
                                    title: "Sustainability Filter",
                                    isOn: .constant(false)
                                )
                            }
                            .background(Color.modaicsSurface)
                            .cornerRadius(12)
                        }
                        
                        // Support Section
                        SettingsSection(title: "Support") {
                            VStack(spacing: 0) {
                                SettingsNavigationRow(title: "Help Centre")
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                SettingsNavigationRow(title: "Report a Problem")
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                SettingsNavigationRow(title: "Terms of Service")
                                
                                Divider()
                                    .background(Color.modaicsSurfaceHighlight)
                                
                                SettingsNavigationRow(title: "Privacy Policy")
                            }
                            .background(Color.modaicsSurface)
                            .cornerRadius(12)
                        }
                        
                        // Sign Out
                        Button(action: { showSignOutConfirmation = true }) {
                            Text("Sign Out")
                                .font(.forestBodyMedium)
                                .foregroundColor(.luxeGold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.modaicsSurface)
                                .cornerRadius(12)
                        }
                        
                        // Delete Account
                        Button(action: { showDeleteConfirmation = true }) {
                            Text("Delete Account")
                                .font(.forestBodyMedium)
                                .foregroundColor(.red.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.modaicsSurface)
                                .cornerRadius(12)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.forestCaptionMedium)
                        .foregroundColor(.luxeGold)
                }
            }
            .alert("Sign Out?", isPresented: $showSignOutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    viewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    showDeleteFinalConfirmation = true
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
            .alert("This is Permanent", isPresented: $showDeleteFinalConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Permanently Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteAccount()
                    }
                }
            } message: {
                Text("All your data will be permanently deleted. This cannot be recovered.")
            }
        }
    }
}

// MARK: - Settings Section
private struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.forestCaptionMedium)
                .foregroundColor(.luxeGold)
                .tracking(1)
            
            content
        }
    }
}

// MARK: - Settings Row
private struct SettingsRow<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
    }
}

// MARK: - Settings Navigation Row
private struct SettingsNavigationRow: View {
    let title: String
    var value: String?
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Text(title)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageWhite)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.sageMuted)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Toggle Row
private struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.modaicsEco)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Membership Upgrade View
private struct MembershipUpgradeView: View {
    @ObservedObject var viewModel: ProfileHeaderViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: ModaicsUserTier
    
    init(viewModel: ProfileHeaderViewModel) {
        self.viewModel = viewModel
        _selectedTier = State(initialValue: viewModel.user.tier)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Tier Cards
                    VStack(spacing: 16) {
                        // Free Tier
                        TierCard(
                            tier: .free,
                            price: nil,
                            features: ["Basic marketplace access"],
                            isSelected: selectedTier == .free,
                            isCurrent: viewModel.user.tier == .free
                        ) {
                            selectedTier = .free
                        }
                        
                        // Premium Tier
                        TierCard(
                            tier: .premium,
                            price: "$9.99/mo",
                            features: [
                                "Priority matching",
                                "Advanced analytics",
                                "Custom wardrobe insights",
                                "AI styling suggestions"
                            ],
                            isSelected: selectedTier == .premium,
                            isCurrent: viewModel.user.tier == .premium
                        ) {
                            selectedTier = .premium
                        }
                        
                        // Atelier Tier
                        TierCard(
                            tier: .atelier,
                            price: "$24.99/mo",
                            features: [
                                "Everything in Premium",
                                "Unlimited AI features",
                                "Early access to drops",
                                "Exclusive events"
                            ],
                            isSelected: selectedTier == .atelier,
                            isCurrent: viewModel.user.tier == .atelier
                        ) {
                            selectedTier = .atelier
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Upgrade Button
                    Button(action: upgrade) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(Color.modaicsBackground)
                        } else {
                            Text(selectedTier == viewModel.user.tier ? "Current Plan" : "Upgrade")
                                .font(.forestBodyLarge)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedTier == viewModel.user.tier ? .sageWhite : .modaicsBackground)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedTier == viewModel.user.tier ? Color.modaicsSurface : Color.luxeGold)
                    .cornerRadius(12)
                    .disabled(selectedTier == viewModel.user.tier || viewModel.isLoading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Membership")
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
    
    private func upgrade() {
        Task {
            await viewModel.upgradeMembership(to: selectedTier)
            dismiss()
        }
    }
}

// MARK: - Tier Card
private struct TierCard: View {
    let tier: ModaicsUserTier
    let price: String?
    let features: [String]
    let isSelected: Bool
    let isCurrent: Bool
    let action: () -> Void
    
    private var tierName: String {
        switch tier {
        case .free: return "Free"
        case .premium: return "Premium"
        case .atelier: return "Atelier"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 16) {
                // Selection indicator
                VStack {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.luxeGold)
                    } else {
                        Circle()
                            .stroke(Color.modaicsSurfaceHighlight, lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(tierName)
                            .font(.forestHeadlineMedium)
                            .foregroundColor(.sageWhite)
                        
                        Spacer()
                        
                        if isCurrent {
                            Text("Current")
                                .font(.forestCaptionSmall)
                                .foregroundColor(.modaicsEco)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.modaicsEco.opacity(0.15))
                                .clipShape(Capsule())
                        } else if let price = price {
                            Text(price)
                                .font(.forestCaptionMedium)
                                .foregroundColor(.luxeGold)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(features, id: \.self) { feature in
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10))
                                    .foregroundColor(.modaicsEco)
                                Text(feature)
                                    .font(.forestCaptionSmall)
                                    .foregroundColor(.sageMuted)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.modaicsSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.luxeGold : Color.modaicsSurfaceHighlight, lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: ProfileHeaderViewModel())
            .preferredColorScheme(.dark)
    }
}
