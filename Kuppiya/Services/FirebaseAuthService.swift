//
//  FirebaseAuthService.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-16.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FirebaseCore

class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    private let db = Firestore.firestore()

    // MARK: - Current user UID
    var currentUID: String? {
        Auth.auth().currentUser?.uid
    }

    var currentFirebaseUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    // MARK: - Sign Up with Email
    func signUp(
        username: String,
        email: String,
        password: String
    ) async throws -> AppUser {
        // 1. Create Firebase Auth user
        let result = try await Auth.auth()
            .createUser(withEmail: email, password: password)
        let uid = result.user.uid

        // 2. Send email verification (per Firebase docs)
        try await result.user.sendEmailVerification()

        // 3. Build and save user to Firestore
        let newUser = AppUser(
            uid: uid,
            username: username,
            email: email,
            profileImage: "",
            university: "",
            //major: "",
            joinedGroups: [],
            createdAt: Date(),
            fcmToken: ""
        )
        try db.collection("users")
            .document(uid)
            .setData(from: newUser)

        return newUser
    }

    // MARK: - Sign In with Email
    func signIn(
        email: String,
        password: String
    ) async throws -> AppUser {
        let result = try await Auth.auth()
            .signIn(withEmail: email, password: password)
        let uid = result.user.uid

        // Fetch user profile from Firestore
        return try await fetchUser(uid: uid)
    }

    // MARK: - Google Sign-In
    // Per Firebase docs: get clientID from FirebaseApp,
    // present sign-in, exchange token with Firebase
    func signInWithGoogle() async throws -> AppUser {
        // Get client ID from Firebase config
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }

        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Get top-most view controller to present Google UI
        guard let windowScene = UIApplication.shared
            .connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows
            .first?.rootViewController else {
            throw AuthError.noViewController
        }

        // Present Google Sign-In
        let result = try await GIDSignIn.sharedInstance
            .signIn(withPresenting: rootVC)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingToken
        }

        // Exchange Google token with Firebase
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        let authResult = try await Auth.auth()
            .signIn(with: credential)
        let uid = authResult.user.uid

        // Check if user exists in Firestore, create if not
        let userDoc = try await db.collection("users")
            .document(uid)
            .getDocument()

        if userDoc.exists,
           let user = try? userDoc.data(as: AppUser.self) {
            return user
        } else {
            // First time Google sign-in — create Firestore record
            let newUser = AppUser(
                uid: uid,
                username: result.user.profile?.name ?? "",
                email: result.user.profile?.email ?? "",
                profileImage: result.user.profile?
                    .imageURL(withDimension: 200)?
                    .absoluteString ?? "",
                university: "",
                //major: "",
                joinedGroups: [],
                createdAt: Date(),
                fcmToken: ""
            )
            try db.collection("users")
                .document(uid)
                .setData(from: newUser)
            return newUser
        }
    }

    // MARK: - Email Verification Check
    func checkEmailVerified() async throws -> Bool {
        // Reload user to get latest verification status
        try await Auth.auth().currentUser?.reload()
        return Auth.auth().currentUser?.isEmailVerified ?? false
    }

    // MARK: - Resend Verification Email
    func resendVerificationEmail() async throws {
        try await Auth.auth().currentUser?
            .sendEmailVerification()
    }

    // MARK: - Password Reset
    func resetPassword(email: String) async throws {
        try await Auth.auth()
            .sendPasswordReset(withEmail: email)
    }

    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
        // Also sign out from Google if needed
        GIDSignIn.sharedInstance.signOut()
    }

    // MARK: - Session Check (per Firebase docs)
    // Firebase persists auth state automatically
    func checkSession() -> Bool {
        return Auth.auth().currentUser != nil
    }

    // MARK: - Fetch user from Firestore
    func fetchUser(uid: String) async throws -> AppUser {
        let doc = try await db.collection("users")
            .document(uid)
            .getDocument()
        guard let user = try? doc.data(as: AppUser.self) else {
            throw AuthError.userNotFound
        }
        return user
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case missingClientID
    case noViewController
    case missingToken
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Firebase client ID not found"
        case .noViewController:
            return "Could not find view controller"
        case .missingToken:
            return "Google sign-in token missing"
        case .userNotFound:
            return "User profile not found"
        }
    }
}
