//
//  AddFriende.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 14/09/25.
//


import SwiftUI

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var app: AppNavigation
    @State private var searchText: String = ""
    
    // Lista de todos los usuarios (simulada)
    @State private var allUsers: [String] = []
    // Lista filtrada según búsqueda
    @State private var filteredUsers: [String] = []
    // Amigos agregados temporalmente
    @State private var friends: Set<String> = []

    var body: some View {
        NavigationStack {
            VStack {
                // Campo de búsqueda
                TextField("Buscar usuarios...", text: $searchText)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onChange(of: searchText) {
                        filterUsers()
                    }

                // Lista de usuarios
                List(filteredUsers, id: \.self) { user in
                    HStack {
                        Text(user)
                        Spacer()
                        Button {
                            addFriend(user: user)
                        } label: {
                            Text(friends.contains(user) ? "Agregado" : "Agregar")
                                .foregroundColor(friends.contains(user) ? .green : .customOrange)
                                .bold()
                        }
                        .disabled(friends.contains(user))
                    }
                }
            }
            .navigationTitle("Buscar amigos")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadUsers()
            }
        }
    }

    // Filtrar usuarios según búsqueda
    private func filterUsers() {
        if searchText.isEmpty {
            filteredUsers = allUsers
        } else {
            filteredUsers = allUsers.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }

    // Cargar usuarios simulados (excepto el usuario actual)
    private func loadUsers() {
        allUsers = DatabaseManager.shared.fetchAllUsers(excluding: app.currentUser)
            filteredUsers = allUsers
    }

    // Agregar amigo
    private func addFriend(user: String) {
        DatabaseManager.shared.addFriend(user: app.currentUser, friendUser: user)
           friends.insert(user)
    }
}

#Preview {
    AddFriendView()
        .environmentObject(AppNavigation())
}
