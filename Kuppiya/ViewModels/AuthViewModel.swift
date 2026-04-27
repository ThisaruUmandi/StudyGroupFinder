//
//  AuthViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-16.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class AuthViewModel: ObservableObject {

    // MARK: - Auth State
    @Published var currentUser: AppUser?
    @Published var isLoggedIn: Bool      = false
    @Published var isLoading: Bool       = false
    @Published var errorMessage: String?
    @Published var showError: Bool       = false

    // MARK: - Sign Up fields
    @Published var username: String = ""
    @Published var email: String    = ""
    @Published var password: String = ""
    @Published var signUpSuccess    = false

    // MARK: - Login fields
    @Published var loginEmail: String    = ""
    @Published var loginPassword: String = ""

    // MARK: - Password Reset
    @Published var resetEmailSent = false

    // MARK: - Services
    private let authService      = FirebaseAuthService.shared
    private let biometricService = BiometricService.shared

    // MARK: - Computed
    var isBiometricAvailable: Bool {
        biometricService.isBiometricAvailable
    }
    var hasSavedCredentials: Bool {
        biometricService.hasSavedCredentials
    }

    // ─────────────────────────────────────
    // MARK: - Sign Up
    // ─────────────────────────────────────
    func signUp() async {
        guard !username.isEmpty,
              !email.isEmpty,
              !password.isEmpty else {
            showError(message: "Please fill in all fields.")
            return
        }
        guard password.count >= 6 else {
            showError(message: "Password must be at least 6 characters.")
            return
        }
        guard email.contains("@") else {
            showError(message: "Please enter a valid email.")
            return
        }

        isLoading = true
        do {
            let user = try await authService.signUp(
                username: username,
                email: email,
                password: password
            )
            currentUser  = user
            signUpSuccess = true  // triggers OTP navigation
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }

    // ─────────────────────────────────────
    // MARK: - Login with Email
    // ─────────────────────────────────────
    func login() async {
        guard !loginEmail.isEmpty,
              !loginPassword.isEmpty else {
            showError(message: "Please enter your email and password.")
            return
        }

        isLoading = true
        do {
            let user = try await authService.signIn(
                email: loginEmail,
                password: loginPassword
            )
            // Save to Keychain for Face ID
            biometricService.saveCredentials(
                email: loginEmail,
                password: loginPassword
            )
            currentUser = user
            isLoggedIn  = true
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }

    // ─────────────────────────────────────
    // MARK: - Google Sign-In
    // ─────────────────────────────────────
    func signInWithGoogle() async {
        isLoading = true
        do {
            let user = try await authService.signInWithGoogle()
            currentUser = user
            isLoggedIn  = true
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }

    // ─────────────────────────────────────
    // MARK: - Face ID Login
    // ─────────────────────────────────────
    
    // MARK: - Auto Face ID (call this when LoginView appears)
    func tryAutoFaceID() async {
        // Only auto-trigger if:
        // 1. User has saved credentials
        // 2. Face ID is available
        guard biometricService.hasSavedCredentials,
              biometricService.isBiometricAvailable else {
            return  // silently do nothing — no error shown
        }

        let success = await biometricService.authenticate()
        guard success else {
            return  // silently fail — don't show error on auto-trigger
        }

        guard let creds = biometricService.loadCredentials() else {
            return
        }

        isLoading = true
        do {
            let user = try await authService.signIn(
                email: creds.email,
                password: creds.password
            )
            currentUser = user
            isLoggedIn  = true
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }
    
    //-----------------------------
    
    func loginWithFaceID() async {
        guard biometricService.hasSavedCredentials else {
            showError(message: "Please log in with email first to enable Face ID.")
            return
        }

        let success = await biometricService.authenticate()
        guard success else {
            showError(message: "Face ID authentication failed.")
            return
        }

        guard let creds = biometricService.loadCredentials() else {
            return
        }

        isLoading = true
        do {
            let user = try await authService.signIn(
                email: creds.email,
                password: creds.password
            )
            currentUser = user
            isLoggedIn  = true
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }

    // ─────────────────────────────────────
    // MARK: - Email Verification
    // ─────────────────────────────────────
    func checkEmailVerified() async -> Bool {
        do {
            return try await authService.checkEmailVerified()
        } catch {
            showError(message: error.localizedDescription)
            return false
        }
    }

    func resendVerificationEmail() async {
        do {
            try await authService.resendVerificationEmail()
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    // ─────────────────────────────────────
    // MARK: - Forgot Password
    // ─────────────────────────────────────
    func sendPasswordReset(email: String) async {
        guard !email.isEmpty else {
            showError(message: "Please enter your email.")
            return
        }
        do {
            try await authService.resetPassword(email: email)
            resetEmailSent = true
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    // ─────────────────────────────────────
    // MARK: - Session Check
    // Per Firebase docs: Firebase persists auth state
    // automatically — just check currentUser
    // ─────────────────────────────────────
    func checkSession() {
        // Firebase automatically restores auth state
        // We DON'T auto-login — user must authenticate each launch
        // isLoggedIn stays false until manual login
    }

    // ─────────────────────────────────────
    // MARK: - Sign Out
    // ─────────────────────────────────────
    func signOut() {
        do {
            try authService.signOut()
            biometricService.clearCredentials()
            currentUser   = nil
            isLoggedIn    = false
            signUpSuccess = false
            loginEmail    = ""
            loginPassword = ""
            username      = ""
            email         = ""
            password      = ""
        } catch {
            showError(message: error.localizedDescription)
        }
    }

    // ─────────────────────────────────────
    // MARK: - Helper
    // ─────────────────────────────────────
    private func showError(message: String) {
        errorMessage = message
        showError    = true
    }
    
    // ─────────────────────────────────────
    // MARK: - Refresh after Save
    // ─────────────────────────────────────
    func refreshUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        currentUser = try? await FirestoreService.shared.fetchUser(uid: uid)
    }
    
}
