//
//  UploadResourceView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//

import SwiftUI
import UniformTypeIdentifiers

struct UploadResourceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = UploadResourceViewModel()

    let group: StudyGroup

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                navBar

                // Mascot
                HStack {
                    Spacer()
                    Image("home_girl")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                    Spacer()
                }
                .padding(.top, 8)

                // Upload area
                uploadArea
                    .padding(.top, 24)

                // Type segment
                sectionLabel("RESOURCE TYPE").padding(.top, 24)
                KSegmentControl(
                    options: ["Document", "Media", "Link"],
                    selected: $vm.selectedType
                )
                .padding(.top, 8)

                // Fields based on type
                if vm.selectedType == 2 {
                    sectionLabel("LINK URL").padding(.top, 24)
                    linkField.padding(.top, 8)
                }

                sectionLabel("TITLE").padding(.top, 24)
                titleField.padding(.top, 8)

                addButton
                    .padding(.top, 32)
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .fileImporter(
            isPresented: $vm.showFilePicker,
            allowedContentTypes: [.pdf, .plainText],
            allowsMultipleSelection: false
        ) { result in
            handleFilePick(result: result)
        }
        .sheet(isPresented: $vm.showImagePicker) {
            ImagePicker(image: Binding(
                get: { nil },
                set: { img in
                    if let img, let data = img.jpegData(compressionQuality: 0.8) {
                        vm.selectedFile     = data
                        vm.selectedFileExt  = "jpg"
                        vm.selectedFileName = "image.jpg"
                    }
                }
            ))
        }
        .onChange(of: vm.didUpload) { _, uploaded in
            if uploaded { dismiss() }
        }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            Spacer()
            Text("Upload Resource")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Image(systemName: "chevron.left").opacity(0)
        }
    }

    private var uploadArea: some View {
        Button {
            if vm.selectedType == 0 {
                vm.showFilePicker = true
            } else if vm.selectedType == 1 {
                vm.showImagePicker = true
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        Color(hex: "#0300BF"),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6])
                    )
                    .frame(height: 160)

                if let name = vm.selectedFile != nil ? vm.selectedFileName : nil, !name.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: "#1D9E75"))
                        Text(name)
                            .font(.system(size: 13))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "plus")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(Color(hex: "#0300BF"))
                        Text("Click here to upload photo, documents...")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(vm.selectedType == 2) // disabled for links
        .opacity(vm.selectedType == 2 ? 0.4 : 1)
    }

    private var linkField: some View {
        HStack(spacing: 12) {
            KIconBox(
                icon: "link",
                iconColor: Color(hex: "#1A6BDB"),
                bgColor: Color(hex: "#EAF3FF"),
                size: 34, cornerRadius: 17, iconSize: 14
            )
            TextField("e.g. https://example.com", text: $vm.linkURL)
                .font(.system(size: 14))
                .keyboardType(.URL)
                .autocapitalization(.none)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    private var titleField: some View {
        HStack(spacing: 12) {
            KIconBox(
                icon: "text.alignleft",
                iconColor: Color(hex: "#6B3FD4"),
                bgColor: Color(hex: "#EDE7FF"),
                size: 34, cornerRadius: 17, iconSize: 14
            )
            TextField("e.g. iOS Lecture Notes", text: $vm.title)
                .font(.system(size: 14))
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    private var addButton: some View {
        Button {
            Task { await vm.upload(for: group) }
        } label: {
            ZStack {
                if vm.isUploading {
                    ProgressView().tint(.white)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Add Resource")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(vm.isValid ? Color(hex: "#0300BF") : Color(.systemGray4))
            .clipShape(Capsule())
        }
        .disabled(!vm.isValid || vm.isUploading)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .tracking(0.5)
    }

    private func handleFilePick(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            if let data = try? Data(contentsOf: url) {
                vm.selectedFile     = data
                vm.selectedFileExt  = url.pathExtension.lowercased()
                vm.selectedFileName = url.lastPathComponent
                if vm.title.isEmpty {
                    vm.title = url.deletingPathExtension().lastPathComponent
                }
            }
        case .failure(let error):
            vm.errorMessage = error.localizedDescription
            vm.showError    = true
        }
    }
}

#Preview {
    NavigationStack {
        UploadResourceView(group: StudyGroup(
            groupId: "preview", name: "iOS Dev",
            subject: "iOS Development", major: "Computer Science",
            description: "Test", createdBy: "uid1",
            members: ["uid1"], privacy: "public",
            university: "NIBM", createdAt: Date()
        ))
        .environmentObject(AuthViewModel())
    }
}
