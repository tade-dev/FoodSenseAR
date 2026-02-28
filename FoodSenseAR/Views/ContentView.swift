import SwiftUI

struct ContentView: View {
    @EnvironmentObject var arViewModel: ARViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Camera/AR View
                ARViewContainer()
                    .environmentObject(arViewModel)
                    .ignoresSafeArea()
                
                // Safe/Danger Overlay UI
                VStack {
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 10) {
                            StatusPill(
                                text: arViewModel.isDetecting ? "Detecting..." : "Paused",
                                color: arViewModel.isDetecting ? .blue : .gray
                            )
                            
                            // Instantly surfaces positive results tracked from ARViewModel
                            if let currentDetection = arViewModel.currentDetection {
                                StatusPill(
                                    text: "⚠️ \(currentDetection.label.replacingOccurrences(of: "_", with: " ").capitalized)",
                                    color: currentDetection.dangerLevel.color
                                )
                            }
                        }
                        .padding()
                    }
                    Spacer()
                    
                    // Controls
                    HStack {
                        Button(action: {
                            arViewModel.toggleDetection()
                        }) {
                            Image(systemName: arViewModel.isDetecting ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 64, height: 64)
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("SafeSpace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        // iOS 17 uses the new optional oldValue/newValue property signature logic 
        // We capture any classification threshold that triggers a non-null DangerLevel hit.
        .onChange(of: arViewModel.currentDetection?.id) { oldValue, newValue in
            if let result = arViewModel.currentDetection {
                print("⚠️ [DANGER DETECTED]")
                print("   Label: \(result.label)")
                print("   Confidence: \(Int(result.confidence * 100))%")
                print("   Action: \(result.safetyTip)")
            }
        }
    }
}

struct StatusPill: View {
    var text: String
    var color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(color.opacity(0.85))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .shadow(radius: 2)
    }
}

#Preview {
    ContentView()
        .environmentObject(ARViewModel())
}
