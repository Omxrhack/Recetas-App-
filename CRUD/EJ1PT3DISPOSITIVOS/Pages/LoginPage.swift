//
//  LoginPage.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 11/09/25.
//

import SwiftUI

struct LoginPage: View {
    @State private var username = ""
    @State private var password = ""
    @State private var message = ""
    @State private var showRegister = false
    @State private var showPassword = false
    @EnvironmentObject private var app: AppNavigation
    
    var body: some View {
        
        ZStack {
            Circle()
                .fill(Color.customOrange)
                .frame(width: 400, height: 500)
                .offset(x: 170 ,y: -390)
                .zIndex(1)
                .ignoresSafeArea()

            NavigationStack{
                
                
                VStack(spacing: 16) {
                    
                    Text("Iniciar Sesión")
                        .font(.title)
                        .bold()
                    
                    TextField("Usuario", text: $username)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(8)
                    HStack {
                        if showPassword {
                            TextField("Contraseña", text: $password)
                        } else {
                            SecureField("Contraseña", text: $password)
                        }
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(8)
                    
                    Button("Entrar") {
                        
                        Task {
                            let success = DatabaseManager.shared.loginUser(username: username, password: password)
                            guard !username.isEmpty, !password.isEmpty else {
                                message = "Completa todos los campos"
                                
                                return
                            }
                            
                            
                            await MainActor.run {
                                if success {
                                    app.login(username: username)
                                } else {
                                    message = "Usuario o contraseña incorrectos"
                                }
                            }
                        }
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    
                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(.red)
                            .transition(.opacity)
                            .animation(.easeInOut, value: message)
                    }
                    
                    Button(action: { showRegister = true }) {
                        Text("¿No tienes cuenta? Regístrate")
                            .foregroundColor(.blue)
                            .underline()
                    }
                    
                }
                .navigationDestination(isPresented: $showRegister) {
                    RegisterPage()
                }
                .padding()
            }
            .padding()
        }
   
        
    }
}
#Preview {
    LoginPage()
        .environmentObject(AppNavigation())
        
}
