import Foundation
import SwiftUI

enum DangerLevel {
    case high
    
    var color: Color {
        switch self {
        case .high:
            return .red
        }
    }
}

struct DetectionResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    let dangerLevel: DangerLevel
    
    var safetyTip: String {
        switch label {
        case "scissors_knives":
            return "Store all sharp objects in locked drawers away from children"
        case "electrical_outlets_cables":
            return "Use outlet covers and keep cables tucked away"
        case "cleaning_products":
            return "Store chemicals in high locked cupboards out of reach"
        default:
            return ""
        }
    }
}
