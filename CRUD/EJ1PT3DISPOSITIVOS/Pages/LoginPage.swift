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
    @EnvironmentObject private var app: AppNavigation
    
    var body: some View {
        ZStack{
           
            ZStack{
                Circle()
                    .fill(Color("CustomOrange"))
                
            }
            .offset(x: 100,y:-200)

            ZStack{
                Image("Iconapp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                   
            }
            .offset(x: 1,y:0)
        }
        ZStack{
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
                    
                    SecureField("Contraseña", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(8)
                    
                    Button("Entrar") {
                        
                        Task {
                            let success = DatabaseManager.shared.loginUser(username: username, password: password)
                            
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
                    }
                    Button("¿No tienes cuenta? Regístrate") {
                        showRegister = true
                    }
                }
                .navigationDestination(isPresented: $showRegister) {
                    RegisterPage()
                }
                .padding()
            }
        }
    }}
#Preview {
    LoginPage()
        .environmentObject(AppNavigation())
        
}
