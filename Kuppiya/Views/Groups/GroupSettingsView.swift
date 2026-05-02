import SwiftUI

struct GroupSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = GroupSettingsViewModel()

    let group: StudyGroup

    @State private var memberToRemove: AppUser? = nil

    private var isAdmin: Bool {
        group.createdBy == authVM.currentUser?.uid
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        avatarSection

                        sectionLabel("GROUP INFORMATION")
                        groupInfoSection

                        sectionLabel("PRIVACY & ACCESS")
                        privacySection

                        sectionLabel(
                            "MEMBERS · \(viewModel.members.count) members"
                        )
                        membersSection

                        if isAdmin
                            && group.privacy == "private"
                            && !viewModel.joinRequests.isEmpty {
                            sectionLabel("JOIN REQUESTS")
                            joinRequestsSection
                        }

                        if !isAdmin {
                            sectionLabel("RATE & REVIEW")
                            reviewSection
                        }

                        leaveGroupButton
                            .padding(.top, 32)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Group Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarItems(
                leading: Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain),
                trailing: Button {
                    Task {
                        await viewModel.saveGroupInfo(
                            groupId: group.groupId
                        )
                        if isAdmin {
                            await viewModel.savePrivacy(
                                groupId: group.groupId
                            )
                        }
                        if viewModel.selectedImage != nil {
                            await viewModel.uploadGroupImage(
                                groupId: group.groupId
                            )
                        }
                    }
                } label: {
                    if viewModel.isSaving || viewModel.isUploadingImage {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Save")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#0300BF"))
                            .clipShape(Capsule())
                    }
                }
                .buttonStyle(.plain)
            )
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
            .sheet(isPresented: $viewModel.showAddMembers) {
                AddMembersView(
                    selectedMembers: $viewModel.selectedMembers
                )
                .onDisappear {
                    Task {
                        await viewModel.addSelectedMembers(
                            groupId: group.groupId
                        )
                    }
                }
            }
            .sheet(isPresented: $viewModel.showReviewSheet) {
                ReviewSheet(
                    rating: $viewModel.rating,
                    reviewText: $viewModel.reviewText,
                    title: "How is Your Group ?",
                    subtitle: "Please take a moment to rate and review\nyour experience in this group.",
                    placeholder: "Type a review"
                ) {
                    Task {
                        await viewModel.submitReview(
                            groupId: group.groupId
                        )
                    }
                }
            }
            // MARK: Leave Group Confirmation
            .confirmationDialog(
                leaveConfirmMessage,
                isPresented: $viewModel.showLeaveConfirm,
                titleVisibility: .visible
            ) {
                Button("Leave Group", role: .destructive) {
                    Task {
                        await viewModel.leaveGroup(group: group)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            // MARK: Remove Member Confirmation
            .confirmationDialog(
                "Remove \(memberToRemove?.username ?? "this member") from the group?",
                isPresented: Binding(
                    get: { memberToRemove != nil },
                    set: { if !$0 { memberToRemove = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Remove Member", role: .destructive) {
                    if let member = memberToRemove {
                        Task {
                            await viewModel.removeMember(
                                member,
                                groupId: group.groupId
                            )
                            memberToRemove = nil
                        }
                    }
                }
                Button("Cancel", role: .cancel) {
                    memberToRemove = nil
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onChange(of: viewModel.didLeaveGroup) { _, left in
                if left { dismiss() }
            }
        }
        .task {
            viewModel.prefill(from: group)
            await viewModel.loadData(group: group)
        }
    }

    private var leaveConfirmMessage: String {
        if isAdmin && group.members.count == 1 {
            return "You are the only member. Leaving will delete this group permanently."
        } else if isAdmin {
            return "Another member will become the new admin."
        }
        return "Are you sure you want to leave this group?"
    }

    // MARK: - Avatar
    private var avatarSection: some View {
        HStack {
            Spacer()
            ZStack(alignment: .bottomTrailing) {
                if let selectedImage = viewModel.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                } else {
                    KGroupAvatar(
                        imageURL: group.groupImageURL,
                        name: group.name,
                        size: 100
                    )
                }

                if isAdmin {
                    Button {
                        viewModel.showImagePicker = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .shadow(
                                    color: .black.opacity(0.12),
                                    radius: 4, x: 0, y: 2
                                )
                            Image(systemName: "pencil.line")
                                .font(.system(
                                    size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B3FD4"))
                        }
                    }
                    .offset(x: 4, y: 4)
                }
            }
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Section label
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .tracking(0.5)
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 10)
    }

    // MARK: - Group Info
    private var groupInfoSection: some View {
        VStack(spacing: 0) {
            SettingsFormField(
                icon: "person.2.fill",
                iconColor: Color(hex: "#6B3FD4"),
                iconBg: Color(hex: "#6B3FD4").opacity(0.12),
                label: "GROUP NAME",
                text: $viewModel.name
            )
            Divider().padding(.leading, 68)

            SettingsFormField(
                icon: "book.fill",
                iconColor: Color(hex: "#2EAA6E"),
                iconBg: Color(hex: "#2EAA6E").opacity(0.12),
                label: "SUBJECT",
                text: $viewModel.subject
            )
            Divider().padding(.leading, 68)

            SettingsFormField(
                icon: "clock.fill",
                iconColor: Color(hex: "#F5A623"),
                iconBg: Color(hex: "#F5A623").opacity(0.12),
                label: "DESCRIPTION",
                text: $viewModel.description,
                isMultiline: true
            )
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }

    // MARK: - Privacy
    private var privacySection: some View {
        VStack(spacing: 0) {
            if isAdmin {
                HStack(spacing: 14) {
                    KIconBox(
                        icon: "globe",
                        iconColor: Color(hex: "#1A6BDB"),
                        bgColor: Color(hex: "#1A6BDB").opacity(0.12),
                        size: 42, cornerRadius: 12, iconSize: 18
                    )
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Public Group")
                            .font(.system(size: 15, weight: .medium))
                        Text("Visible in search and to everyone")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { viewModel.isPublic },
                        set: { if $0 { viewModel.isPublic = true } }
                    ))
                    .labelsHidden()
                    .tint(Color(hex: "#1A6BDB"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider().padding(.leading, 72)

                HStack(spacing: 14) {
                    KIconBox(
                        icon: "lock.shield.fill",
                        iconColor: Color(hex: "#5B4DE8"),
                        bgColor: Color(hex: "#5B4DE8").opacity(0.12),
                        size: 42, cornerRadius: 12, iconSize: 18
                    )
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Request Approval")
                            .font(.system(size: 15, weight: .medium))
                        Text("Admin must approve new members")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { !viewModel.isPublic },
                        set: { if $0 { viewModel.isPublic = false } }
                    ))
                    .labelsHidden()
                    .tint(Color(hex: "#5B4DE8"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

            } else {
                SettingsReadOnlyField(
                    icon: "person.2.fill",
                    iconColor: Color(hex: "#6B3FD4"),
                    iconBg: Color(hex: "#6B3FD4").opacity(0.12),
                    label: "GROUP TYPE",
                    value: group.privacy.capitalized
                )
                Divider().padding(.leading, 68)
                SettingsReadOnlyField(
                    icon: "building.columns.fill",
                    iconColor: Color(hex: "#1A6BDB"),
                    iconBg: Color(hex: "#1A6BDB").opacity(0.12),
                    label: "UNIVERSITY",
                    value: group.university
                )
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }

    // MARK: - Members
    private var membersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.members) { member in
                    MemberSettingsChip(
                        user: member,
                        role: member.uid == group.createdBy
                            ? "Admin" : "Member",
                        canRemove: isAdmin
                            && member.uid != group.createdBy,
                        onRemove: {
                            memberToRemove = member  // ← show confirmation
                        }
                    )
                }

                if isAdmin {
                    DashedChipButton(
                        icon: "person.badge.plus",
                        color: Color(hex: "#6B3FD4"),
                        title: "Add",
                        subtitle: "Search users"
                    ) {
                        viewModel.showAddMembers = true
                    }
                }

                DashedChipButton(
                    icon: "link",
                    color: Color(hex: "#F5A623"),
                    title: "Invite",
                    subtitle: "Copy link"
                ) {
                    UIPasteboard.general.string = group.inviteLink
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Join Requests
    private var joinRequestsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Join Requests")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("\(viewModel.joinRequests.count) PENDING")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#BA7517"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "#FAEEDA"))
                    .cornerRadius(20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            ForEach(viewModel.joinRequests) { request in
                HStack(spacing: 12) {
                    KUserAvatar(
                        name: request.senderName,
                        size: 44
                    )
                    Text(request.senderName)
                        .font(.system(size: 15, weight: .medium))
                    Spacer()
                    Button {
                        Task {
                            await viewModel.rejectRequest(request)
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(
                                Color(hex: "#FF4444").opacity(0.8)
                            )
                    }
                    Button {
                        Task {
                            await viewModel.approveRequest(request)
                        }
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: "#2EAA6E"))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                if request.id != viewModel.joinRequests.last?.id {
                    Divider().padding(.leading, 72)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }

    // MARK: - Review
    private var reviewSection: some View {
        Button {
            viewModel.showReviewSheet = true
        } label: {
            HStack(spacing: 12) {
                KIconBox(
                    icon: "book.fill",
                    iconColor: .secondary,
                    bgColor: Color(.systemGray5),
                    size: 42, cornerRadius: 12, iconSize: 18
                )
                Text("Write a Review")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "arrow.up.circle")
                    .font(.system(size: 22))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }

    // MARK: - Leave Group
    private var leaveGroupButton: some View {
        Button {
            viewModel.showLeaveConfirm = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName:
                    "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                Text("Leave Group")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(Color(hex: "#E8143C"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .stroke(Color(hex: "#E8143C"), lineWidth: 1.5)
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Member Settings Chip
private struct MemberSettingsChip: View {
    let user: AppUser
    let role: String
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                KUserAvatar(
                    imageURL: user.profileImage.isEmpty
                        ? nil : user.profileImage,
                    name: user.username,
                    size: 54
                )
                if canRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 17))
                            .foregroundColor(Color(.systemGray3))
                            .background(Color.white, in: Circle())
                    }
                    .offset(x: 4, y: -4)
                }
            }
            Text(user.username)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
            Text(role)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(width: 74)
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Dashed Chip Button
private struct DashedChipButton: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            color,
                            style: StrokeStyle(lineWidth: 1.5, dash: [5])
                        )
                        .frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(color)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(width: 74)
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GroupSettingsView(group: StudyGroup(
        groupId: "preview",
        name: "iOS Dev",
        subject: "iOS Application Development",
        major: "Computer Science",
        description: "Test group",
        createdBy: "preview-uid",
        members: ["preview-uid"],
        privacy: "public",
        university: "NIBM",
        createdAt: Date()
    ))
    .environmentObject(AuthViewModel())
}
