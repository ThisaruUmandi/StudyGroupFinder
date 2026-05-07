//
//  SessionDetailView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-01.
//

import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = SessionDetailViewModel()

    let session: StudySession
    let group: StudyGroup

    @State private var showReviewSheet = false

    // Completed = status is "completed" OR 2h after start time has passed
    var isCompleted: Bool {
        session.status == "completed" ||
        Date() > session.date.addingTimeInterval(2 * 60 * 60)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                navBar

                sectionLabel("SESSION DETAILS").padding(.top, 24)
                sessionDetailsCard.padding(.top, 8)

                sectionLabel("DATE & TIME").padding(.top, 24)
                dateTimeCard.padding(.top, 8)

                sectionLabel("SESSION TYPE").padding(.top, 24)
                sessionTypeCard.padding(.top, 8)

                sectionLabel("CREATION DETAIL").padding(.top, 24)
                creationDetailCard.padding(.top, 8)

                if isCompleted {
                    sectionLabel("RATE & REVIEW").padding(.top, 24)
                    reviewCard.padding(.top, 8)
                    sectionLabel("ATTENDANCE").padding(.top, 24)
                    attendanceCard.padding(.top, 8)
                }

                if !isCompleted && vm.canManage(session: session, group: group) {
                    actionButtons.padding(.top, 32)
                }

                Spacer(minLength: 60)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showReviewSheet) {
            ReviewSheet(
                rating: $vm.rating,
                reviewText: $vm.reviewText,
                title: "How is Your Session ?",
                subtitle: "Please take a moment to rate and review\nyour experience.",
                placeholder: "Type a review"
            ) {
                Task {
                    await vm.submitReview(session: session)
                    showReviewSheet = false
                }
            }
        }
        .task { await vm.loadCreator(uid: session.createdBy) }
        .onChange(of: vm.didCancel) { _, cancelled in
            if cancelled { dismiss() }
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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            Spacer()
            Text("Session Details")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            // Edit pencil — upcoming + admin/creator only
            if !isCompleted && vm.canManage(session: session, group: group) {
                Button {
                    if vm.isEditing {
                        Task { await vm.saveEdits(session: session) }
                    } else {
                        vm.startEditing(session: session)
                    }
                } label: {
                    Image(systemName: vm.isEditing ? "checkmark" : "pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#0300BF"))
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "#EEEEFF"))
                        .clipShape(Circle())
                }
            } else {
                Image(systemName: "chevron.left").opacity(0)
            }
        }
    }

    // MARK: - Session Details Card
    private var sessionDetailsCard: some View {
        VStack(spacing: 0) {
            if vm.isEditing {
                SettingsFormField(
                    icon: "book.fill",
                    iconColor: Color(hex: "#1D9E75"),
                    iconBg: Color(hex: "#E0F5EE"),
                    label: "SESSION TITLE",
                    text: $vm.editTitle
                )
                Divider().padding(.leading, 72)
                SettingsFormField(
                    icon: "text.alignleft",
                    iconColor: Color(hex: "#D85A30"),
                    iconBg: Color(hex: "#FFF0EB"),
                    label: "DESCRIPTION",
                    text: $vm.editDescription,
                    isMultiline: true
                )
                Divider().padding(.leading, 72)
                SettingsReadOnlyField(
                    icon: "doc.text.fill",
                    iconColor: Color(hex: "#6B3FD4"),
                    iconBg: Color(hex: "#EDE7FF"),
                    label: "SUBJECT",
                    value: group.subject
                )
            } else {
                SettingsReadOnlyField(
                    icon: "book.fill",
                    iconColor: Color(hex: "#1D9E75"),
                    iconBg: Color(hex: "#E0F5EE"),
                    label: "SESSION TITLE",
                    value: session.title
                )
                Divider().padding(.leading, 72)
                SettingsReadOnlyField(
                    icon: "text.alignleft",
                    iconColor: Color(hex: "#D85A30"),
                    iconBg: Color(hex: "#FFF0EB"),
                    label: "DESCRIPTION",
                    value: session.description.isEmpty ? "No description" : session.description
                )
                Divider().padding(.leading, 72)
                SettingsReadOnlyField(
                    icon: "doc.text.fill",
                    iconColor: Color(hex: "#6B3FD4"),
                    iconBg: Color(hex: "#EDE7FF"),
                    label: "SUBJECT",
                    value: group.subject
                )
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Date & Time Card
    private var dateTimeCard: some View {
        VStack(spacing: 0) {
            SettingsReadOnlyField(
                icon: "calendar",
                iconColor: Color(hex: "#0300BF"),
                iconBg: Color(hex: "#EEEEFF"),
                label: "DATE",
                value: formattedDate(session.date)
            )
            Divider().padding(.leading, 72)
            SettingsReadOnlyField(
                icon: "clock.fill",
                iconColor: Color(hex: "#BA7517"),
                iconBg: Color(hex: "#FAEEDA"),
                label: "START TIME",
                value: session.startTime
            )
        }
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Session Type Card
    private var sessionTypeCard: some View {
        HStack(spacing: 14) {
            KIconBox(
                icon: session.isOnline ? "video.fill" : "mappin.and.ellipse",
                iconColor: Color(hex: "#6B3FD4"),
                bgColor: Color(hex: "#EDE7FF"),
                size: 42, cornerRadius: 12, iconSize: 17
            )
            VStack(alignment: .leading, spacing: 3) {
                Text("TYPE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)
                Text(session.isOnline ? "ONLINE" : "PHYSICAL · \(session.location)")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            Spacer()

            // Navigation buttons — upcoming only
            if !isCompleted {
                if session.isOnline && !session.joinLink.isEmpty {
                    Button {
                        UIPasteboard.general.string = session.joinLink
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#0300BF"))
                            .frame(width: 34, height: 34)
                            .background(Color(hex: "#EEEEFF"))
                            .clipShape(Circle())
                    }
                    Button {
                        Task {
                            try? await FirestoreService.shared.markAttendance(
                                sessionId: session.sessionId,
                                groupId: session.groupId
                            )
                        }
                        if let url = URL(string: session.joinLink) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Image(systemName: "link")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#0300BF"))
                            .frame(width: 34, height: 34)
                            .background(Color(hex: "#EEEEFF"))
                            .clipShape(Circle())
                    }
                } else if session.isPhysical {
                    Button {
                        Task {
                            try? await FirestoreService.shared.markAttendance(
                                sessionId: session.sessionId,
                                groupId: session.groupId
                            )
                        }
                        openInMaps()
                    } label: {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#0300BF"))
                            .frame(width: 34, height: 34)
                            .background(Color(hex: "#EEEEFF"))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Creation Detail Card
    private var creationDetailCard: some View {
        VStack(spacing: 0) {
            SettingsReadOnlyField(
                icon: "person.2.fill",
                iconColor: Color(hex: "#BA7517"),
                iconBg: Color(hex: "#FAEEDA"),
                label: "GROUP",
                value: group.name
            )
            Divider().padding(.leading, 72)
            SettingsReadOnlyField(
                icon: "person.fill",
                iconColor: Color(hex: "#378ADD"),
                iconBg: Color(hex: "#EAF3FF"),
                label: "CREATED BY",
                value: vm.creatorName.isEmpty ? "Loading..." : vm.creatorName
            )
        }
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Review Card
    private var reviewCard: some View {
        Button { showReviewSheet = true } label: {
            HStack(spacing: 14) {
                KIconBox(
                    icon: "star.fill",
                    iconColor: Color(hex: "#F5A623"),
                    bgColor: Color(hex: "#FFF8E8"),
                    size: 42, cornerRadius: 12, iconSize: 17
                )
                VStack(alignment: .leading, spacing: 3) {
                    Text("YOUR RATING")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .tracking(0.5)
                    Text(vm.rating > 0 ? "\(vm.rating) stars — tap to update" : "Tap to rate & review")
                        .font(.system(size: 14))
                        .foregroundColor(vm.rating > 0 ? .primary : .secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Attendance Card
    private var attendanceCard: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .leading) {
                let shown = min(session.attendees.count, 4)
                ForEach(0..<shown, id: \.self) { i in
                    KUserAvatar(name: session.attendees[i], size: 36)
                        .offset(x: CGFloat(i) * 24)
                        .zIndex(Double(shown - i))
                }
                if session.attendees.count > 4 {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#0300BF"))
                            .frame(width: 36, height: 36)
                        Text("+\(session.attendees.count - 4)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(uiColor: .systemBackground))
                    }
                    .offset(x: CGFloat(4) * 24)
                }
            }
            .frame(
                width: session.attendees.isEmpty ? 36 :
                    CGFloat(min(session.attendees.count, 4)) * 24 + 36 +
                    (session.attendees.count > 4 ? 24 : 0)
            )

            Spacer()

            Text("\(session.attendees.count)")
                .font(.system(size: 22, weight: .bold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Action Buttons (upcoming + admin/creator only)
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task { await vm.cancelSession(session: session) }
            } label: {
                Text("Cancel Session")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#D85A30"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color(hex: "#D85A30"), lineWidth: 1.5)
                    )
            }

            // Enabled only after start time passes
//            Button {
//                Task { await vm.markCompleted(session: session) }
//            } label: {
//                Text("Session Completed")
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor((.systemBackground))
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(
//                        Date() > session.date
//                            ? Color(hex: "#0300BF")
//                            : Color(.systemGray4)
//                    )
//                    .clipShape(Capsule())
//            }
            //.disabled(Date() <= session.date)
        }
    }

    // MARK: - Helpers
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .tracking(0.5)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f.string(from: date)
    }

    private func openInMaps() {
        let name = session.location
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(name)&ll=\(session.latitude),\(session.longitude)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview("Upcoming") {
    NavigationStack {
        SessionDetailView(
            session: StudySession(
                sessionId: "1", groupId: "g1", groupName: "iOS Dev",
                title: "Swift Language Review",
                description: "A session schedule for review the Swift Language before exam.",
                date: Date().addingTimeInterval(3600), startTime: "08:30 PM",
                type: "online", joinLink: "https://meet.google.com/abc-defg",
                location: "", latitude: 0, longitude: 0, status: "upcoming",
                createdBy: "uid1", createdByName: "Kaveena De Silva", attendees: []
            ),
            group: StudyGroup(
                groupId: "g1", name: "iOS Dev", subject: "iOS Development",
                major: "Computer Science", description: "Test",
                createdBy: "uid1", members: ["uid1"], privacy: "public",
                university: "NIBM", createdAt: Date()
            )
        )
        .environmentObject(AuthViewModel())
    }
}

#Preview("Completed") {
    NavigationStack {
        SessionDetailView(
            session: StudySession(
                sessionId: "2", groupId: "g1", groupName: "iOS Dev",
                title: "Swift Language Review",
                description: "A session schedule for review the Swift Language before exam.",
                date: Date().addingTimeInterval(-86400), startTime: "08:30 PM",
                type: "physical", joinLink: "", location: "NIBM Library",
                latitude: 6.9271, longitude: 79.8612, status: "completed",
                createdBy: "uid1", createdByName: "Kaveena De Silva",
                attendees: ["uid1", "uid2", "uid3", "uid4", "uid5"]
            ),
            group: StudyGroup(
                groupId: "g1", name: "iOS Dev", subject: "iOS Development",
                major: "Computer Science", description: "Test",
                createdBy: "uid1", members: ["uid1"], privacy: "public",
                university: "NIBM", createdAt: Date()
            )
        )
        .environmentObject(AuthViewModel())
    }
}
