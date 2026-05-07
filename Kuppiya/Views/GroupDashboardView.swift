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
    @State private var showAllSessions  = false
    @State private var showAllActivities = false
    @State private var showSettings = false
    @State private var navigateToSessions  = false
    @State private var navigateToChat = false
    @State private var navigateToResources = false
    @State private var navigateToQnA = false
    @State private var navigateToPolls = false
    @State private var navigateToProgress = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection.padding(.top, 16)
                    quickActionsSection.padding(.top, 24).padding(.horizontal, 20)
                    ongoingSessionSection.padding(.top, 28)
                    upcomingSessionsSection.padding(.top, 28)
                    recentActivitiesSection.padding(.top, 28)
                    Spacer(minLength: 140)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToSessions) {
            SessionView(group: group).environmentObject(authVM)
        }
        .navigationDestination(isPresented: $navigateToChat) {
            ChatView(group: group).environmentObject(authVM)
        }
        .navigationDestination(isPresented: $navigateToResources) {
            ResourceView(group: group).environmentObject(authVM)
        }
        .navigationDestination(isPresented: $navigateToQnA) {
            QnAView(group: group).environmentObject(authVM)
        }
        .navigationDestination(isPresented: $navigateToPolls) {
            PollView(group: group).environmentObject(authVM)
        }
        .navigationDestination(isPresented: $navigateToProgress) {
            GroupProgressView(group: group).environmentObject(authVM)
        }
        .sheet(isPresented: $showSettings) {
            GroupSettingsView(group: group).environmentObject(authVM)
        }
        .onChange(of: showSettings) { _, isShowing in
            if !isShowing { Task { await refreshGroup() } }
        }
        .task { await viewModel.loadData(for: group.groupId) }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func refreshGroup() async {
        if let updated = try? await FirestoreService.shared.fetchGroup(groupId: group.groupId) {
            group = updated
        }
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            }

            HStack(spacing: 12) {
                KGroupAvatar(imageURL: group.groupImageURL, name: group.name, size: 46)

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
                        .background(Color(.systemBackground).opacity(0.7))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(hex: "#6B3FD4").opacity(0.1))
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }

    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                QuickActionCard(imageName: "session", label: "Sessions") {
                    navigateToSessions = true
                }
                
                QuickActionCard(imageName: "chat", label: "Chat") {
                    navigateToChat = true
                }
                
                QuickActionCard(imageName: "resource", label: "Resources") {
                    navigateToResources = true
                }
            }
            HStack(spacing: 12) {
                QuickActionCard(imageName: "qna", label: "QnA") {
                    navigateToQnA = true
                }
                
                QuickActionCard(imageName: "poll", label: "Polls") {
                    navigateToPolls = true
                }
                
                QuickActionCard(imageName: "progress", label: "Progress") {
                    navigateToProgress = true
                }
            }
            
        }
        
    }

    // Only shows when a session is currently happening
    private var ongoingSessionSection: some View {
        Group {
            if let ongoing = viewModel.ongoingSession {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ongoing Session")
                        .font(.system(size: 17, weight: .bold))
                        .padding(.horizontal, 20)
                    KSessionCard(session: ongoing) {
                        if let url = URL(string: ongoing.joinLink),
                           !ongoing.joinLink.isEmpty {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    private var upcomingSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sessions")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                if !viewModel.upcomingSessions.isEmpty {
                    Button(showAllSessions ? "Show Less" : "See All") {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showAllSessions.toggle()
                        }
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.brandPrimary)
                }
            }
            .padding(.horizontal, 20)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if viewModel.upcomingSessions.isEmpty {
                emptyCard(icon: "calendar.badge.clock", message: "No upcoming sessions")
            } else if showAllSessions {
                VStack(spacing: 12) {
                    ForEach(viewModel.upcomingSessions) { session in
                        KSessionCard(session: session)
                            .padding(.horizontal, 20)
                    }
                }
            } else {
                KSessionCard(session: viewModel.upcomingSessions[0])
                    .padding(.horizontal, 20)
            }
        }
    }

    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activities")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                if !viewModel.activities.isEmpty {
                    Button(showAllActivities ? "Show Less" : "See All") {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showAllActivities.toggle()
                        }
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.brandPrimary)
                }
            }
            .padding(.horizontal, 20)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if viewModel.activities.isEmpty {
                emptyCard(icon: "clock.arrow.circlepath", message: "No activities yet")
            } else {
                VStack(spacing: 0) {
                    let displayed = showAllActivities
                        ? viewModel.activities
                        : Array(viewModel.activities.prefix(3))

                    ForEach(Array(displayed.enumerated()), id: \.element.id) { index, activity in
                        ActivityRow(activity: activity)
                        if index < displayed.count - 1 {
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

// MARK: - Activity Row

//private struct ActivityRow: View {
//    let activity: Activity
//    @State private var actor: AppUser? = nil
//    private let service = FirestoreService.shared
//
//    var body: some View {
//        HStack(spacing: 12) {
//            KUserAvatar(
//                imageURL: actor?.profileImage.isEmpty == false ? actor?.profileImage : nil,
//                name: actor?.username ?? "?",
//                size: 44
//            )
//            VStack(alignment: .leading, spacing: 3) {
//                Text("\(actor?.username ?? "Someone") \(activity.displayText)")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.primary)
//                    .lineLimit(2)
//                Text("\(activity.timeAgo) • \(activity.type.capitalized)")
//                    .font(.system(size: 12))
//                    .foregroundColor(.secondary)
//            }
//            Spacer()
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//        .task {
//            actor = try? await service.fetchUser(uid: activity.actorId)
//        }
//    }
//}

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
