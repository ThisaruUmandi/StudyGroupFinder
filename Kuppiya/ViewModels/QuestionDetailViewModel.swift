//
//  QuestionDetailViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import SwiftUI
import Foundation
import FirebaseAuth
import Combine

@MainActor
class QuestionDetailViewModel: ObservableObject {
    @Published var answers: [Answer] = []
    @Published var answerText = ""
    @Published var isLoading = false
    @Published var isPosting = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let service  = FirestoreService.shared
    var currentUid: String { Auth.auth().currentUser?.uid ?? "" }

    func load(groupId: String, questionId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            answers = try await service.fetchAnswers(
                groupId:    groupId,
                questionId: questionId
            )
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func postAnswer(groupId: String, question: Question,
                    authorName: String) async {
        guard !answerText.trimmingCharacters(in: .whitespaces).isEmpty,
              let questionId = question.id else { return }
        isPosting = true
        defer { isPosting = false }
        do {
            try await service.postAnswer(
                groupId: groupId,
                questionId: questionId,
                authorId: currentUid,
                authorName: authorName,
                body: answerText.trimmingCharacters(in: .whitespaces)
            )
            answerText = ""
            await load(groupId: groupId, questionId: questionId)
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
    }

    func markBestAnswer(groupId: String, question: Question,
                        answer: Answer) async {
        guard let questionId = question.id else { return }
        do {
            try await service.markBestAnswer(
                groupId: groupId,
                questionId: questionId,
                answerId: answer.answerId,
                authorId: answer.authorId,
                authorName: answer.authorName
            )
            await load(groupId: groupId, questionId: questionId)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func toggleAnswerUpvote(groupId: String, question: Question,
                            answer: Answer) async {
        guard let questionId = question.id else { return }
        let isUpvoted = answer.upvotes.contains(currentUid)
        do {
            try await service.toggleAnswerUpvote(
                groupId: groupId,
                questionId: questionId,
                answerId: answer.answerId,
                uid: currentUid,
                isUpvoted: isUpvoted
            )
            await load(groupId: groupId, questionId: questionId)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
