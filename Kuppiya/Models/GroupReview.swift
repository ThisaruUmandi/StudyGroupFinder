//
//  GroupReview.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-23.
//

import Foundation
import FirebaseFirestore

struct GroupReview: Codable, Identifiable {
    @DocumentID var id: String?
    var authorId: String
    var rating: Int
    var review: String
    var createdAt: Date
}
