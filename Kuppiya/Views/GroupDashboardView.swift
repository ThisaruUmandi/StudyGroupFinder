//
//  GroupDashboardView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct GroupDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = GroupDashboardViewModel()

    @State var group: StudyGroup

    @State private var showSettings        = false
    @State private var navigateToSessions  = false
    @State private var navigateToChat      = false
    @State private var navigateToResources = false
    @State private var navigateToQnA       = false
    @State private var navigateToPolls     = false
    @State private var navigateToProgress  = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    headerSection
                        .padding(.top, 16)

                    quickActionsSection
                        .padding(.top, 24)
                        .padding(.horizontal, 20)

                    upcomingSessionsSection
                        .padding(.top, 28)

                    recentActivitiesSection
                        .padding(.top, 28)

                    Spacer(minLength: 140)
                }
            }

            // Bottom — mascot + FAB
//            HStack(alignment: .bottom, spacing: 0) {
//                Image("oboy_r")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 90)
//                    .padding(.bottom, 8)
//                    .allowsHitTesting(false)
//
//                Spacer()

//                Button {
//                    navigateToChat = true
//                } label: {
//                    HStack(spacing: 8) {
//                        Image(systemName: "plus.circle.fill")
//                            .font(.system(size: 18))
//                        Text("New Message")
//                            .font(.system(size: 15, weight: .semibold))
//                    }
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 14)
//                    .background(Color(hex: "#1A1ADB"))
//                    .clipShape(Capsule())
//                    .shadow(
//                        color: Color(hex: "#1A1ADB").opacity(0.35),
//                        radius: 10, x: 0, y: 5
//                    )
//                }
//                .padding(.bottom, 24)
//                .padding(.trailing, 20)
            //}
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToSessions) {
            SessionView(group: group)
                .environmentObject(authVM)
        }
        .navigationDestination(isPresented: $navigateToChat) {
            ChatView(group: group)
                .environmentObject(authVM)
        }
        .navigationDestination(isPresented: $navigateToResources) {
            ResourceView(group: group)
                .environmentObject(authVM)
        }
        .navigationDestination(isPresented: $navigateToQnA) {
            QnAView(group: group)
                .environmentObject(authVM)
        }
        .navigationDestination(isPresented: $navigateToPolls) {
            PollView(group: group)
                .environmentObject(authVM)
        }
        .navigationDestination(isPresented: $navigateToProgress) {
            GroupProgressView(group: group)
                .environmentObject(authVM)
        }
        .sheet(isPresented: $showSettings) {
            GroupSettingsView(group: group)
                .environmentObject(authVM)
        }
        // ← Refresh group data when settings sheet closes
        .onChange(of: showSettings) { _, isShowing in
            if !isShowing {
                Task { await refreshGroup() }
            }
        }
        .task {
            await viewModel.loadData(for: group.groupId)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Refresh group
    private func refreshGroup() async {
        if let updated = try? await FirestoreService.shared
            .fetchGroup(groupId: group.groupId) {
            group = updated
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06),
                            radius: 4, x: 0, y: 2)
            }

            HStack(spacing: 12) {
                KGroupAvatar(
                    imageURL: group.groupImageURL,
                    name: group.name,
                    size: 46
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(group.subject.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .tracking(0.5)
                        .lineLimit(1)
                }

                Spacer()

                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.7))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(hex: "#EDE7FF"))
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            // Row 1
            HStack(spacing: 12) {
                QuickActionCard(imageName: "session",
                                label: "Sessions") {
                    navigateToSessions = true
                }
                QuickActionCard(imageName: "chat",
                                label: "Chat") {
                    navigateToChat = true
                }
                QuickActionCard(imageName: "resource",
                                label: "Resources") {
                    navigateToResources = true
                }
            }
            // Row 2
            HStack(spacing: 12) {
                QuickActionCard(imageName: "qna",
                                label: "QnA") {
                    navigateToQnA = true
                }
                QuickActionCard(imageName: "poll",
                                label: "Polls") {
                    navigateToPolls = true
                }
                QuickActionCard(imageName: "progress",
                                label: "Progress") {
                    navigateToProgress = true
                }
            }
        }
    }

    // MARK: - Upcoming Sessions
    private var upcomingSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Sessions")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                if !viewModel.upcomingSessions.isEmpty {
                    Button("See All") {
                        navigateToSessions = true
                    }
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#1A1ADB"))
                }
            }
            .padding(.horizontal, 20)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if viewModel.upcomingSessions.isEmpty {
                emptyCard(
                    icon: "calendar.badge.clock",
                    message: "No upcoming sessions"
                )
            } else {
                KSessionCard(session: viewModel.upcomingSessions[0])
                    .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Recent Activities
    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activities")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                if !viewModel.activities.isEmpty {
                    Button("See All") { }
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#1A1ADB"))
                }
            }
            .padding(.horizontal, 20)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if viewModel.activities.isEmpty {
                emptyCard(
                    icon: "clock.arrow.circlepath",
                    message: "No activities yet"
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(
                        Array(viewModel.activities.enumerated()),
                        id: \.element.id
                    ) { index, activity in
                        ActivityRow(activity: activity)
                        if index < viewModel.activities.count - 1 {
                            Divider().padding(.leading, 72)
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Empty card
    private func emptyCard(icon: String, message: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.gray.opacity(0.35))
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 36)
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Quick Action Card
private struct QuickActionCard: View {
    let imageName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04),
                    radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Activity Row
private struct ActivityRow: View {
    let activity: Activity
    @State private var actor: AppUser? = nil
    private let service = FirestoreService.shared

    var body: some View {
        HStack(spacing: 12) {
            KUserAvatar(
                imageURL: actor?.profileImage.isEmpty == false
                    ? actor?.profileImage : nil,
                name: actor?.username ?? "?",
                size: 44
            )
            VStack(alignment: .leading, spacing: 3) {
                Text("\(actor?.username ?? "Someone") \(activity.displayText)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Text("\(activity.timeAgo) • \(activity.type.capitalized)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .task {
            actor = try? await service.fetchUser(uid: activity.actorId)
        }
    }
}

#Preview {
    NavigationStack {
        GroupDashboardView(group: StudyGroup(
            groupId: "preview",
            name: "iOS Dev",
            subject: "iOS Application Development",
            major: "Computer Science",
            description: "Test group",
            createdBy: "uid",
            members: ["uid"],
            privacy: "public",
            university: "NIBM",
            createdAt: Date()
        ))
        .environmentObject(AuthViewModel())
    }
}
