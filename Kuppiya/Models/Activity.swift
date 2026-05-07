//
//  Activity.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-22.
//

import Foundation
import FirebaseFirestore

struct Activity: Codable, Identifiable {
    @DocumentID var id: String?
    var actorId: String
    var action: String
    var target: String?
    var type: String
    var createdAt: Date

    var displayText: String {
        if let target, !target.isEmpty {
            return "\(action) '\(target)'"
        }
        return action
    }

    var timeAgo: String {
        let diff = Date().timeIntervalSince(createdAt)
        if diff < 60 { return "just now" }
        if diff < 3600 { return "\(Int(diff/60))m ago" }
        if diff < 86400 { return "\(Int(diff/3600))h ago" }
        return "\(Int(diff/86400))d ago"
    }
}
