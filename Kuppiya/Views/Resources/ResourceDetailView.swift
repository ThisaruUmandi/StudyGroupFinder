//
//  ResourceDetailView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//

import SwiftUI
import PDFKit

struct ResourceDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ResourceDetailViewModel()

    let resource: Resource
    let group: StudyGroup

    @State private var showShareSheet  = false
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    fileHeader
                    actionBar

                    if !vm.summary.isEmpty {
                        summaryCard
                    }

                    contentPreview
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            vm.setup(resource: resource)
            if !resource.isLink {
                await vm.download(resource: resource)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = vm.localURL {
                ShareSheet(items: [url])
            }
        }
        .alert("Delete Resource", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    await vm.delete(resource: resource) { dismiss() }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete \"\(resource.title)\". This cannot be undone.")
        }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }

    // MARK: - Nav Bar
    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .primary.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            Spacer()
            Text("Resources")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Image(systemName: "chevron.left").opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemGroupedBackground))
    }

    // MARK: - File Header
    private var fileHeader: some View {
        HStack(spacing: 14) {
            KIconBox(
                icon:        resource.iconName,
                iconColor:   Color(hex: resource.iconColor),
                bgColor:     Color(hex: resource.iconColor).opacity(0.12),
                size:        52,
                cornerRadius: 14,
                iconSize:    24
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(resource.title)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(2)
                Text("\(resource.uploaderName) • \(resource.formattedDate)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Action Bar
    private var actionBar: some View {
        HStack(spacing: 0) {
            // Like
            actionButton(
                icon:  vm.isLiked ? "heart.fill" : "heart",
                label: "Like",
                color: vm.isLiked ? Color(hex: "#E84040") : .secondary
            ) {
                Task { await vm.toggleLike(resource: resource) }
            }

            divider

            // Save
            actionButton(
                icon:  vm.isSaved ? "bookmark.fill" : "bookmark",
                label: "Save",
                color: vm.isSaved ? Color(hex: "#0300BF") : .secondary
            ) {
                Task { await vm.toggleSave(resource: resource) }
            }

            divider

            // Summarize — PDF only
            if resource.isPDF {
                actionButton(
                    icon:      "doc.text.magnifyingglass",
                    label:     "Summarize",
                    color:     vm.summary.isEmpty ? .secondary : Color(hex: "#6B3FD4"),
                    isLoading: vm.isSummarizing
                ) {
                    Task { await vm.summarize(resource: resource) }
                }
                divider
            }

            // Download
            actionButton(
                icon:      "arrow.down.circle",
                label:     "Download",
                color:     .secondary,
                isLoading: vm.isDownloading && vm.localURL == nil
            ) {
                if vm.localURL != nil {
                    showShareSheet = true
                }
            }

            // Delete — uploader only
            if resource.uploadedBy == authVM.currentUser?.uid {
                divider
                actionButton(
                    icon:  "trash",
                    label: "Delete",
                    color: Color(hex: "#E84040")
                ) {
                    showDeleteAlert = true
                }
            }
        }
        .padding(.vertical, 4)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .frame(width: 1, height: 36)
    }

    private func actionButton(
        icon:      String,
        label:     String,
        color:     Color,
        isLoading: Bool = false,
        action:    @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if isLoading {
                    ProgressView().scaleEffect(0.7)
                        .frame(height: 22)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                        .frame(height: 22)
                }
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundColor(Color(hex: "#6B3FD4"))
                    .font(.system(size: 14))
                Text("AI Summary")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#6B3FD4"))
                Spacer()
                Button {
                    vm.clearSummary()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
            }
            Text(vm.summary)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineSpacing(5)
        }
        .padding(14)
        .background(Color(hex: "#EDE7FF").opacity(0.5))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "#6B3FD4").opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Content Preview
    @ViewBuilder
    private var contentPreview: some View {
        if resource.isLink {
            linkPreview
        } else if vm.isDownloading && vm.localURL == nil {
            loadingPreview
        } else if let url = vm.localURL {
            if resource.isPDF {
                PDFKitView(url: url)
                    .frame(height: 520)
                    .cornerRadius(14)
                    .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
            } else if resource.isMedia {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .scaledToFit()
                            .cornerRadius(14)
                    case .failure:
                        failedPreview
                    case .empty:
                        loadingPreview
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
    }

    private var linkPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                KIconBox(
                    icon:        "link",
                    iconColor:   Color(hex: "#1A6BDB"),
                    bgColor:     Color(hex: "#EAF3FF"),
                    size:        36,
                    cornerRadius: 10,
                    iconSize:    16
                )
                Text("Open Link")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A6BDB"))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#1A6BDB"))
            }
            Text(resource.url)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
        .onTapGesture {
            if let url = URL(string: resource.url) {
                UIApplication.shared.open(url)
            }
        }
    }

    private var loadingPreview: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading file...")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }

    private var failedPreview: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            Text("Could not load file")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color(.systemBackground))
        .cornerRadius(14)
    }
}

// MARK: - PDFKit View
struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView         = PDFView()
        pdfView.autoScales  = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.document    = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

#Preview {
    NavigationStack {
        ResourceDetailView(
            resource: Resource(
                resourceId:   "1",
                groupId:      "g1",
                title:        "iOS_Lec_Note.pdf",
                type:         "document",
                url:          "",
                fileExtension: "pdf",
                uploadedBy:   "uid1",
                uploaderName: "Alex Chen",
                createdAt:    Date(),
                likedBy:      [],
                savedBy:      []
            ),
            group: StudyGroup(
                groupId:     "g1",
                name:        "iOS Dev",
                subject:     "iOS Development",
                major:       "Computer Science",
                description: "Test",
                createdBy:   "uid1",
                members:     ["uid1"],
                privacy:     "public",
                university:  "NIBM",
                createdAt:   Date()
            )
        )
        .environmentObject(AuthViewModel())
    }
}
