//
//  ContentView.swift
//  FoodSenseAR
//
//  Created by BSTAR on 06/02/2026.
//

import SwiftUI
import RealityKit
import ARKit

struct MainView : View {

    var body: some View {
        
        MainViewARContainer()
            .ignoresSafeArea()
        
    }

}

struct MainViewARContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> () {
        
    }
    
}




#Preview {
    MainView()
}
