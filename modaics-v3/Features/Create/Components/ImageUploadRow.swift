import SwiftUI
import PhotosUI

// MARK: - ImageUploadRow
/// Horizontal scrolling image picker with Cover badge, + button, and ✕ remove
public struct ImageUploadRow: View {
    @Binding var images: [UIImage]
    @Binding var heroImageIndex: Int
    let maxImages: Int
    let onImagesSelected: (() -> Void)?
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var showSourceSheet = false
    
    public init(
        images: Binding<[UIImage]>,
        heroImageIndex: Binding<Int> = .constant(0),
        maxImages: Int = 8,
        onImagesSelected: (() -> Void)? = nil
    ) {
        self._images = images
        self._heroImageIndex = heroImageIndex
        self.maxImages = maxImages
        self.onImagesSelected = onImagesSelected
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with count
            HStack {
                Text("IMAGES (\(images.count)/\(maxImages))")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .tracking(1)
                
                Spacer()
                
                if !images.isEmpty {
                    Text("DRAG TO REORDER • TAP ✕ TO REMOVE")
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageSubtle)
                        .tracking(0.5)
                }
            }
            
            // Horizontal scroll row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Existing images
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        HorizontalImageThumbnail(
                            image: image,
                            isCover: index == heroImageIndex,
                            index: index,
                            onTap: {
                                heroImageIndex = index
                            },
                            onDelete: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    images.remove(at: index)
                                    if heroImageIndex >= images.count {
                                        heroImageIndex = max(0, images.count - 1)
                                    }
                                }
                            }
                        )
                    }
                    
                    // Add button
                    if images.count < maxImages {
                        HorizontalAddButton {
                            showSourceSheet = true
                        }
                    }
                }
                .padding(.horizontal, 1) // Prevent clipping from shadows
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
            maxSelectionCount: maxImages - images.count,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedItems) { _, newItems in
            Task {
                var newImages: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        newImages.append(image)
                    }
                }
                await MainActor.run {
                    images.append(contentsOf: newImages)
                    selectedItems = []
                    onImagesSelected?()
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraViewWrapper { image in
                if let image = image {
                    images.append(image)
                    onImagesSelected?()
                }
                showCamera = false
            }
        }
    }
}

// MARK: - Horizontal Image Thumbnail
struct HorizontalImageThumbnail: View {
    let image: UIImage
    let isCover: Bool
    let index: Int
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Image
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCover ? Color.luxeGold : Color.modaicsSurfaceHighlight, lineWidth: isCover ? 2 : 1)
                )
                .onTapGesture {
                    onTap()
                }
            
            // Cover badge
            if isCover {
                VStack {
                    HStack {
                        Text("COVER")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.modaicsBackground)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.luxeGold)
                            .clipShape(Capsule())
                        
                        Spacer()
                    }
                    .padding(6)
                    
                    Spacer()
                }
            }
            
            // Delete button
            Button(action: onDelete) {
                ZStack {
                    Circle()
                        .fill(Color.modaicsBackground)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.sageWhite)
                }
            }
            .offset(x: 8, y: -8)
        }
        .frame(width: 100, height: 100)
    }
}

// MARK: - Horizontal Add Button
struct HorizontalAddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .medium))
                Text("ADD")
                    .font(.forestCaptionSmall)
                    .tracking(0.5)
            }
            .foregroundColor(.luxeGold)
            .frame(width: 100, height: 100)
            .background(Color.modaicsSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.luxeGold.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
            .cornerRadius(12)
        }
    }
}

// MARK: - Camera View Wrapper
struct CameraViewWrapper: UIViewControllerRepresentable {
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
