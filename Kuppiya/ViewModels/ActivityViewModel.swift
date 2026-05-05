//
//  ActivityViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//

import SwiftUI
import Foundation
import FirebaseAuth
import Combine

@MainActor
class ActivityViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var downloads: [URL] = []
    @Published var favourites: [Resource] = []
    @Published var bookmarked: [Resource] = []
    @Published var summaries: [(resourceId: String, title: String, summaryText: String, generatedAt: Date)] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var fileToOpen: URL?
    @Published var showFilePreview = false
    @Published var shareURL: URL?
    @Published var showShareSheet = false
    @Published var isOffline = false

    private let service = FirestoreService.shared
    private var cancellables = Set<AnyCancellable>()

    let tabs = ["Downloads", "Favourites", "Bookmarked", "Summarized"]

//    init() {
//        // Observe network changes in real time
//        NetworkMonitor.shared.$isConnected
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] connected in
//                guard let self else { return }
//                self.isOffline = !connected
//                if connected {
//                    // Back online — reload Firestore tabs
//                    Task { await self.loadAll() }
//                } else {
//                    // Gone offline — clear Firestore tabs
//                    self.favourites = []
//                    self.bookmarked = []
//                }
//            }
//            .store(in: &cancellables)
//    }
    
    init() {
        // Set initial state
        isOffline = !NetworkMonitor.shared.isConnected

        // Observe changes
        NetworkMonitor.shared.$isConnected
            .removeDuplicates()
            .dropFirst() // Skip initial value — we set it manually above
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                guard let self else { return }
                self.isOffline = !connected
                if connected {
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        await self.loadAll()
                    }
                } else {
                    self.favourites = []
                    self.bookmarked = []
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Filtered

    var filteredDownloads: [URL] {
        guard !searchText.isEmpty else { return downloads }
        return downloads.filter {
            $0.lastPathComponent.lowercased().contains(searchText.lowercased())
        }
    }

    var filteredFavourites: [Resource] {
        guard !searchText.isEmpty else { return favourites }
        return favourites.filter {
            $0.title.lowercased().contains(searchText.lowercased())
        }
    }

    var filteredBookmarked: [Resource] {
        guard !searchText.isEmpty else { return bookmarked }
        return bookmarked.filter {
            $0.title.lowercased().contains(searchText.lowercased())
        }
    }

    var filteredSummaries: [(resourceId: String, title: String, summaryText: String, generatedAt: Date)] {
        guard !searchText.isEmpty else { return summaries }
        return summaries.filter {
            $0.title.lowercased().contains(searchText.lowercased())
        }
    }

    // MARK: - Load

    func loadAll() async {
        isLoading = true
        defer { isLoading = false }

        loadDownloads()
        loadSummaries()

        if NetworkMonitor.shared.isConnected {
            async let f: () = loadFavourites()
            async let b: () = loadBookmarked()
            await f; await b
        } else {
            favourites = []
            bookmarked = []
        }
    }

    private func loadDownloads() {
        let cdDownloads = CoreDataService.shared.fetchDownloads()
        print("Core Data downloads count: \(cdDownloads.count)")
        for cd in cdDownloads {
            print("Download: \(cd.filename) at \(cd.filePath)")
        }
        downloads = cdDownloads.compactMap { cd -> URL? in
            let path = cd.filePath
            guard FileManager.default.fileExists(atPath: path) else {
                print("File missing at: \(path)")
                CoreDataService.shared.deleteDownload(resourceId: cd.resourceId)
                return nil
            }
            return URL(fileURLWithPath: path)
        }
        print("Downloads loaded: \(downloads.count)")
    }

    private func loadFavourites() async {
        do {
            favourites = try await service.fetchFavouriteResources()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func loadBookmarked() async {
        do {
            bookmarked = try await service.fetchBookmarkedResources()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func loadSummaries() {
        summaries = CoreDataService.shared.fetchSummaries()
        print("Summaries loaded: \(summaries.count)")
    }

    // MARK: - Actions

    func openFile(url: URL) {
        fileToOpen = url
        showFilePreview = true
    }

    func shareFile(url: URL) {
        shareURL = url
        showShareSheet = true
    }

    func deleteDownload(url: URL) {
        try? FileManager.default.removeItem(at: url)
        let cdDownloads = CoreDataService.shared.fetchDownloads()
        if let cd = cdDownloads.first(where: { $0.filePath == url.path }) {
            CoreDataService.shared.deleteDownload(resourceId: cd.resourceId)
        }
        downloads.removeAll { $0 == url }
        print("Download deleted: \(url.lastPathComponent)")
    }

    func deleteSummary(resourceId: String) {
        CoreDataService.shared.deleteSummary(resourceId: resourceId)
        summaries.removeAll { $0.resourceId == resourceId }
    }

    // MARK: - Helpers

    func fileSize(url: URL) -> String {
        let bytes = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        let kb    = Double(bytes) / 1024
        if kb < 1024 { return String(format: "%.1f KB", kb) }
        return String(format: "%.1f MB", kb / 1024)
    }

    func fileIcon(url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "pdf": return "doc.fill"
        case "png", "jpg", "jpeg": return "photo.fill"
        case "mp4", "mov": return "video.fill"
        default: return "doc.fill"
        }
    }

    func fileIconColor(url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "pdf": return "#E84040"
        case "png", "jpg", "jpeg": return "#1D9E75"
        case "mp4", "mov":         return "#6B3FD4"
        default:                   return "#BA7517"
        }
    }
}
