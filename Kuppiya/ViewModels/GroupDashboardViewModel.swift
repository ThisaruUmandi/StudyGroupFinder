//
//  GroupDashboardViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-22.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class GroupDashboardViewModel: ObservableObject {
    @Published var ongoingSession: StudySession?
    @Published var upcomingSessions: [StudySession] = []
    @Published var activities: [Activity] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?

    private let service = FirestoreService.shared

    func loadData(for groupId: String) async {
        isLoading = true
        do {
            async let sessions = service.fetchSessions(for: groupId)
            async let activitiesFetch = service.fetchActivities(for: groupId)

            let allSessions = try await sessions
            let now = Date()

            // ongoing — started within last 2 hours
            ongoingSession = allSessions.first {
                let end = $0.date.addingTimeInterval(2 * 60 * 60)
                return now >= $0.date && now <= end
            }

            // upcoming — future sessions only
            upcomingSessions = allSessions
                .filter { $0.date > now }
                .sorted { $0.date < $1.date }

            self.activities = try await activitiesFetch
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Dashboard error: \(error)")
        }
        isLoading = false
    }
}
