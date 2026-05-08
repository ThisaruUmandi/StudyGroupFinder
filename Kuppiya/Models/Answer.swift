//
//  Answer.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import Foundation
import FirebaseFirestore

struct Answer: Identifiable, Codable {
    @DocumentID var id: String?
    var answerId: String
    var questionId: String
    var authorId: String
    var authorName: String
    var body: String
    var upvotes: [String]
    var isBestAnswer: Bool
    var createdAt: Date

    var upvoteCount:   Int  { upvotes.count }

    var timeAgo: String {
        let diff = Date().timeIntervalSince(createdAt)
        if diff < 60 { return "Just now" }
        if diff < 3600 { return "\(Int(diff/60))m ago" }
        if diff < 86400 { return "\(Int(diff/3600))h ago" }
        return "\(Int(diff/86400))d ago"
    }
}
