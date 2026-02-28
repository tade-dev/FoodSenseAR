import Foundation
import ARKit
import Vision
import Combine

class ARViewModel: NSObject, ObservableObject, ARSessionDelegate {
    @Published var isDetecting: Bool = false
    @Published var detectedObjects: [DetectedDanger] = []
    
    private weak var arView: ARSCNView?
    // MARK: - CoreML & Vision Properties
    // private var visionModel: VNCoreMLModel?
    // private var visionRequests: [VNRequest] = []
    
    override init() {
        super.init()
    }
    
    // MARK: - Setup
    func setupARView(_ view: ARSCNView) {
        self.arView = view
        view.session.delegate = self
        
        // Show statistics such as fps and timing information for debugging
        // view.showsStatistics = true
        
        let configuration = ARWorldTrackingConfiguration()
        // Frame semantics like sceneDepth are useful if doing occlusion
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics.insert(.sceneDepth)
        }
        view.session.run(configuration)
        
        setupVision()
        isDetecting = true
    }
    
    private func setupVision() {
        // TODO: Load CreateML Object Detection Model
        /*
        guard let model = try? SafeSpaceObjectDetector(configuration: MLModelConfiguration()).model else {
            print("Failed to load CoreML model.")
            return
        }
        guard let visionModel = try? VNCoreMLModel(for: model) else {
            print("Failed to create VNCoreMLModel.")
            return
        }
        
        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            self?.processDetections(for: request, error: error)
        }
        request.imageCropAndScaleOption = .scaleFill
        self.visionRequests = [request]
        */
    }
    
    // MARK: - Controls
    func toggleDetection() {
        isDetecting.toggle()
        if isDetecting {
            let config = ARWorldTrackingConfiguration()
            arView?.session.run(config)
        } else {
            arView?.session.pause()
        }
    }
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // We only want to process vision when detection is active
        guard isDetecting else { return }
        
        // Throttle processing if necessary here
        
        // Pass the frame to Vision
        /*
        let pixelBuffer = frame.capturedImage
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print("Failed to perform Vision request: \(error.localizedDescription)")
        }
        */
    }
    
    // MARK: - CoreML Processing
    private func processDetections(for request: VNRequest, error: Error?) {
        // TODO: Process VNRecognizedObjectObservation results
        /*
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
        
        var currentDetections: [DetectedDanger] = []
        
        for observation in results {
            // Get highest confidence label
            guard let topLabel = observation.labels.first else { continue }
            
            // Only process top confidence results over a threshold
            if topLabel.confidence > 0.8 {
                if let category = DangerCategory(rawValue: topLabel.identifier) {
                    let danger = DetectedDanger(
                        category: category,
                        confidence: topLabel.confidence,
                        boundingBox: observation.boundingBox
                    )
                    currentDetections.append(danger)
                    
                    // TODO: Draw SCNNode overlay in AR space
                    // We map observation.boundingBox to 3D space using ARKit hit/raycast
                }
            }
        }
        
        DispatchQueue.main.async {
            self.detectedObjects = currentDetections
        }
        */
    }
}
