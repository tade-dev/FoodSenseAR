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
                        VStack(alignment: .trailing, spacing: 8) {
                            StatusPill(
                                text: arViewModel.isDetecting ? "Detecting..." : "Paused",
                                color: arViewModel.isDetecting ? .blue : .gray
                            )
                            
                            if !arViewModel.detectedObjects.isEmpty {
                                StatusPill(
                                    text: "\(arViewModel.detectedObjects.count) Dangers Found",
                                    color: .red
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
    }
}

struct StatusPill: View {
    var text: String
    var color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.8))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

#Preview {
    ContentView()
        .environmentObject(ARViewModel())
}
