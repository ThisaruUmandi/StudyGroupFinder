//
//  ResourceViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class ResourceViewModel: ObservableObject {
    @Published var resources: [Resource] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedFilter = "All"

    private let service = FirestoreService.shared

    let filters = ["All", "Documents", "Media", "Links"]

    var filtered: [Resource] {
        switch selectedFilter {
        case "Documents": return resources.filter { $0.isDocument }
        case "Media": return resources.filter { $0.isMedia }
        case "Links": return resources.filter { $0.isLink }
        default: return resources
        }
    }

    func load(for groupId: String) async {
        isLoading = true
        do {
            resources = try await service.fetchResources(for: groupId)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    func delete(resource: Resource) async {
        guard let uid = Auth.auth().currentUser?.uid,
              uid == resource.uploadedBy else { return }
        do {
            try await service.deleteResource(
                resourceId: resource.resourceId,
                groupId: resource.groupId
            )
            if !resource.isLink {
                try? await ResourceStorageService.shared.deleteFile(
                    groupId: resource.groupId,
                    resourceId: resource.resourceId,
                    fileExtension: resource.fileExtension
                )
            }
            resources.removeAll { $0.resourceId == resource.resourceId }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
