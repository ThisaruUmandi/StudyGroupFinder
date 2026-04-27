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
    @Published var upcomingSessions: [StudySession] = []
    @Published var activities: [Activity]           = []
    @Published var isLoading: Bool                  = false
    @Published var showError: Bool                  = false
    @Published var errorMessage: String?

    private let service = FirestoreService.shared

    func loadData(for groupId: String) async {
        //isLoading = true
        do {
            async let sessions   = service.fetchSessions(for: groupId)
            async let activities = service.fetchActivities(for: groupId)

            let allSessions = try await sessions
            upcomingSessions = allSessions
                .filter { $0.status == "upcoming" && $0.date > Date() }
                .sorted { $0.date < $1.date }

            self.activities = try await activities
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Dashboard error: \(error)")
        }
        isLoading = false
    }
}
