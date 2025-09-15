//
//  NavigationTab.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 14/09/25.
//

import SwiftUI

struct NativeTabViews: View {
    @EnvironmentObject var app: AppNavigation
    @State private var selectedTab = 0

    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Home
            HomePage()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }
                .tag(0)
            
            // Favoritos
            FavoritesPage()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favoritos")
                }
                .tag(1)
            
            // Perfil
            ProfilePage()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
                .tag(2)
        }
        .accentColor(.customOrange)
        
        .onAppear {
            app.currentFlowState = .mainApp
        }
        
    }
}

#Preview {
    NativeTabViews()
        .environmentObject(AppNavigation())
}
