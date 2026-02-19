import SwiftUI

struct AuthGateView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.warmSand
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo
                VStack(spacing: 16) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 64))
                        .foregroundColor(DesignSystem.Colors.terracotta)
                    
                    Text("Modaics")
                        .font(.system(size: 36, weight: .medium, design: .serif))
                        .foregroundColor(DesignSystem.Colors.charcoal)
                    
                    Text("Your wardrobe, piece by piece")
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(DesignSystem.Colors.olive)
                }
                
                Spacer()
                
                // Auth Form
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textFieldStyle(ModaicsTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(ModaicsTextFieldStyle())
                    
                    Button(action: {
                        // For preview: just mark as authenticated
                        appState.isAuthenticated = true
                    }) {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(DesignSystem.Colors.terracotta)
                            .cornerRadius(12)
                    }
                    
                    Button(action: { isSignUp.toggle() }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.olive)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Skip for now
                Button(action: {
                    appState.isAuthenticated = true
                }) {
                    Text("Skip for now")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.olive.opacity(0.7))
                }
                .padding(.bottom, 32)
            }
        }
    }
}

struct ModaicsTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(DesignSystem.Colors.cream)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(DesignSystem.Colors.olive.opacity(0.2), lineWidth: 1)
            )
    }
}

struct AuthGateView_Previews: PreviewProvider {
    static var previews: some View {
        AuthGateView()
            .environmentObject(AppState())
    }
}
