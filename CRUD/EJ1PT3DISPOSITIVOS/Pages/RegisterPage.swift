import SwiftUI

struct RegisterPage: View {
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @EnvironmentObject private var app: AppNavigation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Registro de Usuario")
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

            SecureField("Confirmar Contraseña", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)

            Button("Registrar") {
                if password != confirmPassword {
                    message = "Las contraseñas no coinciden"
                    return
                }
                
                if DatabaseManager.shared.registerUser(username: username, password: password) {
                    message = "Usuario registrado con éxito ✅"
                    // Cambiamos el flujo a HomePage
                    app.login(username: username)
                } else {
                    message = "Error: Usuario ya existe o fallo en la base de datos"
                }
            }
            .buttonStyle(.borderedProminent)

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(message.contains("✅") ? .green : .red)
            }
          
          
            Button("¿Ya tienes cuenta? Inicia sesión") {
                           dismiss()
            }
            .padding(30)
        }
        .padding()
    }
}

#Preview {
    RegisterPage()
        .environmentObject(AppNavigation())
}
