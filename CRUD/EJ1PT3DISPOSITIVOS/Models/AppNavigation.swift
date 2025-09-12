//
//  AppNavigation.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 11/09/25.
//


import Foundation
import SwiftUI

// Define the different states of your app flow
enum FlowState {
    case onboarding
    case mainApp
}

class AppNavigation: ObservableObject {
    @Published var currentFlowState: FlowState = .onboarding
    
    // Call this method when the user finishes onboarding
    func completeOnboarding() {
        self.currentFlowState = .mainApp
    }
}
