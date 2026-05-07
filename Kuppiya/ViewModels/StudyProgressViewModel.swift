//
//  StudyProgressViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import Foundation
import Combine

@MainActor
class StudyProgressViewModel: ObservableObject {
    @Published var stat: GroupStat?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showGoalSheet = false

    private let service = StudyProgressService.shared

    func load(uid: String, groupId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await service.checkAndResetWeekly(uid: uid, groupId: groupId)
            stat = try await service.fetchGroupStat(uid: uid, groupId: groupId)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func updateGoal(uid: String, groupId: String, hours: Double) async {
        do {
            try await service.setWeeklyGoal(
                uid: uid, groupId: groupId, hours: hours
            )
            stat?.weeklyGoalHours = hours
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
