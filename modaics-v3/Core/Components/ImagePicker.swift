import SwiftUI
import PhotosUI

// MARK: - ImagePicker
/// Component for picking and managing multiple images
public struct ImagePicker: View {
    @Binding var selectedImages: [UIImage]
    @Binding var heroImageIndex: Int
    let maxImages: Int
    let onImagesSelected: (() -> Void)?
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var showSourceSheet = false
    
    public init(
        selectedImages: Binding<[UIImage]>,
        heroImageIndex: Binding<Int> = .constant(0),
        maxImages: Int = 8,
        onImagesSelected: (() -> Void)? = nil
    ) {
        self._selectedImages = selectedImages
        self._heroImageIndex = heroImageIndex
        self.maxImages = maxImages
        self.onImagesSelected = onImagesSelected
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("IMAGES (\(selectedImages.count)/\(maxImages))")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
                
                Spacer()
                
                if !selectedImages.isEmpty {
                    Text("TAP TO SET HERO")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.luxeGold.opacity(0.7))
                        .tracking(0.5)
                }
            }
            
            // Image grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Existing images
                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                    ImageThumbnail(
                        image: image,
                        isHero: index == heroImageIndex,
                        onTap: {
                            heroImageIndex = index
                        },
                        onDelete: {
                            withAnimation {
                                selectedImages.remove(at: index)
                                if heroImageIndex >= selectedImages.count {
                                    heroImageIndex = max(0, selectedImages.count - 1)
                                }
                            }
                        }
                    )
                }
                
                // Add button
                if selectedImages.count < maxImages {
                    AddImageButton {
                        showSourceSheet = true
                    }
                }
            }
        }
        .confirmationDialog("ADD PHOTO", isPresented: $showSourceSheet, titleVisibility: .visible) {
            Button("PHOTO LIBRARY") {
                // PhotosPicker is shown via the .photosPicker modifier
            }
            Button("CAMERA") {
                showCamera = true
            }
            Button("CANCEL", role: .cancel) { }
        }
        .photosPicker(
            isPresented: Binding(
                get: { showSourceSheet },
                set: { if !$0 { showSourceSheet = false } }
            ),
            selection: $selectedItems,
            maxSelectionCount: maxImages - selectedImages.count,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedItems) { newItems in
            Task {
                var newImages: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        newImages.append(image)
                    }
                }
                await MainActor.run {
                    selectedImages.append(contentsOf: newImages)
                    selectedItems = []
                    onImagesSelected?()
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                if let image = image {
                    selectedImages.append(image)
                    onImagesSelected?()
                }
                showCamera = false
            }
        }
    }
}

// MARK: - Image Thumbnail
struct ImageThumbnail: View {
    let image: UIImage
    let isHero: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isHero ? Color.luxeGold : Color.clear, lineWidth: 2)
                )
                .onTapGesture {
                    onTap()
                }
            
            // Hero badge
            if isHero {
                Text("HERO")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.modaicsBackground)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.luxeGold)
                    .cornerRadius(4)
                    .padding(6)
            }
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.modaicsError)
                    .background(Circle().fill(Color.modaicsBackground))
            }
            .offset(x: 6, y: -6)
        }
    }
}

// MARK: - Add Image Button
struct AddImageButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                Text("ADD")
                    .font(.forestCaptionSmall)
            }
            .foregroundColor(.luxeGold)
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color.modaicsSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.luxeGold.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
            .cornerRadius(8)
        }
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage?) -> Void
        
        init(onCapture: @escaping (UIImage?) -> Void) {
            self.onCapture = onCapture
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            onCapture(image)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCapture(nil)
        }
    }
}

// MARK: - Single Image Picker
public struct SingleImagePicker: View {
    @Binding var image: UIImage?
    let placeholder: String
    let onImageSelected: (() -> Void)?
    
    @State private var showSourceSheet = false
    @State private var showCamera = false
    @State private var selectedItem: PhotosPickerItem?
    
    public init(
        image: Binding<UIImage?>,
        placeholder: String = "SELECT IMAGE",
        onImageSelected: (() -> Void)? = nil
    ) {
        self._image = image
        self.placeholder = placeholder
        self.onImageSelected = onImageSelected
    }
    
    public var body: some View {
        Button(action: { showSourceSheet = true }) {
            ZStack {
                Rectangle()
                    .fill(Color.modaicsSurface)
                    .aspectRatio(1, contentMode: .fit)
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .layoutPriority(-1)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "camera")
                            .font(.system(size: 32))
                        Text(placeholder)
                            .font(.forestCaptionMedium)
                    }
                    .foregroundColor(.sageMuted)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
            )
        }
        .confirmationDialog("ADD PHOTO", isPresented: $showSourceSheet, titleVisibility: .visible) {
            Button("PHOTO LIBRARY") {
                // Handled by photosPicker
            }
            Button("CAMERA") {
                showCamera = true
            }
            Button("CANCEL", role: .cancel) { }
        }
        .photosPicker(
            isPresented: Binding(
                get: { showSourceSheet },
                set: { if !$0 { showSourceSheet = false } }
            ),
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let newImage = UIImage(data: data) {
                    await MainActor.run {
                        image = newImage
                        selectedItem = nil
                        onImageSelected?()
                    }
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView { capturedImage in
                if let capturedImage = capturedImage {
                    image = capturedImage
                    onImageSelected?()
                }
                showCamera = false
            }
        }
    }
}
