//
//  StudyGroup.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import Foundation
import FirebaseFirestore

struct StudyGroup: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var groupId: String
    var name: String
    var subject: String
    var major: String
    var description: String
    var createdBy: String
    var members: [String]
    var privacy: String
    var university: String
    var createdAt: Date
    var inviteLink: String?

    var isPrivate: Bool { privacy == "private" }
    var memberCount: Int { members.count }

    func isAdmin(uid: String) -> Bool { createdBy == uid }
    func isMember(uid: String) -> Bool { members.contains(uid) }
}
