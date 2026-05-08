//
//  Message.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

//
//  Message.swift
//  Kuppiya
//

import Foundation
import FirebaseFirestore

struct ReplyInfo: Codable, Equatable {
    var messageId:  String
    var senderName: String
    var text:       String
}

struct Message: Identifiable, Codable {
    @DocumentID var id: String?

    var messageId:  String
    var senderId:   String
    var senderName: String
    var text:       String
    var createdAt:  Date
    var replyTo:    ReplyInfo?
    var reactions:  [String: [String]] = [:]

    var isMe: Bool = false

    func reactionCount(_ emoji: String) -> Int {
        reactions[emoji]?.count ?? 0
    }

    func hasReacted(_ emoji: String, uid: String) -> Bool {
        reactions[emoji]?.contains(uid) ?? false
    }

    var activeReactions: [(emoji: String, count: Int)] {
        let order = ["👍","❤️","😂","😮","😢","🔥"]
        return order.compactMap { emoji in
            let count = reactionCount(emoji)
            return count > 0 ? (emoji, count) : nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, messageId, senderId, senderName,
             text, createdAt, replyTo, reactions
    }
}

extension Message {
    var dateSeparatorLabel: String {
        let cal = Calendar.current
        if cal.isDateInToday(createdAt)     { return "Today" }
        if cal.isDateInYesterday(createdAt) { return "Yesterday" }
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        return f.string(from: createdAt)
    }

    var timeLabel: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: createdAt)
    }
}
