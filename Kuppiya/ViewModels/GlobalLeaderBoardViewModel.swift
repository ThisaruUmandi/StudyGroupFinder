//
//  GlobalLeaderBoardViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import Foundation
import Combine

@MainActor
class GlobalLeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntry] = []
    @Published var selectedTab  = 0   // 0 = All time, 1 = This week
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let service = StudyProgressService.shared

    var top3: [LeaderboardEntry] { Array(entries.prefix(3)) }
    var rest:  [LeaderboardEntry] {
        guard entries.count > 3 else { return [] }
        return Array(entries.dropFirst(3))
    }

    func load() async {
        print("GlobalLeaderboard load() called")
        isLoading = true
        defer { isLoading = false }
        do {
            entries = try await service.fetchGlobalLeaderboard(
                weekly: selectedTab == 1
            )
            print("GlobalLeaderboard entries: \(entries.count)")
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
            print("GlobalLeaderboard error: \(error)")
        }
    }
}
