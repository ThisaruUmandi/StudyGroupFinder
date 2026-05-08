//
//  Question.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import Foundation
import FirebaseFirestore

struct Question: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var questionId: String
    var groupId: String
    var authorId: String
    var authorName: String
    var title: String
    var description: String
    var tag: String
    var upvotes: [String]
    var answerCount: Int
    var bestAnswerId: String?
    var createdAt: Date
    var status: String // "unanswered" | "answered"

    var isAnswered: Bool { status == "answered" }
    var upvoteCount: Int  { upvotes.count }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: createdAt)
    }

    var timeAgo: String {
        let diff = Date().timeIntervalSince(createdAt)
        if diff < 60 { return "Just now" }
        if diff < 3600 { return "\(Int(diff/60))m ago" }
        if diff < 86400 { return "\(Int(diff/3600))h ago" }
        return "\(Int(diff/86400))d ago"
    }
}
