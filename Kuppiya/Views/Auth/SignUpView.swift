//
//  SignUpView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-16.
//


import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var currentScreen: AppNavigationView.Screen
    @State private var showPassword = false

    private let buttonColor = Color(hex: "0300BF")

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Title
                VStack(spacing: 6) {
                    Text("Sign Up")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    Text("One step closer to Group studies")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(.top, 48)

                // MARK: Card
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray.opacity(0.15))
                        .shadow(color: .black.opacity(0.06),
                                radius: 12, x: 0, y: 4)
                        .padding(.top, 45)

                    VStack(spacing: 16) {
                        Image("upboy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 100)
                            .padding(.top, -34)

                        // Username
                        CustomTextField(
                            icon: "person",
                            placeholder: "Username",
                            text: $authViewModel.username,
                            isSecure: false,
                            showToggle: false
                        )

                        // Email
                        CustomTextField(
                            icon: "envelope",
                            placeholder: "Email",
                            text: $authViewModel.email,
                            isSecure: false,
                            showToggle: false
                        )

                        // Password
                        CustomTextField(
                            icon: "lock",
                            placeholder: "Password",
                            text: $authViewModel.password,
                            isSecure: !showPassword,
                            showToggle: true,
                            showPassword: $showPassword
                        )

                        // Create Account button
                        Button {
                            Task {
                                await authViewModel.signUp()
                                if authViewModel.signUpSuccess {
                                    currentScreen = .otpVerification
                                }
                            }
                        } label: {
                            ZStack {
                                if authViewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Create Account")
                                        .font(.system(size: 16,
                                                      weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(buttonColor)
                            .cornerRadius(30)
                        }
                        .disabled(authViewModel.isLoading)
                        .padding(.top, 40)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                // MARK: Divider
                HStack {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.gray.opacity(0.4))
                    Text("or sign up with")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .fixedSize()
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.gray.opacity(0.4))
                }
                .padding(.horizontal, 40)
                .padding(.top, 28)

                // MARK: Social buttons
                HStack(spacing: 20) {
                    SocialButton(imageName: "google") {
                        Task {
                            await authViewModel.signInWithGoogle()
                        }
                    }
                    SocialButton(
                        imageName: "apple.logo",
                        isSystemImage: true
                    ) {}
                }
                .padding(.top, 20)

                // MARK: Login redirect
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    Button("Login") {
                        currentScreen = .login
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.brandPrimary)
                }
                .padding(.top, 24)

                Spacer()
            }
        }
        .alert("Error", isPresented: $authViewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    SignUpView(currentScreen: .constant(.signup))
        .environmentObject(AuthViewModel())
}
