//
//  Poll.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import Foundation
import FirebaseFirestore

struct PollOption: Codable, Identifiable, Hashable {
    var id: String
    var text: String
    var voteCount: Int
}

struct Poll: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var pollId: String
    var groupId: String
    var authorId:     String
    var authorName:   String
    var question:     String
    var options:      [PollOption]
    var correctIndex: Int
    var duration:     Int
    var endsAt:       Date
    var status:       String
    var createdAt:    Date
    var totalVotes:   Int

    var isActive: Bool  { status == "active" && Date() < endsAt }
    var isClosed: Bool  { status == "closed" || Date() >= endsAt }

    var timeLeft: String {
        let diff = endsAt.timeIntervalSince(Date())
        if diff <= 0 { return "Ended" }
        let hours = Int(diff / 3600)
        if hours < 24 { return "\(hours)h left" }
        return "\(hours / 24)d left"
    }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: createdAt)
    }

    var timeAgo: String {
        let diff = Date().timeIntervalSince(createdAt)
        if diff < 60    { return "Just now" }
        if diff < 3600  { return "\(Int(diff/60))m ago" }
        if diff < 86400 { return "\(Int(diff/3600))h ago" }
        return "\(Int(diff/86400))d ago"
    }

    func percentage(for index: Int) -> Double {
        guard totalVotes > 0 else { return 0 }
        return Double(options[index].voteCount) / Double(totalVotes) * 100
    }
}
