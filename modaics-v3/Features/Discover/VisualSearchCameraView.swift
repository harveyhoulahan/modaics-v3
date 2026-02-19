import SwiftUI
import UIKit

// MARK: - VisualSearchCameraView
/// Camera view for visual search / AI-powered garment identification
public struct VisualSearchCameraView: View {
    @Binding var isPresented: Bool
    var onImageSelected: (UIImage) -> Void
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    public init(
        isPresented: Binding<Bool>,
        onImageSelected: @escaping (UIImage) -> Void
    ) {
        self._isPresented = isPresented
        self.onImageSelected = onImageSelected
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 48))
                            .foregroundColor(.luxeGold)
                        
                        Text("VISUAL SEARCH")
                            .font(.forestHeadlineSmall)
                            .foregroundColor(.sageWhite)
                        
                        Text("Take a photo of any garment to find similar items")
                            .font(.forestCaptionMedium)
                            .foregroundColor(.sageMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Camera preview placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.modaicsSurface)
                            .aspectRatio(3/4, contentMode: .fit)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.luxeGold.opacity(0.3), lineWidth: 2)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            )
                        
                        VStack(spacing: 12) {
                            Image(systemName: "tshirt")
                                .font(.system(size: 48))
                                .foregroundColor(.sageMuted)
                            
                            Text("Tap camera to capture")
                                .font(.forestCaptionMedium)
                                .foregroundColor(.sageMuted)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            sourceType = .camera
                            showImagePicker = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                Text("TAKE PHOTO")
                            }
                            .font(.forestHeadlineSmall)
                            .foregroundColor(.modaicsBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.luxeGold)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            sourceType = .photoLibrary
                            showImagePicker = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle")
                                Text("CHOOSE FROM LIBRARY")
                            }
                            .font(.forestHeadlineSmall)
                            .foregroundColor(.sageWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.modaicsSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.sageWhite)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $selectedImage)
                .onDisappear {
                    if let image = selectedImage {
                        onImageSelected(image)
                        isPresented = false
                    }
                }
        }
    }
}

// MARK: - ImagePicker (UIKit wrapper)
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}