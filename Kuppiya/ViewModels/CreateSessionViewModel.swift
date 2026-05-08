//
//  CreateSessionViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-29.
//

import Foundation
import FirebaseAuth
import CoreLocation
import Combine

@MainActor
class CreateSessionViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var sessionType = 0  // 0 = Online, 1 = Physical
    @Published var joinLink = ""
    @Published var locationName = ""
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var date = Date()
    @Published var startTime = Date()
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var didSave = false

    private let service = FirestoreService.shared

    var isOnline: Bool { sessionType == 0 }

    var isValid: Bool {
        if title.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        if isOnline {
            return !joinLink.trimmingCharacters(in: .whitespaces).isEmpty
        } else {
            return selectedCoordinate != nil
        }
    }

    func save(for group: StudyGroup) async {
        guard isValid else {
            errorMessage = "Please fill in all required fields."
            showError = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        let uid = Auth.auth().currentUser?.uid ?? ""
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        let timeStr = f.string(from: startTime)

        let session = StudySession(
            sessionId: UUID().uuidString,
            groupId: group.groupId,
            groupName: group.name,
            title: title,
            description: description,
            date: date,
            startTime: timeStr,
            type: isOnline ? "online" : "physical",
            joinLink: isOnline ? joinLink : "",
            location: isOnline ? "" : locationName,
            latitude: selectedCoordinate?.latitude ?? 0,
            longitude: selectedCoordinate?.longitude ?? 0,
            status: "upcoming",
            createdBy: uid,
            createdByName: "",
            attendees: []
        )

        do {
            try await service.createSession(session, in: group.groupId)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
