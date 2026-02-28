import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        
        // Adopt the coordinator as the ARSCNViewDelegate
        arView.delegate = context.coordinator
        
        // Debugging / Performance settings
        // arView.showsStatistics = true
        
        let configuration = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics.insert(.sceneDepth)
        }
        
        arView.session.run(configuration)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if arViewModel.isDetecting {
            // Only boot and run the exact configuration if it was entirely paused
            if uiView.session.configuration == nil {
                let configuration = ARWorldTrackingConfiguration()
                if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
                    configuration.frameSemantics.insert(.sceneDepth)
                }
                uiView.session.run(configuration)
            }
        } else {
            uiView.session.pause()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARViewContainer
        
        private var detectionService: DetectionService?
        private var lastDetectionTime: TimeInterval = 0
        private let detectionInterval: TimeInterval = 0.5
        
        // Execute the Vision requests off the main thread to ensure the AR viewport runs smoothly at 60fps
        private let processingQueue = DispatchQueue(label: "com.safespace.processing", qos: .userInitiated)
        
        // Avoid queueing up overlapping frames if one takes longer than 0.5 seconds
        private var isProcessingFrame = false
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
            super.init()
            
            do {
                self.detectionService = try DetectionService()
            } catch {
                print("Failed to initialize DetectionService: \(error.localizedDescription)")
            }
        }
        
        // MARK: - ARSCNViewDelegate
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            // Respect the global pause toggle
            guard parent.arViewModel.isDetecting else { return }
            
            // Step 1: Throttle processing pipeline to occur ~ every 0.5 seconds
            guard time - lastDetectionTime >= detectionInterval else { return }
            
            // Step 2: Prevent concurrent frame pileup
            guard !isProcessingFrame else { return }
            
            // Step 3: Extract the ARKit camera pixel buffer safely
            guard let arView = renderer as? ARSCNView,
                  let currentFrame = arView.session.currentFrame else { return }
            
            let pixelBuffer = currentFrame.capturedImage
            
            // Checkmark logic locks
            lastDetectionTime = time
            isProcessingFrame = true
            
            // Step 4: Dispatch processing queue to the DetectionService asynchronously
            processingQueue.async { [weak self] in
                guard let self = self else { return }
                
                self.detectionService?.performClassification(on: pixelBuffer) { result in
                    defer {
                        // Release the lock exactly when the callback is finalized
                        self.isProcessingFrame = false
                    }
                    
                    switch result {
                    case .success(let detectionResult):
                        // Passes control back to the ObservableObject
                        self.parent.arViewModel.updateDetection(detectionResult)
                        
                    case .failure(let error):
                        print("Classification Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
