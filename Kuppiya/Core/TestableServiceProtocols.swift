//
//  TestableServiceProtocols.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-07.
//

import Foundation

protocol AuthServicing {
    func signUp(username: String, email: String, password: String) async throws -> AppUser
    func signIn(email: String, password: String) async throws -> AppUser
    func signInWithGoogle() async throws -> AppUser
    func checkEmailVerified() async throws -> Bool
    func resendVerificationEmail() async throws
    func resetPassword(email: String) async throws
    func signOut() throws
}

protocol BiometricServicing {
    var isBiometricAvailable: Bool { get }
    var hasSavedCredentials: Bool { get }
    func authenticate() async -> Bool
    func saveCredentials(email: String, password: String)
    func loadCredentials() -> (email: String, password: String)?
    func clearCredentials()
}

protocol GroupSessionServicing {
    func fetchSessions(for groupId: String) async throws -> [StudySession]
}

extension FirebaseAuthService: AuthServicing {}
extension BiometricService: BiometricServicing {}
extension FirestoreService: GroupSessionServicing {}
