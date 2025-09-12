//
//  AppState.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 11/09/25.
//

import Foundation
import SwiftUI

enum AppFlowState {
    case onboarding
    case main
}

final class AppStateManager: ObservableObject {
    @AppStorage("isOnBoardingCompleted") var isOnBoardingCompleted: Bool = false
    
    var currentFlowState: AppFlowState {
        isOnBoardingCompleted ? .main : .onboarding
    }
    
    func completeOnboarding() {
        isOnBoardingCompleted = true
    }
}
