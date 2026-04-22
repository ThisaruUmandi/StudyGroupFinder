//
//  User.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-16.
//

import Foundation
import FirebaseFirestore

struct AppUser: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var username: String
    var email: String
    var profileImage: String
    var university: String
    var major: String
    var joinedGroups: [String]
    var createdAt: Date
    var fcmToken: String

    enum CodingKeys: String, CodingKey {
        case id, uid, username, email,
             profileImage, university, major,
             joinedGroups, createdAt, fcmToken
    }
}
