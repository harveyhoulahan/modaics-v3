import SwiftUI
import PhotosUI

// MARK: - Edit Profile View
public struct EditProfileView: View {
    @ObservedObject public var viewModel: ProfileHeaderViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAvatarPicker = false
    @State private var showCoverPicker = false
    @State private var showAestheticPicker = false
    @State private var newTagText = ""
    
    public init(viewModel: ProfileHeaderViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Photo Section
                        photoSection
                        
                        // Basic Info Section
                        basicInfoSection
                        
                        // Style Profile Section
                        styleProfileSection
                        
                        // Exchange Preferences Section
                        exchangePreferencesSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("EDIT PROFILE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.sageWhite)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveProfile) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(Color.luxeGold)
                        } else {
                            Text("Save")
                                .font(.forestCaptionMedium)
                                .foregroundColor(.luxeGold)
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .photosPicker(isPresented: $showAvatarPicker, selection: .constant([]), matching: .images)
            .photosPicker(isPresented: $showCoverPicker, selection: .constant([]), matching: .images)
        }
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(spacing: 16) {
            // Avatar
            VStack(spacing: 8) {
                ZStack {
                    if let avatarImage = viewModel.editForm.avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.modaicsPrimary, .luxeGold.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Text(String(viewModel.editForm.displayName.prefix(1).uppercased()))
                                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                                    .foregroundColor(.sageWhite)
                            )
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 2)
                )
                .overlay(
                    Button(action: { showAvatarPicker = true }) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.modaicsBackground)
                            .frame(width: 32, height: 32)
                            .background(Color.luxeGold)
                            .clipShape(Circle())
                    }
                    .offset(x: 35, y: 35)
                )
                
                Text("Change Avatar")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.luxeGold)
            }
            
            // Cover Photo
            Button(action: { showCoverPicker = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 16))
                    Text("Change Cover Photo")
                        .font(.forestCaptionMedium)
                }
                .foregroundColor(.luxeGold)
            }
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Basic Info")
            
            VStack(spacing: 16) {
                // Display Name
                FormField(
                    title: "Display Name",
                    text: $viewModel.editForm.displayName,
                    placeholder: "Your name"
                )
                
                // Username
                HStack(spacing: 0) {
                    Text("@")
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageMuted)
                        .padding(.leading, 12)
                    
                    TextField("username", text: $viewModel.editForm.username)
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageWhite)
                        .padding(12)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                .background(Color.modaicsSurface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
                
                // Bio
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $viewModel.editForm.bio)
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageWhite)
                            .scrollContentBackground(.hidden)
                            .background(Color.modaicsSurface)
                            .frame(height: 100)
                        
                        if viewModel.editForm.bio.isEmpty {
                            Text("Tell us about yourself...")
                                .font(.forestBodyMedium)
                                .foregroundColor(.sageMuted)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                    }
                    .padding(8)
                    .background(Color.modaicsSurface)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                    )
                    
                    HStack {
                        Spacer()
                        Text("\(viewModel.editForm.bio.count)/160")
                            .font(.forestCaptionSmall)
                            .foregroundColor(viewModel.editForm.bio.count > 160 ? .modaicsError : .sageMuted)
                    }
                }
                
                // Location
                FormField(
                    title: "Location",
                    text: $viewModel.editForm.location,
                    placeholder: "City, Country"
                )
            }
        }
    }
    
    // MARK: - Style Profile Section
    private var styleProfileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Style Profile")
            
            VStack(spacing: 16) {
                // Aesthetic Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Aesthetic")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                    
                    Button(action: { showAestheticPicker = true }) {
                        HStack {
                            Text(viewModel.editForm.aesthetic?.rawValue.capitalized ?? "Select aesthetic")
                                .font(.forestBodyMedium)
                                .foregroundColor(viewModel.editForm.aesthetic != nil ? .sageWhite : .sageMuted)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.sageMuted)
                        }
                        .padding(12)
                        .background(Color.modaicsSurface)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                        )
                    }
                }
                .sheet(isPresented: $showAestheticPicker) {
                    AestheticPickerSheet(selected: $viewModel.editForm.aesthetic)
                }
                
                // Style Tags
                VStack(alignment: .leading, spacing: 8) {
                    Text("Style Tags (Max 5)")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(viewModel.editForm.styleDescriptors, id: \.self) { tag in
                            HStack(spacing: 4) {
                                Text(tag)
                                    .font(.forestCaptionSmall)
                                    .foregroundColor(.sageWhite)
                                
                                Button(action: { removeTag(tag) }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10))
                                        .foregroundColor(.sageMuted)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.modaicsSurfaceHighlight)
                            .clipShape(Capsule())
                        }
                        
                        if viewModel.editForm.styleDescriptors.count < 5 {
                            HStack(spacing: 4) {
                                TextField("Add tag", text: $newTagText)
                                    .font(.forestCaptionSmall)
                                    .foregroundColor(.sageWhite)
                                    .frame(width: 80)
                                
                                Button(action: addTag) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12))
                                        .foregroundColor(.luxeGold)
                                }
                                .disabled(newTagText.isEmpty)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.modaicsSurface)
                            .overlay(
                                Capsule()
                                    .stroke(Color.luxeGold.opacity(0.5), lineWidth: 1)
                            )
                            .clipShape(Capsule())
                        }
                    }
                }
                
                // Favorite Colors
                VStack(alignment: .leading, spacing: 8) {
                    Text("Favorite Colors")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                    
                    let colors = [
                        ("Black", "000000"), ("White", "FFFFFF"), ("Grey", "808080"),
                        ("Navy", "000080"), ("Blue", "0000FF"), ("Green", "008000"),
                        ("Olive", "808000"), ("Brown", "8B4513"), ("Beige", "F5F5DC"),
                        ("Cream", "FFFDD0"), ("Tan", "D2B48C"), ("Red", "FF0000")
                    ]
                    
                    FlowLayout(spacing: 12) {
                        ForEach(colors, id: \.0) { color in
                            Button(action: { toggleColor(color.0) }) {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(Color(hex: color.1))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(viewModel.editForm.favoriteColors.contains(color.0) ? Color.luxeGold : Color.clear, lineWidth: 2)
                                        )
                                    
                                    Text(color.0)
                                        .font(.forestCaptionSmall)
                                        .foregroundColor(viewModel.editForm.favoriteColors.contains(color.0) ? .luxeGold : .sageMuted)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Exchange Preferences Section
    private var exchangePreferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Exchange Preferences")
            
            VStack(spacing: 16) {
                // Open to Trade Toggle
                HStack {
                    Text("Open to Trade")
                        .font(.forestBodyMedium)
                        .foregroundColor(.sageWhite)
                    
                    Spacer()
                    
                    Toggle("", isOn: $viewModel.editForm.openToTrade)
                        .tint(.modaicsEco)
                        .labelsHidden()
                }
                
                Divider()
                    .background(Color.modaicsSurfaceHighlight)
                
                // Preferred Types
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferred Exchange Types")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(ModaicsExchangeType.allCases, id: \.self) { type in
                            Button(action: { toggleExchangeType(type) }) {
                                Text(type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .font(.forestCaptionSmall)
                                    .foregroundColor(viewModel.editForm.preferredExchangeTypes.contains(type) ? .modaicsBackground : .sageWhite)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(viewModel.editForm.preferredExchangeTypes.contains(type) ? Color.luxeGold : Color.modaicsSurfaceHighlight)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                // Shipping Preference
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shipping")
                        .font(.forestCaptionMedium)
                        .foregroundColor(.sageMuted)
                    
                    Picker("Shipping", selection: $viewModel.editForm.shippingPreference) {
                        ForEach(ModaicsShippingPreference.allCases, id: \.self) { option in
                            Text(option.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                .tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
    }
    
    // MARK: - Actions
    private func saveProfile() {
        Task {
            let success = await viewModel.saveProfile()
            if success {
                dismiss()
            }
        }
    }
    
    private func addTag() {
        guard !newTagText.isEmpty,
              viewModel.editForm.styleDescriptors.count < 5,
              !viewModel.editForm.styleDescriptors.contains(newTagText) else { return }
        
        viewModel.editForm.styleDescriptors.append(newTagText)
        newTagText = ""
    }
    
    private func removeTag(_ tag: String) {
        viewModel.editForm.styleDescriptors.removeAll { $0 == tag }
    }
    
    private func toggleColor(_ color: String) {
        if viewModel.editForm.favoriteColors.contains(color) {
            viewModel.editForm.favoriteColors.removeAll { $0 == color }
        } else {
            viewModel.editForm.favoriteColors.append(color)
        }
    }
    
    private func toggleExchangeType(_ type: ModaicsExchangeType) {
        if viewModel.editForm.preferredExchangeTypes.contains(type) {
            viewModel.editForm.preferredExchangeTypes.removeAll { $0 == type }
        } else {
            viewModel.editForm.preferredExchangeTypes.append(type)
        }
    }
}

// MARK: - Section Header
private struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(.forestCaptionMedium)
            .foregroundColor(.luxeGold)
            .tracking(1)
    }
}

// MARK: - Form Field
private struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.forestCaptionMedium)
                .foregroundColor(.sageMuted)
            
            TextField(placeholder, text: $text)
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
                .padding(12)
                .background(Color.modaicsSurface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                )
        }
    }
}

// MARK: - Aesthetic Picker Sheet
private struct AestheticPickerSheet: View {
    @Binding var selected: ModaicsAesthetic?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                List {
                    ForEach(ModaicsAesthetic.allCases, id: \.self) { aesthetic in
                        Button(action: {
                            selected = aesthetic
                            dismiss()
                        }) {
                            HStack {
                                Text(aesthetic.rawValue.capitalized)
                                    .font(.forestBodyMedium)
                                    .foregroundColor(.sageWhite)
                                
                                Spacer()
                                
                                if selected == aesthetic {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.luxeGold)
                                }
                            }
                        }
                        .listRowBackground(Color.modaicsSurface)
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.modaicsBackground)
            }
            .navigationTitle("Select Aesthetic")
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
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(viewModel: ProfileHeaderViewModel())
            .preferredColorScheme(.dark)
    }
}
