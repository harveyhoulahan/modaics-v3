import SwiftUI
import PhotosUI

// MARK: - ComposePostSheet
/// Sheet for composing a new community post
public struct ComposePostSheet: View {
    @ObservedObject var viewModel: FeedViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showImagePicker: Bool = false
    @State private var showLocationPicker: Bool = false
    @State private var showLinkItemPicker: Bool = false
    
    public init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Post Type Selector
                        postTypeSelector
                        
                        Divider()
                            .background(Color.modaicsSurfaceHighlight)
                        
                        // Image Selector
                        imageSelectorSection
                        
                        Divider()
                            .background(Color.modaicsSurfaceHighlight)
                            .padding(.top, 16)
                        
                        // Caption Input
                        captionSection
                        
                        Divider()
                            .background(Color.modaicsSurfaceHighlight)
                            .padding(.top, 16)
                        
                        // Tags Input
                        tagsSection
                        
                        Divider()
                            .background(Color.modaicsSurfaceHighlight)
                            .padding(.top, 16)
                        
                        // Location Toggle
                        locationSection
                        
                        Divider()
                            .background(Color.modaicsSurfaceHighlight)
                        
                        // Link Item Toggle
                        linkItemSection
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("NEW POST")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("CANCEL")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.createPost()
                    }) {
                        if viewModel.isComposing {
                            ProgressView()
                                .tint(Color.luxeGold)
                        } else {
                            Text("POST")
                                .font(.forestCaptionMedium)
                                .foregroundColor(viewModel.canCreatePost ? Color.luxeGold : Color.sageMuted)
                        }
                    }
                    .disabled(!viewModel.canCreatePost || viewModel.isComposing)
                }
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            viewModel.addImage(image)
                        }
                    }
                }
                selectedItems = []
            }
        }
    }
    
    // MARK: - Post Type Selector
    private var postTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("POST TYPE")
                .font(.forestCaptionMedium)
                .foregroundColor(.sageMuted)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PostType.allCases) { type in
                        PostTypeButton(
                            type: type,
                            isSelected: viewModel.composePostType == type
                        ) {
                            viewModel.selectPostType(type)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Image Selector Section
    private var imageSelectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PHOTOS")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                
                Spacer()
                
                Text("\(viewModel.composeImages.count)/4")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageSubtle)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Add Button
                    if viewModel.composeImages.count < 4 {
                        PhotosPicker(selection: $selectedItems,
                                   maxSelectionCount: 4 - viewModel.composeImages.count,
                                   matching: .images) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.modaicsSurface)
                                    .frame(width: 100, height: 100)
                                
                                VStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 24))
                                        .foregroundColor(.sageMuted)
                                    Text("ADD")
                                        .font(.forestCaptionSmall)
                                        .foregroundColor(.sageMuted)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.modaicsSurfaceHighlight, style: StrokeStyle(lineWidth: 1, dash: [6]))
                            )
                        }
                    }
                    
                    // Selected Images
                    ForEach(0..<viewModel.composeImages.count, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: viewModel.composeImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Button(action: {
                                viewModel.removeImage(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.sageWhite)
                                    .background(Color.modaicsBackground.opacity(0.8))
                                    .clipShape(Circle())
                            }
                            .offset(x: 6, y: -6)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Caption Section
    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CAPTION")
                .font(.forestCaptionMedium)
                .foregroundColor(.sageMuted)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            TextEditor(text: $viewModel.composeCaption)
                .font(.forestBodyMedium)
                .foregroundColor(.sageWhite)
                .scrollContentBackground(.hidden)
                .background(Color.modaicsBackground)
                .frame(minHeight: 100)
                .padding(.horizontal, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                        .padding(.horizontal, 16)
                )
                .overlay(
                    Group {
                        if viewModel.composeCaption.isEmpty {
                            VStack {
                                HStack {
                                    Text("What's on your mind?")
                                        .font(.forestBodyMedium)
                                        .foregroundColor(.sageMuted)
                                        .padding(.top, 8)
                                        .padding(.leading, 20)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }
                )
                .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TAGS")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                
                Spacer()
                
                Text("Separate with spaces")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageSubtle)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            HStack {
                TextField("", text: $viewModel.composeTags)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageWhite)
                    .placeholder(when: viewModel.composeTags.isEmpty) {
                        Text("sustainable thrifting vintage...")
                            .font(.forestBodyMedium)
                            .foregroundColor(.sageMuted)
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.modaicsSurface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
            )
            .padding(.horizontal, 16)
            
            // Tag Preview
            if !viewModel.composeTagsArray.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.composeTagsArray, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.forestCaptionMedium)
                            .foregroundColor(Color.luxeGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.luxeGold.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Location Section
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "mappin")
                        .font(.system(size: 18))
                        .foregroundColor(.sageMuted)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("LOCATION")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                        
                        if viewModel.composeLocation.isEmpty {
                            Text("Add location (optional)")
                                .font(.forestBodySmall)
                                .foregroundColor(.sageSubtle)
                        } else {
                            Text(viewModel.composeLocation)
                                .font(.forestBodySmall)
                                .foregroundColor(.sageWhite)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                if viewModel.composeLocation.isEmpty {
                    Button(action: { showLocationPicker = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                            .foregroundColor(.sageMuted)
                    }
                } else {
                    Button(action: { viewModel.composeLocation = "" }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundColor(.sageMuted)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerSheet(location: $viewModel.composeLocation)
        }
    }
    
    // MARK: - Link Item Section
    private var linkItemSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "link")
                        .font(.system(size: 18))
                        .foregroundColor(.sageMuted)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("LINK ITEM")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                        
                        if viewModel.composeLinkedItem == nil {
                            Text("Link a garment or event (optional)")
                                .font(.forestBodySmall)
                                .foregroundColor(.sageSubtle)
                        } else if let item = viewModel.composeLinkedItem {
                            Text(item.title)
                                .font(.forestBodySmall)
                                .foregroundColor(.sageWhite)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                if viewModel.composeLinkedItem == nil {
                    Button(action: { showLinkItemPicker = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                            .foregroundColor(.sageMuted)
                    }
                } else {
                    Button(action: { viewModel.composeLinkedItem = nil }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundColor(.sageMuted)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .sheet(isPresented: $showLinkItemPicker) {
            LinkItemPickerSheet(linkedItem: $viewModel.composeLinkedItem)
        }
    }
}

// MARK: - Post Type Button
private struct PostTypeButton: View {
    let type: PostType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 12))
                Text(type.rawValue.uppercased())
                    .font(.forestCaptionSmall)
            }
            .foregroundColor(isSelected ? .modaicsBackground : Color(hex: type.color))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: type.color) : Color(hex: type.color).opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color(hex: type.color).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Flow Layout
