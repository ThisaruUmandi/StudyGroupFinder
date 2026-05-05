//
//  QnAViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class QnAViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var selectedFilter  = 0 // 0=All, 1=Unanswered, 2=My Posts
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let service = FirestoreService.shared
    var currentUid: String { Auth.auth().currentUser?.uid ?? "" }

    let filters = ["All", "Unanswered", "My Posts"]

    var filtered: [Question] {
        var result = questions

        switch selectedFilter {
        case 1: result = result.filter { !$0.isAnswered }
        case 2: result = result.filter { $0.authorId == currentUid }
        default: break
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.tag.lowercased().contains(searchText.lowercased())
            }
        }

        return result
    }

    func load(for groupId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            questions = try await service.fetchQuestions(groupId: groupId)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func toggleUpvote(question: Question, groupId: String) async {
        guard let id = question.id else { return }
        let isUpvoted = question.upvotes.contains(currentUid)
        do {
            try await service.toggleQuestionUpvote(
                groupId: groupId,
                questionId: id,
                uid: currentUid,
                isUpvoted: isUpvoted
            )
            await load(for: groupId)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
