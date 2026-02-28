import SwiftUI

struct AROverlayView: View {
    let detection: DetectionResult
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Central Target Bounding Box
            RoundedRectangle(cornerRadius: 16)
                .stroke(detection.dangerLevel.color, lineWidth: 4)
                .frame(width: 250, height: 250)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(detection.dangerLevel.color.opacity(isPulsing ? 0.2 : 0.05))
                )
                .scaleEffect(isPulsing ? 1.05 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                    value: isPulsing
                )
                .onAppear {
                    isPulsing = true
                }
            
            // Text Overlays anchored to the bounding box
            VStack {
                // Spacer pushes the overlay content to align with the bounding box
                Spacer()
                
                VStack(spacing: 8) {
                    // Badge Header
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.headline)
                        
                        Text(detection.formattedLabel)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(detection.dangerLevel.color)
                    .clipShape(Capsule())
                    .shadow(radius: 4)
                    
                    // Safety Tip
                    Text(detection.safetyTip)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .frame(maxWidth: 300)
                        .background(Color.black.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                }
                // Offset positions this group right above or below the bounding box
                .offset(y: -140) 
            }
        }
    }
}

#Preview {
    AROverlayView(
        detection: DetectionResult(
            label: "scissors_knives",
            confidence: 0.95,
            dangerLevel: .high
        )
    )
    .background(Color.gray)
}
