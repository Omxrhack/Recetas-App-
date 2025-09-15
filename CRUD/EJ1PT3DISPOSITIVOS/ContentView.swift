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
        switch app.currentFlowState {
        case .onboarding:
            OnboardingView()
                .environmentObject(app)
        case .login:
            LoginPage()
                .environmentObject(app)
        case .mainApp:
            NativeTabViews()
                .environmentObject(app)
        }
    }
}

#Preview {
    NativeTabViews()
        .environmentObject(AppNavigation())
}
