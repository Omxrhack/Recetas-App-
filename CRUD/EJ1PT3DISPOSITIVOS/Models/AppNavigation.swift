//
//  AppNavigation.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 11/09/25.
//


import Foundation
import SwiftUI


enum FlowState {
    case onboarding
    case mainApp
    case login
}

class AppNavigation: ObservableObject {
    @Published var currentFlowState: FlowState = .onboarding
    @Published var currentUser: String = "" // <- nuevo

    @Published var savedRecipes: [Recipe] = [] // Todas las recetas guardadas
    
    
    func completeOnboarding() {
        currentFlowState = .login
    }
    
    func login(username: String) {
        self.currentUser = username
        self.currentFlowState = .mainApp
        UserDefaults.standard.set(username, forKey: "currentUser")
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
    }

    func logout() {
        self.currentUser = ""
        self.currentFlowState = .login
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }

    init() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if isLoggedIn, let savedUser = UserDefaults.standard.string(forKey: "currentUser") {
            currentUser = savedUser
            currentFlowState = .mainApp
        } else {
            currentFlowState = .onboarding
        }
    }
}
