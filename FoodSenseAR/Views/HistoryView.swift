import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var arViewModel: ARViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                if arViewModel.detectionHistory.isEmpty {
                    Text("No completely unsafe objects detected yet.")
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(arViewModel.detectionHistory) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(item.formattedLabel)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(Int(item.confidence * 100))%")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(item.safetyTip)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(item.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.red.opacity(0.05))
                    }
                }
            }
            .navigationTitle("Detection History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear History") { arViewModel.clearHistory() }
                        .foregroundColor(.red)
                }
            }
        }
    }
}
