//
//  OTPVerificationView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct OTPVerificationView: View {
    @Binding var currentScreen: AppNavigationView.Screen
    let email: String

    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = OTPViewModel()
    @FocusState private var focusedIndex: Int?

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()

            VStack(spacing: 0) {
                // Back
                HStack {
                    Button {
                        currentScreen = .signup
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                VStack(spacing: 8) {
                    Text("Verify Your Email")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)

                    Text("A verification link was sent to")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)

                    Text(email)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.brandPrimary)
                }
                .padding(.bottom, 40)

                // Info box
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.brandPrimary)
                    Text("Click the link in your email, then tap Verify below")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color.brandPrimary.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)

                // Verify button
                KButton(
                    title: "I've Verified My Email",
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        await viewModel.checkVerification()
                        if viewModel.isVerified {
                            currentScreen = .login
                        }
                    }
                }
                .padding(.horizontal, 32)

                // Resend
                HStack(spacing: 4) {
                    Text("Didn't receive it?")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)

                    if viewModel.resendTimer > 0 {
                        Text("Resend in \(viewModel.resendTimer)s")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    } else {
                        Button("Resend Email") {
                            Task { await viewModel.resendCode() }
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.brandPrimary)
                    }
                }
                .padding(.top, 16)

                Spacer()
            }
        }
        .onAppear {
            viewModel.startTimer()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
