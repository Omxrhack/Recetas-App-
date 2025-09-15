//
//  NuevasRecetas.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 14/09/25.
//

import SwiftUI
import PhotosUI



struct NewRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: String = ""
    @State private var image: UIImage? = nil
    @State private var isPublic: Bool = true
    @State private var showImagePicker = false
    
    // Callback cuando se guarda la receta
    var onSave: (Recipe) -> Void
    
    // Parámetro opcional para edición
    var editRecipe: Recipe? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Imagen
                    ZStack(alignment: .bottomTrailing) {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(12)
                        } else if let editImage = editRecipe.flatMap({ loadImageFromDocuments(filename: $0.image) }) {
                            Image(uiImage: editImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                                .cornerRadius(12)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                )
                        }

                        Button {
                            showImagePicker = true
                        } label: {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.customOrange)
                                .font(.title)
                                .padding(8)
                                .background(Color.white.clipShape(Circle()))
                        }
                        .offset(x: -10, y: -10)
                    }

                    // Campos de texto
                    TextField("Título", text: $title)
                        .textFieldStyle(.roundedBorder)
                    TextField("Categoría", text: $category)
                        .textFieldStyle(.roundedBorder)
                    TextEditor(text: $description)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    
                    Toggle("Pública", isOn: $isPublic)
                        .padding(.top)
                    
                    // Guardar
                    Button {
                        saveRecipe()
                    } label: {
                        Text(editRecipe != nil ? "Actualizar Receta" : "Crear Receta")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.customOrange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle(editRecipe != nil ? "Editar Receta" : "Nueva Receta")
            .onAppear {
                // Si hay receta a editar, cargar sus valores
                if let recipe = editRecipe {
                    title = recipe.title
                    description = recipe.description
                    category = recipe.category
                    isPublic = recipe.isPublic
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image)
            }
        }
    }
    
    // MARK: - Guardar/Actualizar receta
    private func saveRecipe() {
        // Si es edición, conservamos el ID
        let newRecipe = Recipe(
            id: editRecipe?.id ?? Int.random(in: 1...Int.max),
            user: editRecipe?.user ?? "Usuario", // o app.currentUser si se pasa por env
            title: title,
            image: saveImageToDocuments(image: image, existingFilename: editRecipe?.image),
            description: description,
            category: category,
            isPublic: isPublic,
            isLiked: editRecipe?.isLiked ?? false,
            isSaved: editRecipe?.isSaved ?? false
        )
        
        onSave(newRecipe)
        dismiss()
    }
    
    // MARK: - Guardar imagen en Documents
    private func saveImageToDocuments(image: UIImage?, existingFilename: String?) -> String {
        guard let image = image else { return existingFilename ?? "" }
        let filename = existingFilename ?? UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url)
        }
        return filename
    }
}


#Preview {
    NewRecipeView { newRecipe in
        print("Receta guardada: \(newRecipe.title)")
    }
}
