//
//  ProfileViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import PhotosUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: AppUser?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var successMessage = ""
    @Published var isUploadingImage = false

    // Biometric
    @AppStorage("biometricEnabled") var biometricEnabled = false

    private let db = Firestore.firestore()
    private let service = FirestoreService.shared

    // MARK: - Load
    func load() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            user = try await service.fetchUser(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Update username
    func updateUsername(_ username: String) async {
        guard let uid = Auth.auth().currentUser?.uid,
              !username.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        do {
            try await service.updateUser(uid: uid, data: ["username": username])
            user?.username = username
            successMessage = "Username updated successfully"
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Update email
    func updateEmail(_ email: String) async {
        guard let user = Auth.auth().currentUser,
              !email.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        do {
            try await user.sendEmailVerification(beforeUpdatingEmail: email)
            successMessage = "Verification email sent to \(email)"
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Update university
    func updateUniversity(_ university: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await service.updateUser(uid: uid, data: ["university": university])
            self.user?.university = university
            successMessage = "University updated successfully"
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Update major
    func updateMajor(_ major: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await service.updateUser(uid: uid, data: ["major": major])
            self.user?.major = major
            successMessage = "Major updated successfully"
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Update interests
    func updateInterests(_ interests: [String]) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await service.updateUser(uid: uid, data: ["interests": interests])
            self.user?.interests = interests
            successMessage = "Interests updated successfully"
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Send password reset
    func sendPasswordReset() async {
        guard let email = Auth.auth().currentUser?.email else { return }
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            successMessage = "Password reset email sent to \(email)"
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Upload profile image
    func uploadProfileImage(_ image: UIImage) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isUploadingImage = true
        defer { isUploadingImage = false }
        do {
            let url = try await service.uploadProfileImage(uid: uid, image: image)
            user?.profileImage = url
            successMessage = "Profile photo updated"
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Sign out
    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Biometric toggle
    func toggleBiometric() async {
        if !biometricEnabled {
            let success = await BiometricService.shared.authenticate(
                reason: "Enable \(BiometricService.shared.biometricLabel) for Kuppiya"
            )
            if success {
                biometricEnabled = true
                successMessage = "\(BiometricService.shared.biometricLabel) enabled"
                showSuccess = true
            }
        } else {
            biometricEnabled = false
        }
    }
}
