//
//  AskQuestionViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import SwiftUI
import Foundation
import FirebaseAuth
import Combine

@MainActor
class AskQuestionViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var selectedTag = "General"
    @Published var isPosting = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let service = FirestoreService.shared
    var currentUid:  String { Auth.auth().currentUser?.uid ?? "" }

    let tags = [
        "General", "Mathematics", "Physics", "Chemistry",
        "Biology", "Computer Science", "English", "History",
        "Economics", "Programming", "iOS", "Other"
    ]

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func post(groupId: String, authorName: String,
              completion: @escaping () -> Void) async {
        guard isValid else { return }
        isPosting = true
        defer { isPosting = false }
        do {
            try await service.postQuestion(
                groupId: groupId,
                authorId: currentUid,
                authorName: authorName,
                title: title.trimmingCharacters(in: .whitespaces),
                description: description.trimmingCharacters(in: .whitespaces),
                tag: selectedTag
            )
            completion()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
