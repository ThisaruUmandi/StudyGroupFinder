//
//  GroupsViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class GroupsViewModel: ObservableObject {
    @Published var myGroups: [StudyGroup]        = []
    @Published var sessionCounts: [String: Int]  = [:]
    @Published var isLoading: Bool               = false
    @Published var errorMessage: String?         = nil
    @Published var showError: Bool               = false
    @Published var searchText: String            = ""

    private let service = FirestoreService.shared

    var filteredGroups: [StudyGroup] {
        if searchText.isEmpty { return myGroups }
        let q = searchText.lowercased()
        return myGroups.filter {
            $0.name.lowercased().contains(q) ||
            $0.subject.lowercased().contains(q) ||
            $0.major.lowercased().contains(q)
        }
    }

//    func loadMyGroups() async {
//        isLoading = true
//        do {
//            myGroups = try await service.fetchMyGroups()
//            print("My groups: \(myGroups.count)")
//
//            // Fetch session counts for each group
//            await fetchSessionCounts()
//        } catch {
//            errorMessage = error.localizedDescription
//            showError = true
//            print("Groups error: \(error)")
//        }
//        isLoading = false
//    }

    private func fetchSessionCounts() async {
        let calendar = Calendar.current
        let now = Date()
        let weekEnd = calendar.date(
            byAdding: .day, value: 7, to: now) ?? now

        for group in myGroups {
            do {
                let sessions = try await service
                    .fetchSessions(for: group.groupId)

                let count = sessions.filter {
                    $0.date >= now && $0.date <= weekEnd
                }.count

                sessionCounts[group.groupId] = count
            } catch {
                sessionCounts[group.groupId] = 0
            }
        }
    }
    
    func loadMyGroups() async {
        isLoading = true
        do {
            // Temporary test if service is reachable at all
            print("Calling fetchMyGroups...")
            myGroups = try await service.fetchMyGroups()
            print("My groups: \(myGroups.count)")
            await fetchSessionCounts()
        } catch {
            print("fetchMyGroups threw: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    // To refresh after group settings update
    func refreshGroups() async {
        await loadMyGroups()
    }
    
}
