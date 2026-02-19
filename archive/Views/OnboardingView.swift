import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var showAuth = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "The Intentional Dresser",
            subtitle: "Welcome to Modaics",
            description: "Where every garment tells a story. Discover the meaning behind what you wear and share the memories woven into your wardrobe.",
            icon: "sparkles",
            image: "onboarding_1"
        ),
        OnboardingPage(
            title: "Your Digital Wardrobe",
            subtitle: "Curate with Purpose",
            description: "Build a visual collection of your garments. Each piece documented, each memory preserved, each story ready to be told.",
            icon: "hanger",
            image: "onboarding_2"
        ),
        OnboardingPage(
            title: "Tell Your Story",
            subtitle: "Share What Matters",
            description: "The dress from your first date. The sweater passed down from grandmother. The jacket that traveled the world with you.",
            icon: "quote.bubble",
            image: "onboarding_3"
        ),
        OnboardingPage(
            title: "Discover & Connect",
            subtitle: "A Community of Stories",
            description: "Explore the stories behind garments from around the world. Find inspiration, connection, and the beauty in intentional fashion.",
            icon: "globe",
            image: "onboarding_4"
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.warmSand
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: skipOnboarding) {
                        Text("Skip")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.6))
                    }
                }
                .padding()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Page indicators
                HStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? DesignSystem.Colors.terracotta : DesignSystem.Colors.charcoal.opacity(0.2))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.vertical)
                
                // Navigation buttons
                HStack(spacing: DesignSystem.Spacing.medium) {
                    if currentPage > 0 {
                        Button(action: previousPage) {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .foregroundColor(DesignSystem.Colors.charcoal)
                                .frame(width: 56, height: 56)
                                .background(DesignSystem.Colors.paper)
                                .clipShape(Circle())
                        }
                    }
                    
                    Button(action: nextPage) {
                        HStack(spacing: DesignSystem.Spacing.small) {
                            Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                                .font(DesignSystem.Typography.button)
                            
                            Image(systemName: currentPage == pages.count - 1 ? "checkmark" : "arrow.right")
                                .font(.body.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignSystem.Spacing.xlarge)
                        .padding(.vertical, DesignSystem.Spacing.medium)
                        .background(DesignSystem.Colors.terracotta)
                        .cornerRadius(DesignSystem.CornerRadius.large)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, DesignSystem.Spacing.xlarge)
            }
        }
        .sheet(isPresented: $showAuth) {
            AuthView()
        }
    }
    
    private func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            showAuth = true
        }
    }
    
    private func previousPage() {
        if currentPage > 0 {
            withAnimation {
                currentPage -= 1
            }
        }
    }
    
    private func skipOnboarding() {
        showAuth = true
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let image: String
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xlarge) {
            // Illustration placeholder with icon
            ZStack {
                // Decorative circles
                Circle()
                    .fill(DesignSystem.Colors.terracotta.opacity(0.1))
                    .frame(width: 280, height: 280)
                
                Circle()
                    .fill(DesignSystem.Colors.terracotta.opacity(0.15))
                    .frame(width: 220, height: 220)
                
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(DesignSystem.Colors.paper)
                        .frame(width: 140, height: 140)
                        .shadow(color: DesignSystem.Colors.charcoal.opacity(0.1), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.Colors.terracotta)
                }
            }
            .padding(.top, DesignSystem.Spacing.xlarge)
            
            // Text content
            VStack(spacing: DesignSystem.Spacing.medium) {
                Text(page.subtitle)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.terracotta)
                    .tracking(2)
                    .textCase(.uppercase)
                
                Text(page.title)
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.charcoal)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(DesignSystem.Typography.bodyLarge)
                    .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, DesignSystem.Spacing.xlarge)
            }
            
            Spacer()
        }
    }
}

