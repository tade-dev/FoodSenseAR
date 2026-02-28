import SwiftUI

@main
struct SafeSpaceApp: App {
    @StateObject private var arViewModel = ARViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(arViewModel)
        }
    }
}
