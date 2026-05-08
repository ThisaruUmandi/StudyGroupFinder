//
//  GroupDetailViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-27.
//

import SwiftUI
import FirebaseAuth
import Combine

@MainActor
final class GroupDetailViewModel: ObservableObject {
    @Published var reviews: [GroupReview] = []
    @Published var isMember = false
    @Published var hasPendingRequest = false
    @Published var isActing = false
    @Published var navigateToDashboard = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let service = FirestoreService.shared

    func load(group: StudyGroup, uid: String) async {
        isMember = group.isMember(uid: uid)

        async let reviewsFetch = service.fetchReviews(for: group.groupId)
        async let pendingFetch = service.checkPendingRequest(groupId: group.groupId)

        reviews = (try? await reviewsFetch) ?? []
        hasPendingRequest = (try? await pendingFetch) ?? false
    }

    func join(_ group: StudyGroup) async {
        isActing = true
        defer { isActing = false }
        do {
            try await service.joinPublicGroup(group)
            isMember = true
            navigateToDashboard = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func requestJoin(_ group: StudyGroup, senderName: String) async {
        isActing = true
        defer { isActing = false }
        do {
            try await service.sendJoinRequest(group: group, senderName: senderName)
            hasPendingRequest = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
