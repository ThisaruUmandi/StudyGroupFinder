//
//  ResourceStorageService.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//


import Foundation
import FirebaseStorage

class ResourceStorageService {
    static let shared = ResourceStorageService()
    private let storage = Storage.storage()

    // MARK: - Upload

    func uploadFile(
        data: Data,
        resourceId: String,
        groupId: String,
        fileExtension: String
    ) async throws -> String {

        let ref = storage
            .reference()
            .child("groupResources/\(groupId)/\(resourceId)/file.\(fileExtension)")

        let metadata = StorageMetadata()
        metadata.contentType = contentType(for: fileExtension)

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()

        print("📤 File uploaded:", url.absoluteString)
        return url.absoluteString
    }

    // MARK: - Download Permanently (FIXED)

    func downloadFile(
        from urlString: String,
        filename: String,
        resourceId: String,
        title: String
    ) async throws -> URL {

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        // Sanitize filename
        let safeFilename = filename
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")

        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let localURL = documentsURL.appendingPathComponent(safeFilename)

        print("Target path:", localURL.path)

        // MARK: Already exists
        if FileManager.default.fileExists(atPath: localURL.path) {
            print("File already exists:", safeFilename)

            let existing = CoreDataService.shared.fetchDownloads()
            if !existing.contains(where: { $0.resourceId == resourceId }) {

                let attrs = try? FileManager.default.attributesOfItem(atPath: localURL.path)
                let fileSize = attrs?[.size] as? Int64 ?? 0

                CoreDataService.shared.saveDownload(
                    resourceId: resourceId,
                    title: title,
                    filename: safeFilename,
                    filePath: localURL.path,
                    fileSize: fileSize
                )
            }

            return localURL
        }

        // MARK: Download file
        let (data, response) = try await URLSession.shared.data(from: url)

        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        // Validate data
        guard !data.isEmpty else {
            throw URLError(.zeroByteResource)
        }

        // MARK: Write file safely
        do {
            try data.write(to: localURL, options: .atomic)
        } catch {
            print("File write failed:", error)
            throw error
        }

        // MARK: Verify file exists
        let exists = FileManager.default.fileExists(atPath: localURL.path)
        print("File exists after write:", exists)

        guard exists else {
            throw NSError(
                domain: "FileError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "File not saved to disk"]
            )
        }

        // MARK: Save to Core Data
        CoreDataService.shared.saveDownload(
            resourceId: resourceId,
            title: title,
            filename: safeFilename,
            filePath: localURL.path,
            fileSize: Int64(data.count)
        )

        print("Download complete:", safeFilename)
        return localURL
    }

    // MARK: - Preview Download (TEMP)

    func downloadForPreview(from urlString: String, filename: String) async throws -> URL {

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(filename)

        if FileManager.default.fileExists(atPath: tmpURL.path) {
            return tmpURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        try data.write(to: tmpURL, options: .atomic)

        print("Preview file saved:", tmpURL.path)
        return tmpURL
    }

    // MARK: - Delete

    func deleteFile(groupId: String, resourceId: String, fileExtension: String) async throws {
        let ref = storage
            .reference()
            .child("groupResources/\(groupId)/\(resourceId)/file.\(fileExtension)")

        try await ref.delete()
        print("Storage file deleted")
    }

    // MARK: - Content Type

    private func contentType(for ext: String) -> String {
        switch ext.lowercased() {
        case "pdf": return "application/pdf"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        default: return "application/octet-stream"
        }
    }
}
