//
//  PollViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class PollViewModel: ObservableObject {
    @Published var polls: [Poll] = []
    @Published var userVotes: [String: Int] = [:] // pollId → optionIndex
    @Published var selectedFilter  = 0
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    private let service  = FirestoreService.shared
    var currentUid: String { Auth.auth().currentUser?.uid ?? "" }

    let filters = ["Active", "Voted", "Closed"]

    var filtered: [Poll] {
        switch selectedFilter {
        case 0: return polls.filter { $0.isActive && userVotes[$0.pollId] == nil }
        case 1: return polls.filter { userVotes[$0.pollId] != nil }
        case 2: return polls.filter { $0.isClosed }
        default: return polls
        }
    }

    func load(for groupId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            polls = try await service.fetchPolls(groupId: groupId)
            // Fetch user votes for all polls
            await withTaskGroup(of: (String, Int?).self) { group in
                for poll in polls {
                    group.addTask {
                        let vote = try? await self.service.fetchUserVote(
                            groupId: groupId,
                            pollId:  poll.pollId,
                            uid:     self.currentUid
                        )
                        return (poll.pollId, vote)
                    }
                }
                for await (pollId, vote) in group {
                    if let vote { userVotes[pollId] = vote }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func vote(poll: Poll, optionIndex: Int, groupId: String) async {
        do {
            try await service.vote(
                groupId: groupId,
                pollId: poll.pollId,
                optionIndex: optionIndex,
                uid: currentUid
            )
            userVotes[poll.pollId] = optionIndex
            await load(for: groupId)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func closePoll(poll: Poll, groupId: String) async {
        do {
            try await service.closePoll(groupId: groupId, pollId: poll.pollId)
            await load(for: groupId)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
