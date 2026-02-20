import UIKit
import Combine

// MARK: - On-Device Classification Result
struct OnDeviceClassificationResult {
    let category: String?
    let categoryConfidence: Float
    let boundingBox: CGRect?
    let embedding: [Float]?
    let labelInfo: LabelOCRResult?
    let processingTimeMs: Double
}

// MARK: - Full Classification Result (On-Device + Server)
struct FullClassificationResult {
    let onDeviceResult: OnDeviceClassificationResult
    let serverResult: ServerAnalysisResult?
    let mergedAttributes: MergedAttributes
    let confidence: Float
}

struct ServerAnalysisResult {
    let category: [AttributePrediction]
    let color: [AttributePrediction]
    let material: [AttributePrediction]
    let condition: [AttributePrediction]
    let style: [AttributePrediction]
    let detectedColors: [ExtractedColor]
    let conditionGrade: ConditionGradeResult
    let embedding: [Float]
    let estimatedPrice: EstimatedPrice
    let sustainabilityScore: Int
    let suggestions: [String]
}

struct MergedAttributes {
    let category: String
    let colors: [String]
    let materials: [String]
    let condition: String
    let style: String
    let size: String?
    let brand: String?
}

struct AttributePrediction {
    let label: String
    let confidence: Float
}

struct ExtractedColor {
    let name: String
    let hex: String
    let rgb: [Int]
    let percentage: Float
}

struct ConditionGradeResult {
    let grade: String
    let label: String
    let confidence: Float
    let description: String
}

struct EstimatedPrice {
    let min: Double
    let max: Double
    let currency: String
    let confidence: String
}

// MARK: - On-Device Classifier
/// Orchestrates all on-device ML models for instant garment classification
@MainActor
class OnDeviceClassifier: ObservableObject {
    
    // MARK: - Services
    private let clipService: MobileCLIPService
    private let detector: ClothingDetector
    private let ocr: LabelOCR
    
    // MARK: - State
    @Published var isProcessing = false
    @Published var lastResult: OnDeviceClassificationResult?
    
    init() {
        self.clipService = MobileCLIPService()
        self.detector = ClothingDetector()
        self.ocr = LabelOCR()
    }
    
    /// Initialize all models
    func initialize() async throws {
        try await clipService.initialize()
        try detector.initialize()
        // OCR uses Vision framework, no explicit init needed
    }
    
    // MARK: - Instant Classification (< 150ms total)
    
    func classifyInstant(image: UIImage, includeOCR: Bool = false) async throws -> OnDeviceClassificationResult {
        isProcessing = true
        defer { isProcessing = false }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Run detection and embedding in parallel
        async let detectionTask = detector.detect(in: image)
        async let embeddingTask = clipService.encodeImage(image)
        
        let (detections, embedding) = try await (detectionTask, embeddingTask)
        
        // Get dominant detected item
        let dominantItem = detector.getDominantItem(from: detections)
        
        // Optional: Read label if requested
        var labelInfo: LabelOCRResult?
        if includeOCR {
            labelInfo = try? await ocr.readLabel(from: image)
        }
        
        let processingTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        
        let result = OnDeviceClassificationResult(
            category: dominantItem?.category.displayName,
            categoryConfidence: dominantItem?.confidence ?? 0,
            boundingBox: dominantItem?.boundingBox,
            embedding: embedding,
            labelInfo: labelInfo,
            processingTimeMs: processingTime
        )
        
        lastResult = result
        return result
    }
    
    // MARK: - Full Classification (On-Device + Server)
    
    func classifyFull(image: UIImage) async throws -> FullClassificationResult {
        // Get instant on-device result first
        let instantResult = try await classifyInstant(image: image, includeOCR: true)
        
        // Send to server for rich analysis
        let serverResult = try await sendToServer(image: image, onDeviceEmbedding: instantResult.embedding)
        
        // Merge results (server overrides on-device where available)
        let merged = mergeResults(onDevice: instantResult, server: serverResult)
        
        return FullClassificationResult(
            onDeviceResult: instantResult,
            serverResult: serverResult,
            mergedAttributes: merged,
            confidence: calculateMergedConfidence(onDevice: instantResult, server: serverResult)
        )
    }
    
    // MARK: - Server Communication
    
    private func sendToServer(image: UIImage, onDeviceEmbedding: [Float]?) async throws -> ServerAnalysisResult {
        // Convert image to data
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            throw ClassificationError.imageEncodingFailed
        }
        
