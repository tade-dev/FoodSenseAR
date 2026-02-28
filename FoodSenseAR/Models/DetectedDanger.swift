import Foundation
import CoreGraphics

// Four classes defined by the CoreML image classification model
enum DangerCategory: String, CaseIterable {
    case scissorsKnives = "scissors_knives"
    case electricalOutletsCables = "electrical_outlets_cables"
    case cleaningProducts = "cleaning_products"
    case safe = "safe"
    
    var isDangerous: Bool {
        return self != .safe
    }
}

struct DetectedDanger: Identifiable {
    let id = UUID()
    let category: DangerCategory
    let confidence: Float
    let boundingBox: CGRect
}
