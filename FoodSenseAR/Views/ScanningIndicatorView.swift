import SwiftUI

struct ScanningIndicatorView: View {
    @EnvironmentObject var arViewModel: ARViewModel
    @State private var pulse: CGFloat = 1.0
    
    var body: some View {
        if let target = arViewModel.scanningTarget, arViewModel.currentDetection == nil {
            VStack {
                Spacer()
                
                ZStack {
                    // Outer pulse
                    Circle()
                        .stroke(target.dangerLevel.color.opacity(0.4), lineWidth: 4)
                        .scaleEffect(pulse)
                        .opacity(2.0 - pulse)
                        .animation(
                            Animation.easeOut(duration: 1.2).repeatForever(autoreverses: false),
                            value: pulse
                        )
                        .onAppear {
                            pulse = 1.8
                        }
                    
                    // Background track
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0.0, to: arViewModel.scanningProgress)
                        .stroke(target.dangerLevel.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .shadow(color: target.dangerLevel.color.opacity(0.8), radius: 5, x: 0, y: 0)
                }
                .frame(width: 130, height: 130)
                
                Text("Scanning...")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
                
                Spacer()
            }
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }
}
