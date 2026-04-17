//
//  GroupsView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct GroupsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = GroupsViewModel()
    @State private var selectedGroup: StudyGroup? = nil
    @State private var navigateToGroup = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6).ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Header
                    VStack(spacing: 0) {
                        // Title row
                        HStack {
                            Text("My Groups")
                                .font(.system(size: 22,
                                              weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                        // Illustration
                        Image("my_group")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 110)
                            .padding(.bottom, 8)

                        // Search
                        KSearchBar(text: $viewModel.searchText)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                    }
                    .background(Color.white)

                    // MARK: Groups List
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if viewModel.filteredGroups.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "person.3")
                                .font(.system(size: 44))
                                .foregroundColor(.gray.opacity(0.4))
                            Text(viewModel.searchText.isEmpty
                                 ? "You haven't joined any groups yet"
                                 : "No groups found")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 10) {
                                ForEach(viewModel.filteredGroups) { group in
                                    KGroupCard(
                                        group: group,
                                        sessionCount: viewModel
                                            .sessionCounts[group.groupId] ?? 0
                                    ) {
                                        selectedGroup = group
                                        navigateToGroup = true
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 80)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToGroup) {
                if let group = selectedGroup {
                    GroupDashboardView(group: group)
                        .environmentObject(authVM)
                }
            }
        }
        .task {
            await viewModel.loadMyGroups()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    GroupsView()
        .environmentObject(AuthViewModel())
}
