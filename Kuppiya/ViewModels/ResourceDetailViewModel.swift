//
//  ResourceDetailViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//

import Foundation
import FirebaseAuth
import PDFKit
import NaturalLanguage
import Combine

@MainActor
class ResourceDetailViewModel: ObservableObject {
    @Published var isLiked       = false
    @Published var isSaved       = false
    @Published var isDownloading = false
    @Published var isDownloaded  = false
    @Published var localURL: URL?
    @Published var summary       = ""
    @Published var isSummarizing = false
    @Published var showError     = false
    @Published var errorMessage  = ""

    private let firestoreService = FirestoreService.shared
    private let storageService   = ResourceStorageService.shared

    var currentUid: String { Auth.auth().currentUser?.uid ?? "" }

    func setup(resource: Resource) {
        isLiked = resource.likedBy.contains(currentUid)
        isSaved = resource.savedBy.contains(currentUid)

        // Check if already downloaded — load instantly from Core Data
        let downloads = CoreDataService.shared.fetchDownloads()
        if let existing = downloads.first(where: { $0.resourceId == resource.resourceId }) {
            let url = URL(fileURLWithPath: existing.filePath)
            if FileManager.default.fileExists(atPath: existing.filePath) {
                localURL     = url
                isDownloaded = true
                print("Already downloaded: \(existing.filename)")
            }
        }

        // Check if already summarized — load instantly from Core Data
        let summaries = CoreDataService.shared.fetchSummaries()
        if let existing = summaries.first(where: { $0.resourceId == resource.resourceId }) {
            summary = existing.summaryText
            print("Summary loaded from Core Data: \(resource.title)")
        }
    }

    func toggleLike(resource: Resource) async {
        do {
            try await firestoreService.toggleLike(
                resourceId: resource.resourceId,
                groupId:    resource.groupId,
                uid:        currentUid,
                isLiked:    isLiked
            )
            isLiked.toggle()
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
    }

    func toggleSave(resource: Resource) async {
        do {
            try await firestoreService.toggleSave(
                resourceId: resource.resourceId,
                groupId:    resource.groupId,
                uid:        currentUid,
                isSaved:    isSaved
            )
            isSaved.toggle()
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
    }

    // Load for preview — uses permanent file if downloaded,
    // otherwise downloads temp copy for preview only
    func loadForPreview(resource: Resource) async {
        guard !resource.isLink else { return }

        // Already have permanent local file
        if let url = localURL,
           FileManager.default.fileExists(atPath: url.path) {
            print("Using existing local file for preview")
            return
        }

        // Not downloaded — get temp copy for preview
        isDownloading = true
        defer { isDownloading = false }
        do {
            let url  = try await storageService.downloadForPreview(
                from:     resource.url,
                filename: "\(resource.title).\(resource.fileExtension)"
            )
            localURL = url
            print("Preview loaded from temp: \(resource.title)")
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
    }

    // Download permanently to Documents/ + Core Data
    func download(resource: Resource) async {
        guard !isDownloaded else {
            print("Already downloaded: \(resource.title)")
            return
        }
        isDownloading = true
        defer { isDownloading = false }
        do {
            let url = try await storageService.downloadFile(
                from:       resource.url,
                filename:   "\(resource.title).\(resource.fileExtension)",
                resourceId: resource.resourceId,
                title:      resource.title
            )
            localURL     = url
            isDownloaded = true
            print("Permanently downloaded: \(resource.title)")
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
    }

    // Summarize — skip if already done, save to Core Data
    func summarize(resource: Resource) async {
        // Already summarized — no need to re-process
        if !summary.isEmpty {
            print("Summary already exists: \(resource.title)")
            return
        }

        guard resource.isPDF, let url = localURL,
              FileManager.default.fileExists(atPath: url.path) else {
            errorMessage = "Please download the file first to summarize."
            showError    = true
            return
        }

        isSummarizing = true
        defer { isSummarizing = false }

        guard let doc = PDFDocument(url: url) else { return }
        var fullText = ""
        for i in 0..<doc.pageCount {
            fullText += doc.page(at: i)?.string ?? ""
        }

        guard !fullText.isEmpty else {
            errorMessage = "Could not extract text from this PDF."
            showError    = true
            return
        }

        let summarized = extractKeySentences(from: fullText, count: 5)
        summary = summarized

        // Save to Core Data — persists offline
        CoreDataService.shared.saveSummary(
            resourceId:  resource.resourceId,
            title:       resource.title,
            summaryText: summarized
        )
        print("Summary saved to Core Data: \(resource.title)")
    }

    func clearSummary() {
        summary = ""
    }

    private func extractKeySentences(from text: String, count: Int) -> String {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        var sentences: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let s = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !s.isEmpty { sentences.append(s) }
            return true
        }

        guard !sentences.isEmpty else { return text }

        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var freq: [String: Int] = [:]
        words.forEach { freq[$0, default: 0] += 1 }

        return sentences
            .map { s -> (String, Int) in
                let score = s.lowercased()
                    .components(separatedBy: .whitespacesAndNewlines)
                    .reduce(0) { $0 + (freq[$1] ?? 0) }
                return (s, score)
            }
            .sorted { $0.1 > $1.1 }
            .prefix(count)
            .map { $0.0 }
            .joined(separator: "\n\n")
    }

    func delete(resource: Resource, completion: @escaping () -> Void) async {
        do {
            try await firestoreService.deleteResource(
                resourceId: resource.resourceId,
                groupId:    resource.groupId
            )
            if !resource.isLink {
                try? await storageService.deleteFile(
                    groupId:       resource.groupId,
                    resourceId:    resource.resourceId,
                    fileExtension: resource.fileExtension
                )
            }
            completion()
        } catch {
            errorMessage = error.localizedDescription
            showError    = true
        }
    }
}
