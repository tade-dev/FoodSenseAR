import Foundation
import Combine

class ARViewModel: ObservableObject {
    @Published var isDetecting: Bool = true
    @Published var currentDetection: DetectionResult?
    @Published var detectionHistory: [DetectionHistoryItem] = []
    
    // MARK: - Update Methods
    func updateDetection(_ result: DetectionResult?) {
        DispatchQueue.main.async {
            self.currentDetection = result
            
            if let result = result {
                self.addToHistory(result)
            }
        }
    }
    
    // Limits the log history to the 20 most recent unique elements
    private func addToHistory(_ result: DetectionResult) {
        // Prevent rapid duplicate fires from the Vision stream filling the array
        if let last = detectionHistory.first, last.label == result.label, Date().timeIntervalSince(last.timestamp) < 5.0 {
            return
        }
        
        let item = DetectionHistoryItem(from: result)
        detectionHistory.insert(item, at: 0)
        
        if detectionHistory.count > 20 {
            detectionHistory = Array(detectionHistory.prefix(20))
        }
    }
    
    // MARK: - Controls
    func toggleDetection() {
        isDetecting.toggle()
        if !isDetecting {
            DispatchQueue.main.async {
                self.currentDetection = nil
            }
        }
    }
    
    func clearHistory() {
        detectionHistory.removeAll()
    }
    
    func dismissCurrentDetection() {
        currentDetection = nil
    }
}
