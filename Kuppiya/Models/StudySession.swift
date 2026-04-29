//
//  StudySession.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct StudySession: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var sessionId: String
    var groupId: String
    var groupName: String
    var title: String
    var description: String
    var date: Date
    var startTime: String
    var type: String
    var joinLink: String
    var location: String
    var latitude: Double
    var longitude: Double
    var status: String
    var createdBy: String
    var createdByName: String
    var attendees: [String]

    // Custom Hashable — avoids CLLocationCoordinate2D hashing issue
    static func == (lhs: StudySession, rhs: StudySession) -> Bool {
        lhs.sessionId == rhs.sessionId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(sessionId)
    }

    var isOnline: Bool    { type == "online" }
    var isPhysical: Bool  { type == "physical" }
    var isUpcoming: Bool  { status == "upcoming" }
    var isCompleted: Bool { status == "completed" }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var formattedDateTime: String {
        if isToday {
            return "Today at \(startTime)"
        }
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return "\(f.string(from: date)) • \(startTime)"
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }

    func isCreator(uid: String) -> Bool {
        createdBy == uid
    }
}
