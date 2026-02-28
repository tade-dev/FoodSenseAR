import Foundation
import Combine

class ARViewModel: ObservableObject {
    @Published var isDetecting: Bool = true
    @Published var currentDetection: DetectionResult?
    
    // MARK: - Update Methods
    func updateDetection(_ result: DetectionResult?) {
        // Ensure UI updates are pushed to the main thread
        DispatchQueue.main.async {
            self.currentDetection = result
        }
    }
    
    // MARK: - Controls
    func toggleDetection() {
        isDetecting.toggle()
        
        // If we pause detection, clear the current detection state
        if !isDetecting {
            DispatchQueue.main.async {
                self.currentDetection = nil
            }
        }
    }
}
