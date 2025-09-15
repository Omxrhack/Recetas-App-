//
//  EmptyRecetas.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 14/09/25.
//

import SwiftUI

struct EmptyRecetas: View {
    var body: some View {
        VStack(spacing: 16) {
                               Image(systemName: "book.closed")
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: 120, height: 120)
                                   .foregroundColor(.customOrange)
                               
                               Text("Aún no hay recetas")
                                   .font(.title2)
                                   .bold()
                               
                               Text("Cuando tus amigos suban recetas, aparecerán aquí 🍲")
                                   .font(.subheadline)
                                   .multilineTextAlignment(.center)
                                   .foregroundColor(.gray)
                                   
                           }
                           .frame(maxWidth: .infinity, maxHeight: .infinity)
                           .padding(.top, 100)
                           .padding(60)
    }
}

#Preview {
    EmptyRecetas()
}

