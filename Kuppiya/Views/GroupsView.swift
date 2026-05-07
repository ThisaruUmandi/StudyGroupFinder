import SwiftUI

struct GroupsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = GroupsViewModel()
    @State private var selectedGroup: StudyGroup? = nil
    @State private var navigateToGroup = false
    @State private var showCreateGroup = false      // ← new

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Header
                    VStack(spacing: 0) {
                        HStack {
                            Text("My Groups")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            Spacer()
                            // Create Group button
                            Button {
                                showCreateGroup = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(Color("PrimaryPurple"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                        Image("my_group")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 110)
                            .padding(.bottom, -15)
                            .zIndex(1)

                        KSearchBar(text: $viewModel.searchText)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                            .padding(.top, 8)
                    }
                    .background(Color(.systemBackground))

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
                            // Prompt to create when empty
                            if viewModel.searchText.isEmpty {
                                Button {
                                    showCreateGroup = true
                                } label: {
                                    Text("Create your first group")
                                        .font(.system(size: 14,
                                                      weight: .semibold))
                                        .foregroundColor(Color("PrimaryPurple"))
                                }
                                .padding(.top, 4)
                            }
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
            // ← Create Group sheet
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupView { newGroup in
                    Task { await viewModel.loadMyGroups() }
                }
                .environmentObject(authVM)
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
