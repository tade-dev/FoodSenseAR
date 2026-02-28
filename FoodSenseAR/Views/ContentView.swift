import SwiftUI

struct ContentView: View {
    @EnvironmentObject var arViewModel: ARViewModel
    @State private var showingHistory = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Camera/AR View
                ARViewContainer()
                    .environmentObject(arViewModel)
                    .ignoresSafeArea()
                
                // Live AR Bounds Overlay 
                if let currentDetection = arViewModel.currentDetection {
                    AROverlayView(detection: currentDetection)
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: arViewModel.currentDetection?.id)
                }
                
                // Safe/Danger Status UI Overlay
                VStack {
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 10) {
                            StatusPill(
                                text: arViewModel.isDetecting ? "Detecting..." : "Paused",
                                color: arViewModel.isDetecting ? .blue : .gray
                            )
                        }
                        .padding()
                    }
                    Spacer()
                    
                    // Controls
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                arViewModel.toggleDetection()
                            }
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
                
                // Bottom Sheet Danger Card
                VStack {
                    Spacer()
                    if let currentDetection = arViewModel.currentDetection {
                        DangerCardView(detection: currentDetection) {
                            withAnimation(.spring()) {
                                arViewModel.dismissCurrentDetection()
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.bottom, 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: arViewModel.currentDetection?.id)
            }
            .navigationTitle("SafeSpace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingHistory = true }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView()
                    .environmentObject(arViewModel)
            }
        }
        // Native observation to print logging optionally alongside AR display
        .onChange(of: arViewModel.currentDetection?.id) { oldValue, newValue in
            if let result = arViewModel.currentDetection {
                print("⚠️ [DANGER DETECTED] \(result.formattedLabel) - \(Int(result.confidence * 100))%")
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
