//
//  Resource.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-02.
//

import Foundation
import FirebaseFirestore

struct Resource: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var resourceId: String
    var groupId: String
    var title: String
    var type: String // "document" | "media" | "link"
    var url: String
    var fileExtension: String // "pdf" | "png" | "jpg" | "mp4" | ""
    var uploadedBy: String
    var uploaderName: String
    var createdAt: Date
    var likedBy: [String]
    var savedBy: [String]

    var isDocument: Bool { type == "document" }
    var isMedia: Bool { type == "media" }
    var isLink: Bool { type == "link" }
    var isPDF: Bool { fileExtension.lowercased() == "pdf" }

    var iconName: String {
        switch fileExtension.lowercased() {
        case "pdf": return "doc.fill"
        case "png", "jpg", "jpeg": return "photo.fill"
        case "mp4", "mov": return "video.fill"
        default: return type == "link" ? "link" : "doc.fill"
        }
    }

    var iconColor: String {
        switch fileExtension.lowercased() {
        case "pdf": return "#E84040"
        case "png", "jpg", "jpeg": return "#1D9E75"
        case "mp4", "mov": return "#6B3FD4"
        default: return type == "link" ? "#1A6BDB" : "#BA7517"
        }
    }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: createdAt)
    }
}
