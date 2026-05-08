//
//  JoinRequest.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import Foundation
import FirebaseFirestore

struct JoinRequest: Codable, Identifiable {
    @DocumentID var id: String?
    var groupId: String
    var groupName: String
    var senderId: String
    var senderName: String
    var status: String
    var createdAt: Date

    var isPending: Bool { status == "pending" }
}
