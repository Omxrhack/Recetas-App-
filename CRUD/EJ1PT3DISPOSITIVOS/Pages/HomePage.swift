//
//  RecetasCard.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 11/09/25.
//

import SwiftUI
import CoreData
import SQLite3


struct HomePage: View {
    @EnvironmentObject var app: AppNavigation
    @State private var recipes: [Recipe] = []
    @State private var showNewRecipe = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    
                    // Botón nueva receta
                    Button {
                        showNewRecipe.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.customOrange)
                            Text("Escribe tu receta...")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3)))
                        .padding(.horizontal)
                    }
                    
                    if recipes.isEmpty {
                        Text("No hay recetas para mostrar")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    } else {
                        ForEach($recipes) { $recipe in
                            RecipeCard(recipe: $recipe)
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        toggleSave(recipe: &recipe)
                                    } label: {
                                        
                                        
                                    }
                                    .padding(6)
                                }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "fork.knife.circle.fill")
                            .foregroundColor(.customOrange)
                        Text("Bienvenido \(app.currentUser)")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
            }
            .onAppear { loadFeed() }
            .sheet(isPresented: $showNewRecipe) {
                NewRecipeView { newRecipe in
                    DatabaseManager.shared.addRecipe(
                        user: app.currentUser,
                        title: newRecipe.title,
                        image: newRecipe.image,
                        description: newRecipe.description,
                        category: newRecipe.category,
                        isPublic: newRecipe.isPublic
                    )
                    loadFeed()
                }
            }
            .refreshable { loadFeed() }
        }
    }

    // MARK: - Cargar feed (recetas propias + amigos)
    private func loadFeed() {
        let friends = DatabaseManager.shared.fetchFriends(of: app.currentUser)
        let usersToShow = friends + [app.currentUser]
        recipes = DatabaseManager.shared.fetchRecipes(ofUsers: usersToShow)
    }

    // MARK: - Guardar/Quitar favorito
    private func toggleSave(recipe: inout Recipe) {
        recipe.isSaved.toggle()
        if recipe.isSaved {
            DatabaseManager.shared.saveRecipe(recipeId: Int64(recipe.id), byUser: app.currentUser)
        } else {
            DatabaseManager.shared.unsaveRecipe(recipeId: Int64(recipe.id), byUser: app.currentUser)
        }
    }
}

// MARK: - Preview
#Preview {
    HomePage()
        .environmentObject(AppNavigation())
}


