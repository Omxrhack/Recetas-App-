//
//  ProfilePage.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 14/09/25.
//

import SwiftUI
struct ProfilePage: View {
    @EnvironmentObject var app: AppNavigation
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var recipes: [Recipe] = []
    @State private var showAddFriend = false // Para presentar la vista de buscar amigos

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Avatar editable (igual que antes)
                    ZStack(alignment: .bottomTrailing) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(radius: 6)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: app.currentUser.isEmpty ? "person.fill" : "person")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        Button {
                            showImagePicker = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.customOrange)
                                .font(.system(size: 30))
                                .background(Color.white.clipShape(Circle()))
                        }
                        .offset(x: 5, y: 5)
                    }

                    // Nombre y bienvenida
                    Text(app.currentUser.isEmpty ? "Anónimo" : app.currentUser)
                        .font(.title)
                        .bold()
                    Text("Bienvenido a tu perfil")
                        .foregroundColor(.gray)

                    // Estadísticas
                    HStack(spacing: 20) {
                        statView(count: recipes.count, label: "Mis recetas")
                        statView(count: recipes.filter { $0.isSaved }.count, label: "Guardadas")
                        statView(count: recipes.filter { $0.isLiked }.count, label: "Favoritas")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.customOrange, lineWidth: 2)
                    )
                    
                    // Botón para buscar amigos
                    Button {
                        showAddFriend = true
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                                .foregroundColor(.white)
                            Text("Buscar amigos")
                                .foregroundColor(.white)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customOrange)
                        .cornerRadius(12)
                    }
                    .padding(.top, 10)
                    .sheet(isPresented: $showAddFriend) {
                        AddFriendView() 
                            .environmentObject(app)
                    }
                    // Botón para cerrar sesión
                        Button {
                            // Limpiar usuario actual y volver a login
                            app.currentUser = ""
                            app.currentFlowState = .login
                        } label: {
                            HStack {
                                Image(systemName: "arrow.backward.square.fill")
                                    .foregroundColor(.white)
                                Text("Cerrar sesión")
                                    .foregroundColor(.white)
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        .padding(.top, 10)
                    HStack{
                        Text("Mis recetas")
                            .padding(.leading,10)
                            .bold()
                        Spacer()
                    }
                    RecipeGridView(recipes: $recipes,currentUser: app.currentUser)
                        .frame(height: 400) // Ajusta según la cantidad de recetas

                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Perfil")
            .onAppear { loadRecipes() }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    // MARK: - Cargar recetas del usuario
    private func loadRecipes() {
        recipes = DatabaseManager.shared.fetchRecipes(forUser: app.currentUser)
    }

    // MARK: - Vista para estadísticas
    private func statView(count: Int, label: String) -> some View {
        VStack {
            Text("\(count)")
                .font(.title2)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(minWidth: 80)
    }
}

// MARK: - Preview
#Preview {
    ProfilePage()
        .environmentObject(AppNavigation())
}
