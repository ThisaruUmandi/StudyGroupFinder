//
//  ResourceView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-23.
//

import SwiftUI

struct ResourceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ResourceViewModel()

    @State private var searchText      = ""
    @State private var showUpload      = false
    @State private var selectedResource: Resource?

    let group: StudyGroup

    var displayed: [Resource] {
        if searchText.isEmpty { return vm.filtered }
        return vm.filtered.filter {
            $0.title.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                filterBar.padding(.top, 16)
                searchBar.padding(.top, 12).padding(.horizontal, 20)
                resourceList.padding(.top, 16)
            }

            // FAB
            Button { showUpload = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color(hex: "#0300BF"))
                    .clipShape(Circle())
                    .shadow(color: Color(hex: "#0300BF").opacity(0.4),
                            radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 90)
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedResource) { resource in
            ResourceDetailView(resource: resource, group: group)
            //Text ("ResourceDetailView")
                .environmentObject(authVM)
        }
        .navigationDestination(isPresented: $showUpload) {
            UploadResourceView(group: group)
            //Text("UploadResourceView")
                .environmentObject(authVM)
        }
        .onChange(of: showUpload) { _, isShowing in
            if !isShowing { Task { await vm.load(for: group.groupId) } }
        }
        .task { await vm.load(for: group.groupId) }
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
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            Spacer()
            Text("Resources")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Image("oboy_r")
                .resizable()
                .scaledToFit()
                .frame(width: 54)
                .offset(y: -6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private var filterBar: some View {
        KSegmentControl(
            options: vm.filters,
            selected: Binding(
                get: { vm.filters.firstIndex(of: vm.selectedFilter) ?? 0 },
                set: { vm.selectedFilter = vm.filters[$0] }
            )
        )
        .padding(.horizontal, 20)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search...", text: $searchText)
                .font(.system(size: 14))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    private var resourceList: some View {
        Group {
            if vm.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if displayed.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "folder")
                        .font(.system(size: 32))
                        .foregroundColor(.gray.opacity(0.35))
                    Text("No resources yet")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(displayed) { resource in
                            KResourceCard(resource: resource) {
                                selectedResource = resource
                            }
                            .padding(.horizontal, 20)
                            .contextMenu {
                                if resource.uploadedBy == authVM.currentUser?.uid {
                                    Button(role: .destructive) {
                                        Task { await vm.delete(resource: resource) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ResourceView(group: StudyGroup(
            groupId: "preview", name: "iOS Dev",
            subject: "iOS Development", major: "Computer Science",
            description: "Test", createdBy: "uid1",
            members: ["uid1"], privacy: "public",
            university: "NIBM", createdAt: Date()
        ))
        .environmentObject(AuthViewModel())
    }
}
