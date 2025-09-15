//
//  RecetasCard.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 14/09/25.
//

import SwiftUI

struct RecipeCard: View {
    @Binding var recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Imagen principal
            ZStack {
                if let uiImage = loadImageFromDocuments(filename: recipe.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray.opacity(0.5))
                        .background(Color.gray.opacity(0.1))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 220)
            .clipped()
            .cornerRadius(16)
            .shadow(radius: 3)

            // Título
            Text(recipe.title)
                .font(.title3)
                .fontWeight(.bold)

            // Usuario y avatar
            HStack(spacing: 8) {
                if !recipe.user.isEmpty {
                    Circle()
                        .fill(.customOrange)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String(recipe.user.prefix(1)))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        )
                }
                
                Text(recipe.user.isEmpty ? "Anónimo" : recipe.user)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
            }

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
                .lineLimit(3)

            // Botones de acción
            HStack(spacing: 20) {
                Button {
                    withAnimation(.spring()) { recipe.isLiked.toggle() }
                } label: {
                    Image(systemName: recipe.isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(recipe.isLiked ? .red : .gray)
                }
                Button {
                    withAnimation(.spring()) { recipe.isSaved.toggle() }
                } label: {
                    Image(systemName: recipe.isSaved ? "book.closed.fill" : "book")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(recipe.isSaved ? .blue : .gray)
                }
                Spacer()
            }
            .padding(.top, 6)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 4)
    }
    
    // MARK: - Cargar imagen desde Documents
    private func loadImageFromDocuments(filename: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }
}



#Preview {
    RecipeCard(recipe: .constant(
        Recipe(
            id: 1,
            user: "Ana",
            title: "Pizza Casera",
            image: "pizza",
            description: "Pizza con masa artesanal y mucho queso 🧀. Fácil de preparar en casa.",
            category: "Comida",
            isPublic: true,
            isLiked: true,
            isSaved: false
        )
    ))
    .padding()
}