        // Create multipart request
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "\(APIConfig.baseURL)/api/analyze")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if available
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Build body
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"garment.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Send request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ClassificationError.serverError
        }
        
        // Parse response
        let result = try JSONDecoder().decode(ServerAnalysisResponse.self, from: data)
        
        return ServerAnalysisResult(
            category: result.category.map { AttributePrediction(label: $0.label, confidence: $0.confidence) },
            color: result.color.map { AttributePrediction(label: $0.label, confidence: $0.confidence) },
            material: result.material.map { AttributePrediction(label: $0.label, confidence: $0.confidence) },
            condition: result.condition.map { AttributePrediction(label: $0.label, confidence: $0.confidence) },
            style: result.style.map { AttributePrediction(label: $0.label, confidence: $0.confidence) },
            detectedColors: result.detected_colors.map {
                ExtractedColor(name: $0.name, hex: $0.hex, rgb: $0.rgb, percentage: $0.percentage)
            },
            conditionGrade: ConditionGradeResult(
                grade: result.condition_grade.grade,
                label: result.condition_grade.label,
                confidence: result.condition_grade.confidence,
                description: result.condition_grade.description
            ),
            embedding: result.embedding,
            estimatedPrice: EstimatedPrice(
                min: result.estimated_price.min,
                max: result.estimated_price.max,
                currency: result.estimated_price.currency,
                confidence: result.estimated_price.confidence
            ),
            sustainabilityScore: result.sustainability_score,
            suggestions: result.suggestions
        )
    }
    
    // MARK: - Result Merging
    
    private func mergeResults(onDevice: OnDeviceClassificationResult, server: ServerAnalysisResult?) -> MergedAttributes {
        guard let server = server else {
            return MergedAttributes(
                category: onDevice.category ?? "Unknown",
                colors: [],
                materials: [],
                condition: "Unknown",
                style: "Unknown",
                size: onDevice.labelInfo?.size,
                brand: onDevice.labelInfo?.brand
            )
        }
        
        return MergedAttributes(
            category: server.category.first?.label ?? onDevice.category ?? "Unknown",
            colors: server.color.map { $0.label },
            materials: server.material.map { $0.label },
            condition: server.conditionGrade.label,
            style: server.style.first?.label ?? "Unknown",
            size: onDevice.labelInfo?.size ?? extractSize(from: server),
            brand: onDevice.labelInfo?.brand ?? extractBrand(from: server)
        )
    }
    
    private func calculateMergedConfidence(onDevice: OnDeviceClassificationResult, server: ServerAnalysisResult?) -> Float {
        guard let server = server else {
            return onDevice.categoryConfidence
        }
        
        let serverConfidence = server.category.first?.confidence ?? 0
        return (onDevice.categoryConfidence + serverConfidence) / 2
    }
    
    private func extractSize(from server: ServerAnalysisResult) -> String? {
        // Try to find size in style attributes or tags
        return nil
    }
    
    private func extractBrand(from server: ServerAnalysisResult) -> String? {
        // Try to find brand in style attributes or tags
        return nil
    }
}

// MARK: - API Response Models
private struct ServerAnalysisResponse: Codable {
    let category: [PredictionResponse]
    let color: [PredictionResponse]
    let material: [PredictionResponse]
    let condition: [PredictionResponse]
    let style: [PredictionResponse]
    let detected_colors: [ColorResponse]
    let condition_grade: ConditionGradeResponse
    let embedding: [Float]
    let estimated_price: PriceResponse
    let sustainability_score: Int
    let suggestions: [String]
}

private struct PredictionResponse: Codable {
    let label: String
    let confidence: Float
}

private struct ColorResponse: Codable {
    let name: String
    let hex: String
    let rgb: [Int]
    let percentage: Float
}

private struct ConditionGradeResponse: Codable {
    let grade: String
    let label: String
    let confidence: Float
    let description: String
}

private struct PriceResponse: Codable {
    let min: Double
    let max: Double
    let currency: String
    let confidence: String
}

// MARK: - Errors
enum ClassificationError: Error {
    case imageEncodingFailed
    case serverError
    case networkError
}

// MARK: - Config
private struct APIConfig {
    static let baseURL = "https://api.modaics.com"
}

// MARK: - Auth Manager (Placeholder)
private class AuthManager {
    static let shared = AuthManager()
    var token: String? { nil }
}
