//
//  GroupDetailView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-25.
//

import SwiftUI

struct GroupDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = GroupDetailViewModel()

    let group: StudyGroup

    private var uid: String { authVM.currentUser?.uid ?? "" }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    navBar
                    infoCard.padding(.top, 24)
                    membersRow.padding(.top, 12)
                    if !group.description.isEmpty {
                        Text(group.description)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                            .padding(.top, 20)
                    }
                    if !vm.reviews.isEmpty {
                        reviewsSection.padding(.top, 24)
                    }
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            buttonArea
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $vm.navigateToDashboard) {
            GroupDashboardView(group: group).environmentObject(authVM)
        }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
        .task { await vm.load(group: group, uid: uid) }
    }

    // MARK: - Nav bar

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            Spacer()
            Text("Group Details")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            // invisible balance so title stays centered
            Image(systemName: "chevron.left").opacity(0)
        }
    }

    // MARK: - Group info card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Avatar + group name
            HStack(spacing: 14) {
                KGroupAvatar(imageURL: group.groupImageURL, name: group.name, size: 54)
                Text(group.name)
                    .font(.system(size: 22, weight: .bold))
            }
            .padding(.bottom, 12)

            Divider()

            infoRow(
                icon: "doc.text.fill",
                label: "SUBJECT",
                value: group.subject.uppercased(),
                iconColor: Color(hex: "#6B3FD4"),
                bgColor: Color(hex: "#EDE7FF")
            )

            Divider()

            infoRow(
                icon: "graduationcap.fill",
                label: "UNIVERSITY",
                value: "\(group.university) • Year 4",
                iconColor: Color(hex: "#3D3D3D"),
                bgColor: Color(hex: "#EFEFEF")
            )
        }
        .padding(16)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 3)
    }

    private func infoRow(
        icon: String,
        label: String,
        value: String,
        iconColor: Color,
        bgColor: Color
    ) -> some View {
        HStack(spacing: 12) {
            KIconBox(
                icon: icon,
                iconColor: iconColor,
                bgColor: bgColor,
                size: 34,
                cornerRadius: 17,
                iconSize: 14
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.3)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.vertical, 13)
    }

    // MARK: - Members bar

    private var membersRow: some View {
        HStack(spacing: 8) {
            stackedAvatars
            Text("\(group.members.count) MEMBERS")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            privacyPill
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color(hex: "#F4F4F4"))
        .cornerRadius(12)
    }

    // Shows first 2 member avatars then a +N count circle
    private var stackedAvatars: some View {
        let shown = min(group.members.count, 2)
        let extra = group.members.count - shown
        return ZStack(alignment: .leading) {
            ForEach(0..<shown, id: \.self) { i in
                KUserAvatar(name: "M\(i)", size: 28)
                    .offset(x: CGFloat(i) * 18)
                    .zIndex(Double(shown - i))
            }
            if extra > 0 {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#0300BF"))
                        .frame(width: 28, height: 28)
                    Text("+\(extra)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(.systemGroupedBackground))
                }
                .offset(x: CGFloat(shown) * 18)
            }
        }
        .frame(width: CGFloat(shown + (extra > 0 ? 1 : 0)) * 18 + 28)
    }

    private var privacyPill: some View {
        // green for private, brand blue for public
        let color = group.isPrivate ? Color(hex: "#1D9E75") : Color(hex: "#0300BF")
        return HStack(spacing: 4) {
            Image(systemName: group.isPrivate ? "lock.fill" : "globe")
                .font(.system(size: 9, weight: .semibold))
            Text(group.isPrivate ? "PRIVATE" : "PUBLIC")
                .font(.system(size: 10, weight: .bold))
                .tracking(0.3)
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .overlay(Capsule().stroke(color, lineWidth: 1))
    }

    // MARK: - Reviews

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reviews")
                .font(.system(size: 17, weight: .bold))
            ForEach(vm.reviews) { review in
                ReviewCard(review: review)
            }
        }
    }

    // MARK: - Bottom action button

    // Floats above scroll content with a fade gradient behind it
    private var buttonArea: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [.white.opacity(0), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            .allowsHitTesting(false)

            VStack {
                if vm.isMember {
                    // Already a member — go straight to dashboard
                    mainButton(title: "Go to Group", enabled: true) {
                        vm.navigateToDashboard = true
                    }
                } else if group.isPrivate {
                    // Private group — send a join request to admin
                    mainButton(
                        title: vm.hasPendingRequest ? "Request Sent" : "Request to Join",
                        enabled: !vm.hasPendingRequest,
                        loading: vm.isActing
                    ) {
                        let name = authVM.currentUser?.username ?? "User"
                        Task { await vm.requestJoin(group, senderName: name) }
                    }
                    .disabled(vm.hasPendingRequest || vm.isActing)
                } else {
                    // Public group — instant join
                    mainButton(title: "Join Group", enabled: true, loading: vm.isActing) {
                        Task { await vm.join(group) }
                    }
                    .disabled(vm.isActing)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemGroupedBackground))
            .padding(.bottom, 100)
        }
    }

    private func mainButton(
        title: String,
        enabled: Bool,
        loading: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                if loading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(enabled ? .white : Color(.systemGray2))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(enabled ? Color(hex: "#0300BF") : Color(.systemGray5))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Previews

#Preview("Private") {
    NavigationStack {
        GroupDetailView(group: StudyGroup(
            groupId: "preview-1",
            name: "iOS Dev",
            subject: "iOS App Development",
            major: "Computer Science",
            description: "A dedicated space for STEM majors tackling complex mathematical proofs and multidimensional calculus. We meet twice a week for deep-focus sessions and resource sharing. Serious learners only.",
            createdBy: "uid1",
            members: ["uid1","uid2","uid3","uid4","uid5",
                      "uid6","uid7","uid8","uid9","uid10",
                      "uid11","uid12","uid13","uid14"],
            privacy: "private",
            university: "NIBM",
            createdAt: Date()
        ))
        .environmentObject(AuthViewModel())
    }
}

#Preview("Public") {
    NavigationStack {
        GroupDetailView(group: StudyGroup(
            groupId: "preview-2",
            name: "iOS Dev",
            subject: "iOS App Development",
            major: "Computer Science",
            description: "A dedicated space for STEM majors tackling complex mathematical proofs and multidimensional calculus. We meet twice a week for deep-focus sessions and resource sharing. Serious learners only.",
            createdBy: "uid1",
            members: ["uid1","uid2","uid3","uid4","uid5",
                      "uid6","uid7","uid8","uid9","uid10",
                      "uid11","uid12","uid13","uid14"],
            privacy: "public",
            university: "NIBM",
            createdAt: Date()
        ))
        .environmentObject(AuthViewModel())
    }
}
