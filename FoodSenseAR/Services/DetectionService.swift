import Foundation
import CoreML
import Vision
import CoreVideo

enum DetectionError: LocalizedError {
    case modelNotFound
    case modelLoadingFailed
    case visionModelCreationFailed
    case requestFailed
    case invalidImage
    
    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "The CoreML model file was not found in the app bundle."
        case .modelLoadingFailed:
            return "Failed to load the CoreML model."
        case .visionModelCreationFailed:
            return "Failed to create VNCoreMLModel from the loaded MLModel."
        case .requestFailed:
            return "The Vision classification request failed."
        case .invalidImage:
            return "The provided CVPixelBuffer is invalid."
        }
    }
}

class DetectionService {
    private var visionModel: VNCoreMLModel?
    private let confidenceThreshold: Float = 0.90
    
    /// Initializes the DetectionService by safely loading the CoreML model.
    /// Requirements: The .mlmodel file (or .mlpackage) needs to be compiled into the app bundle.
    init() throws {
        // Loads the compiled CreateML model from the bundle dynamically.
        guard let modelURL = Bundle.main.url(forResource: "SafeSpaceClassifier", withExtension: "mlmodelc") else {
            throw DetectionError.modelNotFound
        }
        
        do {
            let model = try MLModel(contentsOf: modelURL)
            self.visionModel = try VNCoreMLModel(for: model)
        } catch {
            print("Failed to load CoreML model: \(error)")
            throw DetectionError.modelLoadingFailed
        }
    }
    
    /// Processes a CVPixelBuffer from the camera.
    /// Returns a DetectionResult if its confidence >= 90%.
    /// Returns nil if confidence < 90% (treated as safe) or if the class is unknown.
    func performClassification(
        on pixelBuffer: CVPixelBuffer,
        completion: @escaping (Result<DetectionResult?, Error>) -> Void
    ) {
        guard let visionModel = self.visionModel else {
            completion(.failure(DetectionError.visionModelCreationFailed))
            return
        }
        
        // Build the Vision CoreML request
        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Image Classifiers return an array of VNClassificationObservation
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(.failure(DetectionError.requestFailed))
                return
            }
            
            let label = topResult.identifier
            let confidence = topResult.confidence
            
            // Allow listed classes. Other classes (or fallback classes) automatically return nil (safe)
            let validClasses = ["scissors_knives", "electrical_outlets_cables", "cleaning_products"]
            
            // Enforce confidence threshold: under 0.90 is ignored and returned as nil (safe)
            guard confidence >= self.confidenceThreshold, validClasses.contains(label) else {
                completion(.success(nil))
                return
            }
            
            let result = DetectionResult(
                label: label,
                confidence: confidence,
                dangerLevel: .high
            )
            
            completion(.success(result))
        }
        
        // Use center crop to adjust the rectangular image frame from ARKit 
        // to the model's preferred square aspect ratio
        request.imageCropAndScaleOption = .centerCrop
        
        // The standard ARKit orientation is typically .right
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
}
