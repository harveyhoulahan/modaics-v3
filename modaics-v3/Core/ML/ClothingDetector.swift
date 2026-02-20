import Vision
import UIKit

// MARK: - Clothing Detection Models
struct DetectedClothingItem {
    let category: ClothingCategory
    let confidence: Float
    let boundingBox: CGRect  // Normalized coordinates (0-1)
}

enum ClothingCategory: String, CaseIterable {
    case tshirt = "t-shirt"
    case dress = "dress"
    case jacket = "jacket"
    case jeans = "jeans"
    case skirt = "skirt"
    case sweater = "sweater"
    case coat = "coat"
    case blouse = "blouse"
    case shorts = "shorts"
    case hoodie = "hoodie"
    case trousers = "trousers"
    case suit = "suit"
    case cardigan = "cardigan"
    case shoes = "shoes"
    case bag = "bag"
    case hat = "hat"
    case scarf = "scarf"
    
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Clothing Detector
/// YOLOv8n-based clothing detection with bounding boxes
class ClothingDetector {
    private var model: VNCoreMLModel?
    private let confidenceThreshold: Float = 0.5
    
    init() {}
    
    /// Initialize with YOLOv8n CoreML model
    func initialize() throws {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        
        // Load YOLOv8n model (exported from PyTorch)
        guard let modelURL = Bundle.main.url(forResource: "YOLOv8n_Clothing", withExtension: "mlmodelc") else {
            throw DetectionError.modelNotFound
        }
        
        let yoloModel = try MLModel(contentsOf: modelURL, configuration: config)
        self.model = try VNCoreMLModel(for: yoloModel)
    }
    
    /// Detect clothing items in image (< 50ms)
    func detect(in image: UIImage) async throws -> [DetectedClothingItem] {
        guard let cgImage = image.cgImage else {
            throw DetectionError.invalidImage
        }
        
        guard let model = model else {
            throw DetectionError.modelNotInitialized
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                guard let self = self else { return }
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let items = results.compactMap { observation -> DetectedClothingItem? in
                    guard let label = observation.labels.first,
                          label.confidence >= self.confidenceThreshold,
                          let category = ClothingCategory(rawValue: label.identifier) else {
                        return nil
                    }
                    
                    return DetectedClothingItem(
                        category: category,
                        confidence: label.confidence,
                        boundingBox: observation.boundingBox
                    )
                }
                
                continuation.resume(returning: items)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage)
            try? handler.perform([request])
        }
    }
    
    /// Get the dominant/focal clothing item (largest bounding box)
    func getDominantItem(from items: [DetectedClothingItem]) -> DetectedClothingItem? {
        return items.max { $0.boundingBox.area < $1.boundingBox.area }
    }
}

// MARK: - Errors
enum DetectionError: Error {
    case modelNotFound
    case modelNotInitialized
    case invalidImage
}

// MARK: - CGRect Extension
private extension CGRect {
    var area: CGFloat {
        width * height
    }
}

// MARK: - Overlay Helper
extension ClothingDetector {
    /// Generate overlay view with bounding boxes for camera preview
    func generateOverlayView(for image: UIImage, detections: [DetectedClothingItem]) -> UIView {
        let overlayView = UIView(frame: CGRect(origin: .zero, size: image.size))
        overlayView.backgroundColor = .clear
        
        for detection in detections {
            let boxView = createBoundingBoxView(for: detection, in: image.size)
            overlayView.addSubview(boxView)
        }
        
        return overlayView
    }
    
    private func createBoundingBoxView(for detection: DetectedClothingItem, in imageSize: CGSize) -> UIView {
        // Convert normalized coordinates to image coordinates
        let rect = CGRect(
            x: detection.boundingBox.origin.x * imageSize.width,
            y: (1 - detection.boundingBox.origin.y - detection.boundingBox.height) * imageSize.height,
            width: detection.boundingBox.width * imageSize.width,
            height: detection.boundingBox.height * imageSize.height
        )
        
        let boxView = UIView(frame: rect)
        boxView.layer.borderColor = UIColor.luxeGold.cgColor
        boxView.layer.borderWidth = 2
        boxView.backgroundColor = UIColor.luxeGold.withAlphaComponent(0.1)
        
        // Add label
        let label = UILabel()
        label.text = "\(detection.category.displayName) (\(Int(detection.confidence * 100))%)"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .modaicsBackground
        label.backgroundColor = .luxeGold
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 0, y: -label.frame.height)
        boxView.addSubview(label)
        
        return boxView
    }
}
