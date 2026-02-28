import SwiftUI

struct DangerCardView: View {
    let detection: DetectionResult
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Drag handle indicator
            Capsule()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .foregroundColor(.red)
            
            Text(detection.formattedLabel)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("HIGH DANGER")
                .font(.caption)
                .fontWeight(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.2))
                .foregroundColor(.red)
                .clipShape(Capsule())
            
            Text(detection.safetyTip)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Text("Detected with \(Int(detection.confidence * 100))% confidence")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Button(action: onDismiss) {
                Text("Dismiss Safety Warning")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: -5)
        .padding(.horizontal)
    }
}
