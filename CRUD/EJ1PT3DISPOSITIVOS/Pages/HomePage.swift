//
//  HomePage.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 12/09/25.
//

import SwiftUI

struct HomePage: View {
    @EnvironmentObject var app: AppNavigation

    var body: some View {
        VStack(spacing: 20) {
            Text("Bienvenido \(app.currentUser) 🎉")
                .font(.title)
                .padding()


            Button("Cerrar Sesión") {
                app.logout()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color("CustomOrange"))
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    HomePage()
        .environmentObject(AppNavigation())
}
