//
//  AddMembersView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-21.
//

import SwiftUI
import FirebaseAuth

struct AddMembersView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMembers: [AppUser]

    @State private var allUsers: [AppUser] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false

    private let service = FirestoreService.shared
    private var currentUID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    var filteredUsers: [AppUser] {
        let others = allUsers.filter {
            $0.uid != currentUID && !$0.uid.isEmpty
        }
        if searchText.isEmpty { return others }
        let q = searchText.lowercased()
        return others.filter {
            $0.username.lowercased().contains(q) ||
            $0.email.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Search bar
                KSearchBar(text: $searchText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    List {
                        if !filteredUsers.isEmpty {
                            Section("All Users") {
                                ForEach(filteredUsers) { user in
                                    UserRowItem(
                                        user: user,
                                        isSelected: selectedMembers
                                            .contains { $0.uid == user.uid }
                                    ) {
                                        toggleMember(user)
                                    }
                                }
                            }
                        } else {
                            ContentUnavailableView(
                                "No users found",
                                systemImage: "person.slash"
                            )
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Add Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add (\(selectedMembers.count))") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedMembers.isEmpty)
                }
            }
        }
        .task { await loadUsers() }
    }

    // MARK: - Helpers
    private func toggleMember(_ user: AppUser) {
        if selectedMembers.contains(where: { $0.uid == user.uid }) {
            selectedMembers.removeAll { $0.uid == user.uid }
        } else {
            selectedMembers.append(user)
        }
    }

    private func loadUsers() async {
        isLoading = true
        do {
            allUsers = try await service.fetchAllUsers()
        } catch {
            print("fetchAllUsers: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Row
private struct UserRowItem: View {
    let user: AppUser
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                KUserAvatar(
                    imageURL: user.profileImage.isEmpty ? nil : user.profileImage,
                    name: user.username,
                    size: 40
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.username)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    if !user.email.isEmpty {
                        Text(user.email)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Image(systemName: isSelected
                      ? "checkmark.circle.fill"
                      : "circle")
                    .foregroundColor(isSelected ? .blue : .gray.opacity(0.4))
                    .font(.system(size: 22))
            }
        }
        .buttonStyle(.plain)
    }
}
