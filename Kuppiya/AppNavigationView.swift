//
//  AppNavigationView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-16.
//

import SwiftUI

struct AppNavigationView: View {
    @AppStorage("hasSeenOnboarding")
    private var hasSeenOnboarding = false
    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentScreen: Screen = .landing

    enum Screen {
        case landing
        case onboarding
        case signup
        case otpVerification
        case login
    }

    var body: some View {
        ZStack {
            switch currentScreen {
            case .landing:
                LandingView(currentScreen: $currentScreen)

            case .onboarding:
                OnboardingView(currentScreen: $currentScreen)

            case .signup:
                SignUpView(currentScreen: $currentScreen)
                    .environmentObject(authVM)

            case .otpVerification:
                OTPVerificationView(
                    currentScreen: $currentScreen,
                    email: authVM.email
                )
                .environmentObject(authVM)

            case .login:
                LoginView(currentScreen: $currentScreen)
                    .environmentObject(authVM)
                    .onAppear { hasSeenOnboarding = true }
            }
        }
        .onAppear {
            if hasSeenOnboarding {
                currentScreen = .login
            }
        }
    }
}
