import Vision
import UIKit

// MARK: - Label OCR Result
struct LabelOCRResult {
    let brand: String?
    let size: String?
    let material: String?
    let careInstructions: [String]
    let allText: [String]
    let confidence: Float
}

// MARK: - Label OCR
/// Vision framework OCR for reading garment labels
class LabelOCR {
    
    /// Recognized text request with custom configuration
    private lazy var textRequest: VNRecognizeTextRequest = {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate  // High accuracy for small text
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US", "en-GB", "en-AU"]
        return request
    }()
    
    /// Read label from garment tag photo
    func readLabel(from image: UIImage) async throws -> LabelOCRResult {
        guard let cgImage = image.cgImage else {
            throw OCError.invalidImage
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([textRequest])
        
        guard let observations = textRequest.results else {
            return LabelOCRResult(
                brand: nil, size: nil, material: nil,
                careInstructions: [], allText: [], confidence: 0
            )
        }
        
        let texts = observations.compactMap { $0.topCandidates(1).first?.string }
        
        return LabelOCRResult(
            brand: extractBrand(from: texts),
            size: extractSize(from: texts),
            material: extractMaterial(from: texts),
            careInstructions: extractCareInstructions(from: texts),
            allText: texts,
            confidence: calculateConfidence(observations)
        )
    }
    
    // MARK: - Extraction Helpers
    
    private func extractBrand(from texts: [String]) -> String? {
        let knownBrands = [
            "Levi's", "Nike", "Adidas", "Zara", "H&M", "Uniqlo", "Cos", "Everlane",
            "Reformation", "Patagonia", "The North Face", "Ralph Lauren", "Tommy Hilfiger",
            "Calvin Klein", "Guess", "Mango", "Topshop", "ASOS", "Boohoo",
            "Country Road", "Witchery", "Trenery", "Assembly Label", "Bassike",
            "Zimmermann", "Scanlan Theodore", "Camilla and Marc", "Dion Lee"
        ]
        
        for text in texts {
            let upperText = text.upperCase
            for brand in knownBrands {
                if upperText.contains(brand.upperCase) {
                    return brand
                }
            }
        }
        
        // Look for "Brand:" or trademark symbols
        for text in texts {
            if text.contains("®"), let match = text.range(of: "[A-Za-z]+", options: .regularExpression) {
                return String(text[match])
            }
        }
        
        return nil
    }
    
    private func extractSize(from texts: [String]) -> String? {
        // Size patterns
        let sizePatterns = [
            "XXS", "XS", "S", "M", "L", "XL", "XXL", "XXXL",
            "\d{1,2}",           // Numeric sizes (8, 10, 12, etc.)
            "\d{2}/\d{2}",      // Split sizes (32/34)
            "SIZE\s*[:\-]?\s*([A-Z0-9]+)",  // "Size: M" or "Size-10"
        ]
        
        for text in texts {
            let upperText = text.upperCase
            
            // Direct size mentions
            for pattern in sizePatterns {
                if let range = upperText.range(of: pattern, options: .regularExpression) {
                    let match = String(upperText[range])
                    // Validate it's actually a size
                    if match.count <= 5 || match.contains("SIZE") {
                        return match.replacingOccurrences(of: "SIZE", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: ":", with: "")
                            .replacingOccurrences(of: "-", with: "")
                    }
                }
            }
        }
        
        return nil
    }
    
    private func extractMaterial(from texts: [String]) -> String? {
        let materialKeywords = [
            "cotton", "polyester", "wool", "silk", "linen", "cashmere",
            "viscose", "modal", "rayon", "nylon", "acrylic", "elastane",
            "spandex", "leather", "suede", "denim", "organic cotton",
            "recycled polyester", "merino wool"
        ]
        
        for text in texts {
            let lowerText = text.lowercased()
            for material in materialKeywords {
                if lowerText.contains(material) {
                    return material.capitalized
                }
            }
        }
        
        // Look for percentage patterns (e.g., "100% Cotton")
        for text in texts {
            let pattern = "\\d+%\\s*([A-Za-z]+)"
            if let match = text.range(of: pattern, options: .regularExpression) {
                return String(text[match])
            }
        }
        
        return nil
    }
    
    private func extractCareInstructions(from texts: [String]) -> [String] {
        let careSymbols = [
            "machine wash", "hand wash", "dry clean", "do not bleach",
            "tumble dry", "line dry", "iron", "do not iron",
            "wash separately", "cold wash", "warm wash", "hot wash"
        ]
        
        return texts.filter { text in
            let lower = text.lowercased()
            return careSymbols.contains { lower.contains($0) }
        }
    }
    
    private func calculateConfidence(_ observations: [VNRecognizedTextObservation]) -> Float {
        guard !observations.isEmpty else { return 0 }
        
        let confidences = observations.compactMap { obs -> Float? in
            obs.topCandidates(1).first?.confidence
        }
        
        guard !confidences.isEmpty else { return 0 }
        return confidences.reduce(0, +) / Float(confidences.count)
    }
}

// MARK: - Errors
enum OCError: Error {
    case invalidImage
    case recognitionFailed
}
