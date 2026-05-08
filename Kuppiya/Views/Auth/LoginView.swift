//
//  LoginView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-16.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var currentScreen: AppNavigationView.Screen
    @State private var showPassword = false
    @State private var showForgotSheet = false
    @State private var resetEmail = ""

    private let biometric = BiometricService.shared

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Title
                VStack(spacing: 6) {
                    Text("Login")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Welcome back to Kuppiya!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(.top, 5)
                }
                .padding(.top, 48)
                
                Image("upboy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    //.offset(y: -40)
                    .padding(.top, 16)

                // MARK: Card
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray.opacity(0.15))
                        .shadow(color: .black.opacity(0.06),
                                radius: 12, x: 0, y: 4)

                    VStack(spacing: 16) {

                        // Email
                        CustomTextField(
                            icon: "envelope",
                            placeholder: "Email",
                            text: $authViewModel.loginEmail,
                            isSecure: false,
                            showToggle: false
                        )

                        // Password
                        CustomTextField(
                            icon: "lock",
                            placeholder: "Password",
                            text: $authViewModel.loginPassword,
                            isSecure: !showPassword,
                            showToggle: true,
                            showPassword: $showPassword
                        )

                        // Forgot password
                        HStack {
                            Spacer()
                            Button("Forget Password ?") {
                                showForgotSheet = true
                            }
                            .font(.system(size: 13))
                            .foregroundColor(.brandPrimary)
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 0)

                        // Login button
                        Button {
                            Task {
                                await authViewModel.login()
                            }
                        } label: {
                            ZStack {
                                if authViewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Login")
                                        .font(.system(size: 16,
                                                      weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color(hex: "#0300BF"))
                            .cornerRadius(30)
                        }
                        .disabled(authViewModel.isLoading)
                        .padding(.top, 30)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                }
                .padding(.horizontal, 20)
                .padding(.top, -25)

                // MARK: Divider
                HStack {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.gray.opacity(0.4))
                    Text("or login with")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .fixedSize()
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.gray.opacity(0.4))
                }
                .padding(.horizontal, 40)
                .padding(.top, 60)

                // MARK: Social buttons + Face ID
                HStack(spacing: 20) {
                    // Google
                    SocialButton(imageName: "google") {
                        Task { await authViewModel.signInWithGoogle() }
                    }

                    // Face ID
                    Button {
                        Task { await authViewModel.loginWithFaceID() }
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(
                                    biometric.hasSavedCredentials
                                    ? Color.brandPrimary
                                    : Color.gray.opacity(0.3),
                                    lineWidth: biometric.hasSavedCredentials ? 2 : 1
                                )
                                .frame(width: 52, height: 52)
                            Image(systemName: "faceid")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundColor(
                                    biometric.hasSavedCredentials
                                    ? .brandPrimary
                                    : .gray
                                )
                        }
                    }

                    // Apple
                    SocialButton(
                        imageName: "apple.logo",
                        isSystemImage: true
                    ) {}
                }
                .padding(.top, 30)

                // Face ID hint
                if biometric.isBiometricAvailable {
                    Text(biometric.hasSavedCredentials
                         ? "Tap Face ID to login instantly"
                         : "Login once to enable Face ID")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }

                // MARK: Sign Up redirect
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    Button("Sign Up") {
                        currentScreen = .signup
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.brandPrimary)
                }
                .padding(.top, 30)
                .padding(.bottom, 15)

                Spacer()
            }
        }
        .onAppear {
            if biometric.hasSavedCredentials &&
               biometric.isBiometricAvailable {
                Task { await authViewModel.loginWithFaceID() }
            }
        }
        
        // MARK: Forgot Password Sheet
        .sheet(isPresented: $showForgotSheet) {
            ForgotPasswordSheet(
                email: $resetEmail,
                onSend: {
                    Task {
                        await authViewModel.sendPasswordReset(
                            email: resetEmail)
                        showForgotSheet = false
                    }
                }
            )
            .presentationDetents([.height(300)])
        }
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
        .alert("Email Sent", isPresented: $authViewModel.resetEmailSent) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Password reset email has been sent.")
        }
    }
}

// MARK: - Forgot Password Sheet
struct ForgotPasswordSheet: View {
    @Binding var email: String
    var onSend: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 24)

            Text("Enter your email and we'll send\na password reset link.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            CustomTextField(
                icon: "envelope",
                placeholder: "Email address",
                text: $email,
                isSecure: false,
                showToggle: false
            )
            .padding(.horizontal, 24)

            Button(action: onSend) {
                Text("Send Reset Email")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "#0300BF"))
                    .cornerRadius(30)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

#Preview {
    LoginView(currentScreen: .constant(.login))
        .environmentObject(AuthViewModel())
}
