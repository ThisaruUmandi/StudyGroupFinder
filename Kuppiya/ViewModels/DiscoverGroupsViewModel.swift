//
//  DiscoverGroupsViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-25.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class DiscoverGroupsViewModel: ObservableObject {

    @Published var recommendedGroups: [StudyGroup] = []
    @Published var trendingGroups: [StudyGroup] = []
    @Published var searchResults: [StudyGroup] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var isSearching = false
    @Published var showError = false
    @Published var errorMessage: String?

    private let service = FirestoreService.shared
    private var searchTask: Task<Void, Never>?

    func load(user: AppUser) async {
        isLoading = true
        do {
            async let r = service.fetchScoredRecommendedGroups(user: user)
            async let t = service.fetchTrendingGroupsCombined(currentUserUid: user.uid)
            let (recommended, trending) = try await (r, t)
            recommendedGroups = recommended
            trendingGroups = trending
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    func search() {
        searchTask?.cancel()
        let query = searchText.trimmingCharacters(in: .whitespaces)

        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            do {
                searchResults = try await service.searchAllGroups(query: query)
            } catch {}
            isSearching = false
        }
    }

    var isSearchActive: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
