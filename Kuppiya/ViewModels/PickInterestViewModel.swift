//
//  PickInterestViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-25.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class PickInterestsViewModel: ObservableObject {
    @Published var selectedInterests: [String] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var didSaveInterests = false

    private let service = FirestoreService.shared

    let allInterests = [
        "Mathematics", "Physics", "Chemistry", "Biology",
        "Computer Science", "iOS Development", "Web Development",
        "Data Science", "Machine Learning", "Artificial Intelligence",
        "Business", "Economics", "Accounting", "Finance",
        "Engineering", "Electronics", "Mechanical", "Civil",
        "Literature", "History", "Psychology", "Philosophy",
        "Medicine", "Nursing", "Law", "Architecture", "Other"
    ]

    func toggle(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.removeAll { $0 == interest }
        } else {
            selectedInterests.append(interest)
        }
    }

    func isSelected(_ interest: String) -> Bool {
        selectedInterests.contains(interest)
    }

    func save() async {
        guard !selectedInterests.isEmpty else {
            errorMessage = "Please select at least one interest."
            showError = true
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        do {
            try await service.saveInterests(uid: uid, interests: selectedInterests)
            didSaveInterests = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    func skip() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        try? await service.saveInterests(uid: uid, interests: ["skipped"])
        isLoading = false
        didSaveInterests = true
    }
}
