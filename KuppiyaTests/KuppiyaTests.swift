//
//  KuppiyaTests.swift
//  KuppiyaTests
//
//  Created by M H T U De Silva on 2026-04-01.
//

import Foundation
import Testing
@testable import Kuppiya

struct KuppiyaTests {

    // MARK: - AuthViewModel tests

    @MainActor
    @Test func signUp_emptyFields_showsError() async {
        let vm = AuthViewModel(
            authService: MockAuthService(),
            biometricService: MockBiometricService()
        )

        vm.username = ""
        vm.email = ""
        vm.password = ""

        await vm.signUp()

        #expect(vm.showError)
        #expect(vm.errorMessage == "Please fill in all fields.")
    }

    @MainActor
    @Test func signUp_shortPassword_showsError() async {
        let vm = AuthViewModel(
            authService: MockAuthService(),
            biometricService: MockBiometricService()
        )

        vm.username = "test"
        vm.email = "test@mail.com"
        vm.password = "123"

        await vm.signUp()

        #expect(vm.showError)
        #expect(vm.errorMessage == "Password must be at least 6 characters.")
    }

    @MainActor
    @Test func login_emptyCredentials_showsError() async {
        let vm = AuthViewModel(
            authService: MockAuthService(),
            biometricService: MockBiometricService()
        )

        vm.loginEmail = ""
        vm.loginPassword = ""

        await vm.login()

        #expect(vm.showError)
        #expect(vm.errorMessage == "Please enter your email and password.")
    }

    @MainActor
    @Test func login_success_setsLoggedInAndUser() async {
        let auth = MockAuthService()
        auth.signInResult = .success(makeUser(uid: "u1", username: "Alex"))
        let bio = MockBiometricService()

        let vm = AuthViewModel(authService: auth, biometricService: bio)
        vm.loginEmail = "alex@mail.com"
        vm.loginPassword = "secret123"

        await vm.login()

        #expect(vm.isLoggedIn)
        #expect(vm.currentUser?.uid == "u1")
        #expect(bio.savedEmail == "alex@mail.com")
        #expect(bio.savedPassword == "secret123")
    }

    @MainActor
    @Test func login_failure_showsError() async {
        let auth = MockAuthService()
        auth.signInResult = .failure(MockError.failed)

        let vm = AuthViewModel(
            authService: auth,
            biometricService: MockBiometricService()
        )
        vm.loginEmail = "bad@mail.com"
        vm.loginPassword = "wrongpass"

        await vm.login()

        #expect(!vm.isLoggedIn)
        #expect(vm.showError)
        #expect(vm.errorMessage == MockError.failed.localizedDescription)
    }

    // MARK: - SessionViewModel tests

    @MainActor
    @Test func sessionFilter_online_returnsOnlyOnline() async {
        let now = Date()
        let sessions = [
            makeSession(id: "1", date: now.addingTimeInterval(7200), type: "online"),
            makeSession(id: "2", date: now.addingTimeInterval(10800), type: "physical")
        ]

        let vm = SessionViewModel(service: MockSessionService(sessions: sessions))
        await vm.load(for: "g1")
        vm.selectedFilter = SessionViewModel.SessionFilter.online

        #expect(vm.upcomingSessions.count == 1)
        #expect(vm.upcomingSessions.first?.isOnline == true)
    }

    @MainActor
    @Test func sessionFilter_physical_returnsOnlyPhysical() async {
        let now = Date()
        let sessions = [
            makeSession(id: "1", date: now.addingTimeInterval(7200), type: "online"),
            makeSession(id: "2", date: now.addingTimeInterval(10800), type: "physical")
        ]

        let vm = SessionViewModel(service: MockSessionService(sessions: sessions))
        await vm.load(for: "g1")
        vm.selectedFilter = SessionViewModel.SessionFilter.physical

        #expect(vm.upcomingSessions.count == 1)
        #expect(vm.upcomingSessions.first?.isPhysical == true)
    }

    @MainActor
    @Test func sessionLoad_failure_showsError() async {
        let vm = SessionViewModel(
            service: MockSessionService(error: MockError.failed)
        )

        await vm.load(for: "g1")

        #expect(vm.showError)
        #expect(vm.errorMessage == MockError.failed.localizedDescription)
    }
}

// MARK: - Mocks

private enum MockError: LocalizedError {
    case failed
    var errorDescription: String? { "Mock operation failed." }
}

private final class MockAuthService: AuthServicing {
    var signInResult: Result<AppUser, Error> = .success(
        makeUser(uid: "default", username: "Default")
    )

    func signUp(username: String, email: String, password: String) async throws -> AppUser {
        makeUser(uid: "signup", username: username)
    }

    func signIn(email: String, password: String) async throws -> AppUser {
        switch signInResult {
        case .success(let user): return user
        case .failure(let error): throw error
        }
    }

    func signInWithGoogle() async throws -> AppUser {
        makeUser(uid: "google", username: "GoogleUser")
    }

    func checkEmailVerified() async throws -> Bool { true }
    func resendVerificationEmail() async throws {}
    func resetPassword(email: String) async throws {}
    func signOut() throws {}
}

private final class MockBiometricService: BiometricServicing {
    var isBiometricAvailable: Bool = true
    var hasSavedCredentials: Bool = false
    var savedEmail: String?
    var savedPassword: String?

    func authenticate() async -> Bool { true }

    func saveCredentials(email: String, password: String) {
        savedEmail = email
        savedPassword = password
        hasSavedCredentials = true
    }

    func loadCredentials() -> (email: String, password: String)? {
        guard let email = savedEmail, let password = savedPassword else { return nil }
        return (email, password)
    }

    func clearCredentials() {
        savedEmail = nil
        savedPassword = nil
        hasSavedCredentials = false
    }
}

private struct MockSessionService: GroupSessionServicing {
    var sessions: [StudySession] = []
    var error: Error?

    init(sessions: [StudySession] = [], error: Error? = nil) {
        self.sessions = sessions
        self.error = error
    }

    func fetchSessions(for groupId: String) async throws -> [StudySession] {
        if let error { throw error }
        return sessions
    }
}

// MARK: - Helpers

private func makeUser(uid: String, username: String) -> AppUser {
    AppUser(
        id: nil,
        uid: uid,
        username: username,
        email: "\(username.lowercased())@mail.com",
        profileImage: "",
        university: "",
        major: "",
        joinedGroups: [],
        interests: [],
        createdAt: Date(),
        fcmToken: ""
    )
}

private func makeSession(id: String, date: Date, type: String) -> StudySession {
    StudySession(
        id: nil,
        sessionId: id,
        groupId: "g1",
        groupName: "Group",
        title: "Session \(id)",
        description: "Desc",
        date: date,
        startTime: "10:00 AM",
        type: type,
        joinLink: "",
        location: "",
        latitude: 0,
        longitude: 0,
        status: "upcoming",
        createdBy: "u1",
        createdByName: "Alex",
        attendees: []
    )
}
