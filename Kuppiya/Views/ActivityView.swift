//
//  ActivityView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//

import SwiftUI
import PDFKit

struct ActivityView: View {
    @StateObject private var vm = ActivityViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                if vm.isOffline {
                    offlineBanner
                }

                filterBar.padding(.top, 16)
                searchBar.padding(.top, 12).padding(.horizontal, 20)
                contentArea.padding(.top, 16)
            }

//            Image("oboy_l")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 70)
//                .offset(y: -90)
        }
        .navigationBarHidden(true)
//        .onAppear { Task { await vm.loadAll() } }
        .onAppear {
            vm.isOffline = !NetworkMonitor.shared.isConnected
            Task { await vm.loadAll() }
        }
        .onChange(of: vm.selectedTab) { _, _ in Task { await vm.loadAll() } }
        
        .onChange(of: scenePhase) { _, phase in          // ← add here
            if phase == .active {
                vm.isOffline = !NetworkMonitor.shared.isConnected
                if !vm.isOffline {
                    Task { await vm.loadAll() }
                }
            }
        }
        
        // File preview sheet
        .sheet(isPresented: $vm.showFilePreview) {
            if let url = vm.fileToOpen {
                NavigationStack {
                    if url.pathExtension.lowercased() == "pdf" {
                        ActivityPDFView(url: url)
                            .navigationTitle(url.lastPathComponent)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button("Close") {
                                        vm.showFilePreview = false
                                    }
                                }
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button {
                                        vm.showFilePreview = false
                                        vm.shareFile(url: url)
                                    } label: {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                }
                            }
                    } else if url.pathExtension.lowercased() == "png" ||
                              url.pathExtension.lowercased() == "jpg" ||
                              url.pathExtension.lowercased() == "jpeg" {
                        ScrollView {
                            if let uiImage = UIImage(contentsOfFile: url.path) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                            }
                        }
                        .navigationTitle(url.lastPathComponent)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Close") { vm.showFilePreview = false }
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    vm.showFilePreview = false
                                    vm.shareFile(url: url)
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                    }
                }
            }
        }
        // Share sheet
        .sheet(isPresented: $vm.showShareSheet) {
            if let url = vm.shareURL {
                ActivityShareSheet(items: [url])
            }
        }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }

    // MARK: - Offline Banner
    private var offlineBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 13))
            Text("You're offline. Downloads & Summaries available.")
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(Color(uiColor: .systemBackground))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#D85A30"))
    }

    // MARK: - Nav Bar
    private var navBar: some View {
        HStack {
            Spacer()
            Text("Activity")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.tabs.indices, id: \.self) { index in
                    Button {
                        vm.selectedTab = index
                    } label: {
                        Text(vm.tabs[index])
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(
                                vm.selectedTab == index
                                ? .white
                                : .primary
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                vm.selectedTab == index
                                    ? Color(hex: "#0300BF")
                                    : Color(.systemBackground)
                            )
                            .clipShape(Capsule()).overlay {
                                RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
                            }
                            .shadow(color: .primary.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search...", text: $vm.searchText)
                .font(.system(size: 14))
            Image(systemName: "mic")
                .foregroundColor(Color(hex: "#0300BF"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color(.systemBackground))
        .cornerRadius(25)
        .shadow(color: .primary.opacity(0.05), radius: 6, x: 0, y: 2)
        .overlay {
            RoundedRectangle(cornerRadius: 50)
            .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
        }
    }

    // MARK: - Content
    @ViewBuilder
    private var contentArea: some View {
        if vm.isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else {
            switch vm.selectedTab {
            case 0: downloadsTab
            case 1: favouritesTab
            case 2: bookmarkedTab
            case 3: summarizedTab
            default: EmptyView()
            }
        }
    }

    // MARK: - Downloads Tab
    private var downloadsTab: some View {
        Group {
            if vm.filteredDownloads.isEmpty {
                emptyState(
                    icon: "arrow.down.circle",
                    message: "No downloads yet",
                    subtitle: "Downloads are available offline"
                )
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(vm.filteredDownloads, id: \.self) { url in
                            downloadRow(url: url)
                                .padding(.horizontal, 20)
                        }
                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private func downloadRow(url: URL) -> some View {
        HStack(spacing: 14) {
            KIconBox(
                icon:         vm.fileIcon(url: url),
                iconColor:    Color(hex: vm.fileIconColor(url: url)),
                bgColor:      Color(hex: vm.fileIconColor(url: url)).opacity(0.12),
                size:         46,
                cornerRadius: 12,
                iconSize:     20
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(url.lastPathComponent)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(vm.fileSize(url: url))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                vm.shareFile(url: url)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#0300BF"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.04), radius: 6, x: 0, y: 2)
        .onTapGesture {
            vm.openFile(url: url)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                vm.deleteDownload(url: url)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Favourites Tab
    private var favouritesTab: some View {
        Group {
            if vm.isOffline {
                offlineEmptyState(
                    icon: "heart",
                    message: "Favourites unavailable offline"
                )
            } else if vm.filteredFavourites.isEmpty {
                emptyState(
                    icon: "heart",
                    message: "No favourites yet",
                    subtitle: "Like resources to see them here"
                )
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(vm.filteredFavourites) { resource in
                            KResourceCard(resource: resource) {}
                                .padding(.horizontal, 20)
                        }
                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }

    // MARK: - Bookmarked Tab
    private var bookmarkedTab: some View {
        Group {
            if vm.isOffline {
                offlineEmptyState(
                    icon: "bookmark",
                    message: "Bookmarks unavailable offline"
                )
            } else if vm.filteredBookmarked.isEmpty {
                emptyState(
                    icon: "bookmark",
                    message: "No bookmarks yet",
                    subtitle: "Save resources to see them here"
                )
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(vm.filteredBookmarked) { resource in
                            KResourceCard(resource: resource) {}
                                .padding(.horizontal, 20)
                        }
                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }

    // MARK: - Summarized Tab
    private var summarizedTab: some View {
        Group {
            if vm.filteredSummaries.isEmpty {
                emptyState(
                    icon: "doc.text.magnifyingglass",
                    message: "No summaries yet",
                    subtitle: "Summaries are available offline"
                )
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(vm.filteredSummaries, id: \.resourceId) { summary in
                            summaryCard(summary: summary)
                                .padding(.horizontal, 20)
                        }
                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private func summaryCard(
        summary: (resourceId: String, title: String, summaryText: String, generatedAt: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                KIconBox(
                    icon:         "doc.fill",
                    iconColor:    Color(hex: "#E84040"),
                    bgColor:      Color(hex: "#E84040").opacity(0.12),
                    size:         42,
                    cornerRadius: 10,
                    iconSize:     18
                )
                VStack(alignment: .leading, spacing: 3) {
                    Text(summary.title)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    Text(formattedDate(summary.generatedAt))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    vm.deleteSummary(resourceId: summary.resourceId)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 18))
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb")
                        .foregroundColor(Color(hex: "#6B3FD4"))
                        .font(.system(size: 13))
                    Text("Key Takeaways")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "#6B3FD4"))
                }

                let sentences = summary.summaryText
                    .components(separatedBy: "\n\n")
                    .filter { !$0.isEmpty }

                ForEach(sentences, id: \.self) { sentence in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color(hex: "#6B3FD4"))
                            .frame(width: 6, height: 6)
                            .padding(.top, 5)
                        Text(sentence)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                }
            }
            .padding(12)
            .background(Color(hex: "#EDE7FF").opacity(0.4))
            .cornerRadius(12)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Empty States
    private func emptyState(
        icon: String,
        message: String,
        subtitle: String = ""
    ) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(.gray.opacity(0.35))
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
            Spacer()
        }
    }

    private func offlineEmptyState(icon: String, message: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 36))
                    .foregroundColor(.gray.opacity(0.35))
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text("Connect to internet to view")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            Spacer()
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }
}

// MARK: - PDF Viewer
private struct ActivityPDFView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let v         = PDFView()
        v.autoScales  = true
        v.displayMode = .singlePageContinuous
        v.document    = PDFDocument(url: url)
        return v
    }
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// MARK: - Share Sheet
private struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ActivityView()
            .environmentObject(AuthViewModel())
    }
}
