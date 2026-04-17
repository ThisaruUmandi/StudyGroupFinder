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

    @Published var upcomingSession: StudySession?
    @Published var joinRequests: [JoinRequest] = []
    @Published var isLoading: Bool             = false
    @Published var errorMessage: String?
    @Published var showError: Bool             = false
    @Published var searchText: String          = ""

    private let firestoreService = FirestoreService.shared

    var pendingCount: Int { joinRequests.count }

    // MARK: - Load home data
    func loadHomeData() async {
        isLoading = true
        do {
            async let session  = firestoreService
                .fetchUpcomingSession()
            async let requests = firestoreService
                .fetchPendingJoinRequests()

            upcomingSession = try await session
            joinRequests    = try await requests

            print("✅ Session loaded: \(upcomingSession?.title ?? "none")")
            print("✅ Requests loaded: \(joinRequests.count)")
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
            print("❌ HomeViewModel error: \(error)")
        }
        isLoading = false
    }

    // MARK: - Approve request
    func approveRequest(_ request: JoinRequest) async {
        do {
            try await firestoreService.approveJoinRequest(request)
            joinRequests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
    }

    // MARK: - Reject request
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
