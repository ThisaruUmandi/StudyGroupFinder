//
//  UploadResourceViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//


import Foundation
import FirebaseAuth
import UIKit
import Combine

@MainActor
class UploadResourceViewModel: ObservableObject {
    @Published var title        = ""
    @Published var linkURL      = ""
    @Published var selectedType = 0  // 0=Document, 1=Media, 2=Link
    @Published var selectedFile: Data?
    @Published var selectedFileName = ""
    @Published var selectedFileExt  = ""
    @Published var isUploading  = false
    @Published var showError    = false
    @Published var errorMessage = ""
    @Published var didUpload    = false
    @Published var showFilePicker = false
    @Published var showImagePicker = false

    private let firestoreService = FirestoreService.shared
    private let storageService   = ResourceStorageService.shared

    var typeString: String {
        switch selectedType {
        case 0: return "document"
        case 1: return "media"
        default: return "link"
        }
    }

    var isValid: Bool {
        if title.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        switch selectedType {
        case 0, 1: return selectedFile != nil
        case 2:    return !linkURL.trimmingCharacters(in: .whitespaces).isEmpty
        default:   return false
        }
    }

    func upload(for group: StudyGroup) async {
        guard isValid else { return }
        isUploading = true
        defer { isUploading = false }

        let uid          = Auth.auth().currentUser?.uid ?? ""
        let resourceId   = UUID().uuidString
        var downloadURL  = ""

        do {
            // Upload file to Storage if not a link
            if selectedType != 2, let data = selectedFile {
                downloadURL = try await storageService.uploadFile(
                    data: data,
                    resourceId: resourceId,
                    groupId: group.groupId,
                    fileExtension: selectedFileExt
                )
            } else {
                downloadURL = linkURL
            }

            // Fetch uploader name
            let user = try? await firestoreService.fetchUser(uid: uid)

            let resource = Resource(
                resourceId:   resourceId,
                groupId:      group.groupId,
                title:        title,
                type:         typeString,
                url:          downloadURL,
                fileExtension: selectedFileExt,
                uploadedBy:   uid,
                uploaderName: user?.username ?? "Unknown",
                createdAt:    Date(),
                likedBy:      [],
                savedBy:      []
            )

            try await firestoreService.createResource(resource, in: group.groupId)

            // Log activity
            try await firestoreService.logActivity(
                groupId: group.groupId,
                actorId: uid,
                action: "uploaded a resource",
                target: title,
                type: "resource"
            )

            didUpload = true
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
    }
}
