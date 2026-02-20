import CoreML
import Vision
import UIKit

// MARK: - MobileCLIP Service
/// On-device CLIP inference using CoreML for instant feedback
class MobileCLIPService {
    private var imageEncoder: VNCoreMLModel?
    private let modelURL: URL
    
    init() {
        // Model path - would be bundled in app
        self.modelURL = Bundle.main.url(forResource: "MobileCLIP_S2_ImageEncoder", withExtension: "mlmodelc")
            ?? Bundle.main.url(forResource: "MobileCLIP_S2_ImageEncoder", withExtension: "mlpackage")!
    }
    
    /// Initialize the CoreML model
    func initialize() async throws {
        let config = MLModelConfiguration()
        config.computeUnits = .all  // Use Neural Engine when available
        
        let model = try await MLModel.load(contentsOf: modelURL, configuration: config)
        self.imageEncoder = try VNCoreMLModel(for: model)
    }
    
    /// Encode image to 512-dimensional vector (< 100ms on iPhone 12+)
    func encodeImage(_ image: UIImage) async throws -> [Float] {
        guard let cgImage = image.cgImage else {
            throw MLError.invalidImage
        }
        
        guard let model = imageEncoder else {
            throw MLError.modelNotInitialized
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                      let multiArray = results.first?.featureValue.multiArrayValue else {
                    continuation.resume(throwing: MLError.noResults)
                    return
                }
                
                // Extract 512-dimensional embedding
                let embedding = (0..<multiArray.count).map { Float(truncating: multiArray[$0]) }
                continuation.resume(returning: embedding)
            }
            
            request.imageCropAndScaleOption = .centerCrop
            
            let handler = VNImageRequestHandler(cgImage: cgImage)
            try? handler.perform([request])
        }
    }
    
    /// Calculate similarity between two embeddings (cosine similarity)
    func calculateSimilarity(embedding1: [Float], embedding2: [Float]) -> Float {
        let dotProduct = zip(embedding1, embedding2).map(*).reduce(0, +)
        let norm1 = sqrt(embedding1.map { $0 * $0 }.reduce(0, +))
        let norm2 = sqrt(embedding2.map { $0 * $0 }.reduce(0, +))
        return dotProduct / (norm1 * norm2)
    }
}

// MARK: - Errors
enum MLError: Error {
    case invalidImage
    case modelNotInitialized
    case noResults
    case encodingFailed
}

// MARK: - Performance Metrics
struct CLIPPerformanceMetrics {
    let inferenceTimeMs: Double
    let usedNeuralEngine: Bool
}
