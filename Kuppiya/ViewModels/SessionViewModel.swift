//
//  SessionViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-29.
//

import Foundation
import Combine

@MainActor
class SessionViewModel: ObservableObject {
    @Published var sessions: [StudySession] = []
    @Published var selectedFilter: SessionFilter = .all
    @Published var showingPastSessions = false
    @Published var showError = false
    @Published var errorMessage: String?

    private let service = FirestoreService.shared

    enum SessionFilter: String, CaseIterable {
        case all = "All"
        case online = "Online"
        case physical = "Physical"
    }

    // Only ongoing sessions show in the KSessionCard
    var todaySession: StudySession? {
        sessions.first { $0.status == "ongoing" }
    }

    var upcomingSessions: [StudySession] {
        let list = sessions.filter { $0.status == "upcoming" }
        return applyFilter(list)
    }

    var pastSessions: [StudySession] {
        let list = sessions.filter { $0.status == "completed" }
        return applyFilter(list)
    }

    var displayedSessions: [StudySession] {
        showingPastSessions ? pastSessions : upcomingSessions
    }

    func load(for groupId: String) async {
        do {
            sessions = try await service.fetchSessions(for: groupId)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func applyFilter(_ list: [StudySession]) -> [StudySession] {
        switch selectedFilter {
        case .all: return list
        case .online: return list.filter { $0.isOnline }
        case .physical: return list.filter { $0.isPhysical }
        }
    }
}
