//
//  SessionDetailViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-01.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class SessionDetailViewModel: ObservableObject {
    @Published var creatorName = ""
    @Published var reviewText = ""
    @Published var rating = 0
    @Published var isSubmitting = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var didCancel = false
    @Published var editTitle = ""
    @Published var editDescription = ""
    @Published var isEditing = false

    private let service = FirestoreService.shared

    var currentUid: String { Auth.auth().currentUser?.uid ?? "" }

    func canManage(session: StudySession, group: StudyGroup) -> Bool {
        currentUid == session.createdBy || currentUid == group.createdBy
    }

    func loadCreator(uid: String) async {
        let user    = try? await service.fetchUser(uid: uid)
        creatorName = user?.username ?? "Unknown"
    }

    func cancelSession(session: StudySession) async {
        do {
            try await service.deleteSession(
                sessionId: session.sessionId,
                groupId: session.groupId
            )
            didCancel = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func markCompleted(session: StudySession) async {
        do {
            try await service.updateSessionStatus(
                sessionId: session.sessionId,
                groupId: session.groupId,
                status: "completed"
            )
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func submitReview(session: StudySession) async {
        guard rating > 0 else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await service.submitReview(
                groupId: session.groupId,
                rating: rating,
                review: reviewText
            )
            reviewText = ""
            rating = 0
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func startEditing(session: StudySession) {
        editTitle = session.title
        editDescription = session.description
        isEditing = true
    }

    func saveEdits(session: StudySession) async {
        guard !session.sessionId.isEmpty, !session.groupId.isEmpty else {
            errorMessage = "Session data is missing."
            showError = true
            return
        }
        do {
            try await service.updateSessionInfo(
                sessionId: session.sessionId,
                groupId: session.groupId,
                title: editTitle,
                description: editDescription
            )
            isEditing = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