// MARK: - Auth View
struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showEmailAuth = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.warmSand
                    .ignoresSafeArea()
                
                VStack(spacing: DesignSystem.Spacing.xlarge) {
                    Spacer()
                    
                    // Header
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        Text("Welcome")
                            .font(DesignSystem.Typography.largeTitle)
                            .foregroundColor(DesignSystem.Colors.charcoal)
                        
                        Text("Sign in to continue your journey")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.7))
                    }
                    
                    // Auth buttons
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        // Apple Sign In
                        AppleSignInButton {
                            signInWithApple()
                        }
                        
                        // Google Sign In
                        GoogleSignInButton {
                            signInWithGoogle()
                        }
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(DesignSystem.Colors.charcoal.opacity(0.2))
                                .frame(height: 1)
                            Text("or")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.5))
                            Rectangle()
                                .fill(DesignSystem.Colors.charcoal.opacity(0.2))
                                .frame(height: 1)
                        }
                        
                        // Email Sign In
                        Button(action: { showEmailAuth = true }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Continue with Email")
                            }
                            .font(DesignSystem.Typography.button)
                            .foregroundColor(DesignSystem.Colors.charcoal)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DesignSystem.Colors.paper)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.large)
                    
                    Spacer()
                    
                    // Terms
                    Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationDestination(isPresented: $showEmailAuth) {
                EmailAuthView()
            }
        }
    }
    
    private func signInWithApple() {
        // Implementation handled by AuthService
        Task {
            do {
                try await ServiceLocator.shared.authService.signInWithApple()
                appState.completeOnboarding()
                dismiss()
            } catch {
                print("Apple sign in error: \(error)")
            }
        }
    }
    
    private func signInWithGoogle() {
        // Implementation handled by AuthService
        Task {
            do {
                try await ServiceLocator.shared.authService.signInWithGoogle()
                appState.completeOnboarding()
                dismiss()
            } catch {
                print("Google sign in error: \(error)")
            }
        }
    }
}

// MARK: - Apple Sign In Button
struct AppleSignInButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "apple.logo")
                Text("Continue with Apple")
            }
            .font(DesignSystem.Typography.button)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .cornerRadius(DesignSystem.CornerRadius.medium)
        }
    }
}

// MARK: - Google Sign In Button
struct GoogleSignInButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "g.circle.fill")
                Text("Continue with Google")
            }
            .font(DesignSystem.Typography.button)
            .foregroundColor(DesignSystem.Colors.charcoal)
            .frame(maxWidth: .infinity)
            .padding()
            .background(DesignSystem.Colors.paper)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(DesignSystem.Colors.charcoal.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Email Auth View
struct EmailAuthView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.warmSand
                .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.large) {
                // Toggle
                Picker("", selection: $isSignUp) {
                    Text("Sign In").tag(false)
                    Text("Sign Up").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Form
                VStack(spacing: DesignSystem.Spacing.medium) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(DesignSystem.Colors.paper)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                    
                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .padding()
                        .background(DesignSystem.Colors.paper)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .padding(.horizontal)
                
                if let error = errorMessage {
                    Text(error)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button(action: authenticate) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(DesignSystem.Typography.button)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(DesignSystem.Colors.terracotta)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, DesignSystem.Spacing.xlarge)
        }
        .navigationTitle(isSignUp ? "Create Account" : "Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func authenticate() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isSignUp {
                    try await ServiceLocator.shared.authService.signUp(email: email, password: password)
                } else {
                    try await ServiceLocator.shared.authService.signIn(email: email, password: password)
                }
                
                await MainActor.run {
                    appState.completeOnboarding()
                    dismiss()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Auth Gate View
struct AuthGateView: View {
    @State private var showAuth = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.warmSand
                .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xlarge) {
                Spacer()
                
                // Logo
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.terracotta.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundColor(DesignSystem.Colors.terracotta)
                }
                
                VStack(spacing: DesignSystem.Spacing.small) {
                    Text("Welcome back")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(DesignSystem.Colors.charcoal)
                    
                    Text("Sign in to continue sharing your stories")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.charcoal.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                Button(action: { showAuth = true }) {
                    Text("Sign In")
                        .font(DesignSystem.Typography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(DesignSystem.Colors.terracotta)
                        .cornerRadius(DesignSystem.CornerRadius.large)
                }
                .padding(.horizontal, DesignSystem.Spacing.xlarge)
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showAuth) {
            AuthView()
        }
    }
}