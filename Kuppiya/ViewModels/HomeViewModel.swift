//
//  HomeViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class HomeViewModel: ObservableObject {

    @Published var ongoingSession: StudySession?
    @Published var upcomingSession: StudySession?
    @Published var allUpcomingSessions: [StudySession] = []
    @Published var joinRequests: [JoinRequest] = []
    @Published var isLoading                   = false
    @Published var errorMessage: String?
    @Published var showError                   = false
    @Published var searchText                  = ""

    private let firestoreService = FirestoreService.shared

    var pendingCount: Int { joinRequests.count }

    func loadHomeData() async {
        isLoading = true
        do {
            async let requests = firestoreService.fetchPendingJoinRequests()

            // fetch all sessions across groups
            let allSessions = try await firestoreService.fetchAllUpcomingSessions()
            let now         = Date()

            // ongoing — started within last 2 hours
            ongoingSession = allSessions.first {
                let end = $0.date.addingTimeInterval(2 * 60 * 60)
                return now >= $0.date && now <= end
            }

            // upcoming — next future session
            upcomingSession = allSessions
                .filter { $0.date > now }
                .sorted { $0.date < $1.date }
                .first
            
            // all upcoming sessions sorted by date
            allUpcomingSessions = allSessions
                .filter { $0.date > now }
                .sorted { $0.date < $1.date }

            joinRequests = try await requests

            print("Ongoing: \(ongoingSession?.title ?? "none")")
            print("Upcoming: \(upcomingSession?.title ?? "none")")
            print("Requests: \(joinRequests.count)")
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
        
        isLoading = false
    }

    func approveRequest(_ request: JoinRequest) async {
        do {
            try await firestoreService.approveJoinRequest(request)
            joinRequests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
    }

    func rejectRequest(_ request: JoinRequest) async {
        do {
            try await firestoreService.rejectJoinRequest(request)
            joinRequests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
    }
}
