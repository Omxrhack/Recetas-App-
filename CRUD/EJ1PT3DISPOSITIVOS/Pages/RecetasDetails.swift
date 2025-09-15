//
//  RecetasDetails.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 14/09/25.
//

import SwiftUI

struct RecipeDetailView: View {
    @Binding var recipe: Recipe
    @EnvironmentObject var app: AppNavigation
    @State private var showEditRecipe = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Imagen principal
                if let uiImage = loadImageFromDocuments(filename: recipe.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        )
                }

                // Título y usuario
                Text(recipe.title)
                    .font(.title)
                    .bold()
                Text("Por: \(recipe.user.isEmpty ? "Anónimo" : recipe.user)")
                    .foregroundColor(.gray)

                // Categoría
                Text(recipe.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(5)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(6)

                // Descripción
                Text(recipe.description)
                    .font(.body)
                    .foregroundColor(.secondary)

                HStack(spacing: 20) {
           
                    // Botón eliminar
                    Button {
                        deleteRecipe()
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                    }

                

                    Spacer()
                    
                    // Botón de edición solo si la receta es tuya
                    if recipe.user == app.currentUser {
                        Button {
                            showEditRecipe = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.customOrange)
                                .font(.title2)
                        }
                        .sheet(isPresented: $showEditRecipe) {
                            NewRecipeView(onSave:  { updatedRecipe in
                                // Actualizar en BD
                                DatabaseManager.shared.updateRecipe(updatedRecipe)
                                recipe = updatedRecipe
                            }, editRecipe: recipe)
                        }
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
    }
    private func toggleLike() {
        recipe.isLiked.toggle()
        DatabaseManager.shared.updateReaction(
            id: Int64(recipe.id),
            isLiked: recipe.isLiked,
            isSaved: recipe.isSaved
        )
    }

    private func toggleSave() {
        recipe.isSaved.toggle()
        DatabaseManager.shared.updateReaction(
            id: Int64(recipe.id),
            isLiked: recipe.isLiked,
            isSaved: recipe.isSaved
        )
    }
    private func deleteRecipe() {
        DatabaseManager.shared.deleteRecipe(id: Int64(recipe.id))
        // Cierra la vista de detalle después de eliminar
        app.currentFlowState = .mainApp   // o navega hacia la lista de recetas
    }

}


#Preview {
    RecipeDetailView(
        recipe: .constant(Recipe(
            id: 1,
            user: "Omar",
            title: "Tacos al Pastor",
            image: "Mexicana",
            description: "Deliciosos tacos con piña y carne marinada.",
            category: "tacos",
            isPublic: true,
            isLiked: false,
            isSaved: false
        ))
    )
    .environmentObject(AppNavigation())
}
