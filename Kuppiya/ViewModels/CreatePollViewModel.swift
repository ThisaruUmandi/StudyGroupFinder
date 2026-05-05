//
//  CreatePollViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class CreatePollViewModel: ObservableObject {
    @Published var question      = ""
    @Published var options       = ["", "", "", ""]
    @Published var correctIndex  = 0
    @Published var duration      = 24
    @Published var isPosting     = false
    @Published var showError     = false
    @Published var errorMessage  = ""

    private let service  = FirestoreService.shared
    var currentUid: String { Auth.auth().currentUser?.uid ?? "" }

    let durations = [24, 48, 72]

    var isValid: Bool {
        !question.trimmingCharacters(in: .whitespaces).isEmpty &&
        options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count >= 2
    }

    func post(groupId: String, authorName: String, completion: @escaping () -> Void) async {
        guard isValid else { return }
        isPosting = true
        defer { isPosting = false }
        do {
            let validOptions = options.filter {
                !$0.trimmingCharacters(in: .whitespaces).isEmpty
            }
            try await service.createPoll(
                groupId:      groupId,
                authorId:     currentUid,
                authorName:   authorName,
                question:     question.trimmingCharacters(in: .whitespaces),
                options:      validOptions,
                correctIndex: correctIndex,
                duration:     duration
            )
            completion()
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
    }
}
