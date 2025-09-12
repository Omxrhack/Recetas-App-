//
//  ContentView.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 11/09/25.
//
// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var app = AppNavigation()
    
    var body: some View {
       
        if app.currentFlowState == .onboarding {
            OnboardingView()
                .environmentObject(app)
        } else {
       
            LoginPage()
                .environmentObject(app)
        }
    }
}
#Preview {
    ContentView()
        .environmentObject(AppNavigation())
}
