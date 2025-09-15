//
//  FavoritesPage.swift
//  EJ1PT3DISPOSITIVOS
//
import SwiftUI

struct FavoritesPage: View {
    @EnvironmentObject var app: AppNavigation
    @State private var recipes: [Recipe] = []

    private let columns = [
        GridItem(.fixed(120), spacing: 8),
        GridItem(.fixed(120), spacing: 8),
        GridItem(.fixed(120), spacing: 8)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if recipes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No hay recetas guardadas")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    .padding(.top, 50)
                } else {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach($recipes) { $recipe in
                            ZStack(alignment: .topTrailing) {
                                // Imagen de la receta
                                NavigationLink(destination: RecipeDetailView(recipe: $recipe)) {
                                    if let uiImage = loadImageFromDocuments(filename: recipe.image) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipped()
                                            .cornerRadius(8)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 120, height: 120)
                                            .cornerRadius(8)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }

                                // Botón guardar/quitar favorito
                                Button {
                                    toggleSave(recipe: &recipe)
                                } label: {
                                    Image(systemName: recipe.isSaved ? "bookmark.fill" : "bookmark")
                                        .foregroundColor(.customOrange)
                                        .padding(6)
                                        .background(Color.white.opacity(0.8))
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                                .padding(6)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Favoritos")
            .onAppear { loadFavorites() }
            .refreshable { loadFavorites() }
        }
    }

    // MARK: - Cargar recetas guardadas (tuyas + amigos)
    private func loadFavorites() {
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
    FavoritesPage()
        .environmentObject(AppNavigation())
}
