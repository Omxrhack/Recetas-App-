//
//  RecetasGrid.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 14/09/25.
//

import SwiftUI
struct RecipeGridView: View {
    @Binding var recipes: [Recipe]       // Para poder editar
    let currentUser: String               // Usuario actual
    let imageSize: CGFloat = 120
    let spacing: CGFloat = 8

    var body: some View {
        let columns = [
            GridItem(.fixed(imageSize), spacing: spacing),
            GridItem(.fixed(imageSize), spacing: spacing),
            GridItem(.fixed(imageSize), spacing: spacing)
        ]

        ScrollView {
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach($recipes) { $recipe in
                    ZStack(alignment: .topTrailing) {
                        NavigationLink(destination: RecipeDetailView(recipe: $recipe)) {
                            if let uiImage = loadImageFromDocuments(filename: recipe.image) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imageSize, height: imageSize)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: imageSize, height: imageSize)
                                    .cornerRadius(8)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.white)
                                    )
                            }
                        }

                        // Botón de editar solo si es tu receta
                        if recipe.user == currentUser {
                            Button {
                                // Acción de editar
                                print("Editar receta \(recipe.title)")
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.customOrange)
                                    .font(.system(size: 24))
                                    .background(Color.white.clipShape(Circle()))
                            }
                            .padding(4)
                        }
                    }
                }
            }
            .padding(.horizontal, spacing)
            .padding(.top, spacing)
        }
    }
}

#Preview {
    RecipeGridView(
        recipes: .constant([
            Recipe(id: 1, user: "Omar", title: "Tacos", image: "taco.jpg", description: "Deliciosos", category: "Comida", isPublic: true, isLiked: false, isSaved: true),
            Recipe(id: 2, user: "Ana", title: "Pizza", image: "pizza.jpg", description: "Italiana", category: "Comida", isPublic: false, isLiked: true, isSaved: false)
        ]),
        currentUser: "Omar"
    )
}
