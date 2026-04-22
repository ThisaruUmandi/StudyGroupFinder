//
//  CreateGroupViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-21.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class CreateGroupViewModel: ObservableObject {

    // MARK: - Form fields
    @Published var groupName: String        = ""
    @Published var major: String            = ""
    @Published var subject: String          = ""
    @Published var university: String       = ""
    @Published var description: String      = ""
    @Published var isPublic: Bool           = true
    @Published var selectedMembers: [AppUser] = []

    // MARK: - State
    @Published var isLoading: Bool          = false
    @Published var showError: Bool          = false
    @Published var errorMessage: String?
    @Published var createdGroup: StudyGroup?
    @Published var showAddMembers: Bool     = false
    @Published var inviteLink: String       = ""
    @Published var showShareSheet: Bool     = false

    private let service = FirestoreService.shared

    var privacy: String { isPublic ? "public" : "private" }

    var isFormValid: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !subject.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Prefill major from authVM
    func prefill(major: String?, university: String?) {
        self.major = major ?? ""
        self.university = university ?? ""
    }

    // MARK: - Create group
    func createGroup(university: String) async {
        guard isFormValid else {
            errorMessage = "Please fill in group name and subject."
            showError = true
            return
        }

        isLoading = true
        do {
            let memberIds = selectedMembers.map { $0.uid }

            let group = try await service.createGroup(
                name: groupName.trimmingCharacters(in: .whitespaces),
                subject: subject.trimmingCharacters(in: .whitespaces),
                major: major.trimmingCharacters(in: .whitespaces),
                description: description.trimmingCharacters(in: .whitespaces),
                privacy: privacy,
                university: university,
                initialMembers: memberIds
            )
            createdGroup = group
            inviteLink = group.inviteLink ?? ""
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Create group error: \(error)")
        }
        isLoading = false
    }

    // MARK: - Invite link actions
    func copyLink() {
        UIPasteboard.general.string = inviteLink
    }

    func shareLink() {
        showShareSheet = true
    }

    // MARK: - Member management
    func removeMember(_ user: AppUser) {
        selectedMembers.removeAll { $0.uid == user.uid }
    }
}
