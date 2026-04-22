import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = CreateGroupViewModel()

    var onGroupCreated: ((StudyGroup) -> Void)?

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Fixed Header
            headerSection

            // MARK: Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    sectionLabel("GROUP INFORMATION")
                    groupInfoFields

                    sectionLabel("PRIVACY")
                    privacySection

                    sectionLabel("MEMBERS")
                    membersSection

                    KButton(title: "Create Group",
                            isLoading: viewModel.isLoading) {
                        Task {
                            await viewModel.createGroup(
                                university: viewModel.university
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $viewModel.showAddMembers) {
            AddMembersView(selectedMembers: $viewModel.selectedMembers)
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            ShareSheet(items: [viewModel.inviteLink])
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.createdGroup) { _, group in
            if let group {
                onGroupCreated?(group)
                dismiss()
            }
        }
        .onAppear {
            if let user = authVM.currentUser {
                viewModel.prefill(
                    major: user.major,
                    university: user.university
                )
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Create a New Group")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.black)
//                    .padding(.leading,30)
//                    .padding(.top, -20)
            }

            Spacer()

            Image("oboy_l")
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding(.bottom, 0)
                .zIndex(1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(Color.white)
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

    // MARK: - Group info fields
    private var groupInfoFields: some View {
        VStack(spacing: 0) {

            GroupFormField(
                icon: "person.fill",
                iconColor: Color(hex: "#8423B3"),
                iconBg: Color(hex: "#8423B3").opacity(0.12),
                placeholder: "GROUP NAME",
                hint: "e.g. Your Group Name is here",
                text: $viewModel.groupName
            )
            Divider().padding(.leading, 68)

            GroupFormField(
                icon: "building.columns.fill",
                iconColor: Color(hex: "#1A6BDB"),
                iconBg: Color(hex: "#1A6BDB").opacity(0.12),
                placeholder: "UNIVERSITY",
                hint: "e.g. Your University",
                text: $viewModel.university
            )
            Divider().padding(.leading, 68)

            GroupFormField(
                icon: "book.fill",
                iconColor: Color(hex: "#2EAA6E"),
                iconBg: Color(hex: "#2EAA6E").opacity(0.12),
                placeholder: "SUBJECT",
                hint: "e.g. Related Subject is here",
                text: $viewModel.subject
            )
            Divider().padding(.leading, 68)

            GroupFormField(
                icon: "text.alignleft",
                iconColor: Color(hex: "#F5A623"),
                iconBg: Color(hex: "#F5A623").opacity(0.12),
                placeholder: "DESCRIPTION",
                hint: "e.g. Group details, goals, Expectations...",
                text: $viewModel.description,
                isMultiline: true
            )
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }

    // MARK: - Privacy section
    private var privacySection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                KIconBox(
                    icon: "globe",
                    iconColor: Color(hex: "#1A6BDB"),
                    bgColor: Color(hex: "#1A6BDB").opacity(0.12),
                    size: 42,
                    cornerRadius: 12,
                    iconSize: 18
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Public Group")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    Text("Visible in search and to everyone")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { viewModel.isPublic },
                    set: { if $0 { viewModel.isPublic = true } }
                ))
                .labelsHidden()
                .tint(Color(hex: "0300BF"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider().padding(.leading, 72)

            HStack(spacing: 14) {
                KIconBox(
                    icon: "lock.shield.fill",
                    iconColor: Color(hex: "#5B4DE8"),
                    bgColor: Color(hex: "#5B4DE8").opacity(0.12),
                    size: 42,
                    cornerRadius: 12,
                    iconSize: 18
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Private Group")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                    Text("Admin Must Approve new members")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { !viewModel.isPublic },
                    set: { if $0 { viewModel.isPublic = false } }
                ))
                .labelsHidden()
                .tint(Color(hex: "0300BF"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }

    // MARK: - Members section
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {

                    MemberChip(
                        name: authVM.currentUser?.username ?? "You",
                        imageURL: authVM.currentUser?.profileImage
                            .isEmpty == false
                            ? authVM.currentUser?.profileImage : nil,
                        role: "Admin",
                        canRemove: false,
                        onRemove: {}
                    )

                    ForEach(viewModel.selectedMembers) { user in
                        MemberChip(
                            name: user.username,
                            imageURL: user.profileImage.isEmpty
                                ? nil : user.profileImage,
                            role: "Member",
                            canRemove: true,
                            onRemove: { viewModel.removeMember(user) }
                        )
                    }

                    DashedActionButton(
                        icon: "person.badge.plus",
                        color: Color(hex: "0300BF"),
                        title: "Add",
                        subtitle: "Search users"
                    ) {
                        viewModel.showAddMembers = true
                    }

                    DashedActionButton(
                        icon: "link",
                        color: Color(hex: "#F5A623"),
                        title: "Invite",
                        subtitle: "Copy link"
                    ) {
                        viewModel.shareLink()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }

            if !viewModel.inviteLink.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13))
                    Text(viewModel.inviteLink)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Spacer()
                    Button("Copy") { viewModel.copyLink() }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "0300BF"))
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.04), radius: 6)
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Group Form Field
private struct GroupFormField: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let placeholder: String
    let hint: String
    @Binding var text: String
    var isMultiline: Bool = false

    var body: some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: 14) {
            KIconBox(
                icon: icon,
                iconColor: iconColor,
                bgColor: iconBg,
                size: 42,
                cornerRadius: 12,
                iconSize: 18
            )
            .padding(.top, isMultiline ? 4 : 0)

            VStack(alignment: .leading, spacing: 3) {
                Text(placeholder)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)

                if isMultiline {
                    ZStack(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(hint)
                                .font(.system(size: 14))
                                .foregroundColor(Color(.placeholderText))
                        }
                        TextEditor(text: $text)
                            .frame(minHeight: 60)
                            .font(.system(size: 14))
                            .scrollContentBackground(.hidden)
                            .padding(.leading, -4)
                    }
                } else {
                    TextField(hint, text: $text)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Member Chip
private struct MemberChip: View {
    let name: String
    let imageURL: String?
    let role: String
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                KUserAvatar(imageURL: imageURL, name: name, size: 56)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
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
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            Text(role)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(width: 74)
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Dashed Action Button
private struct DashedActionButton: View {
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
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(
        context: Context
    ) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }
    func updateUIViewController(
        _ uvc: UIActivityViewController,
        context: Context
    ) {}
}

#Preview {
    CreateGroupView()
        .environmentObject(AuthViewModel())
}
