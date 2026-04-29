//
//  SessionView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-27.
//

import SwiftUI

struct SessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = SessionViewModel()

    @State private var showFilterMenu  = false
    @State private var showCreateSheet = false
    @State private var selectedSession: StudySession?

    let group: StudyGroup

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    // Ongoing session — shows in purple KSessionCard
                    if let ongoing = viewModel.todaySession {
                        KSessionCard(session: ongoing) { }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                    }

                    segmentAndFilter
                        .padding(.top, 24)
                        .padding(.horizontal, 20)

                    sessionList.padding(.top, 16)

                    Spacer(minLength: 100)
                }
                .padding(.top, 16)
            }

            // Any member can create a session
            Button { showCreateSheet = true } label: {
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
        .navigationDestination(item: $selectedSession) { session in
            SessionDetailView(session: session)
        }
        .navigationDestination(isPresented: $showCreateSheet) {
            CreateSessionView(group: group).environmentObject(authVM)
        }
        .task { await viewModel.load(for: group.groupId) }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var header: some View {
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
            Text("Sessions")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
//            Image("oboy_r")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 54)
//                .offset(y: -6)
        }
        .padding(.horizontal, 20)
    }

    private var segmentAndFilter: some View {
        HStack() {
            KSegmentControl(
                options: ["Upcoming", "Past Sessions"],
                selected: Binding(
                    get: { viewModel.showingPastSessions ? 1 : 0 },
                    set: { viewModel.showingPastSessions = $0 == 1 }
                )
            )
            Spacer()
            Button { showFilterMenu.toggle() } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .frame(width: 42, height: 42)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            .popover(isPresented: $showFilterMenu) {
                filterMenu.presentationCompactAdaptation(.popover)
            }
        }
    }

    private var filterMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(SessionViewModel.SessionFilter.allCases, id: \.self) { filter in
                Button {
                    viewModel.selectedFilter = filter
                    showFilterMenu = false
                } label: {
                    HStack {
                        Text(filter.rawValue)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                        Spacer()
                        if viewModel.selectedFilter == filter {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#0300BF"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                }
                if filter != .physical {
                    Divider().padding(.leading, 16)
                }
            }
        }
        .frame(width: 160)
    }

    private var sessionList: some View {
        Group {
            if viewModel.displayedSessions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: viewModel.showingPastSessions
                              ? "clock.arrow.circlepath" : "calendar.badge.clock")
                            .font(.system(size: 32))
                            .foregroundColor(.gray.opacity(0.35))
                        Text(viewModel.showingPastSessions
                             ? "No past sessions" : "No upcoming sessions")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 40)
                    Spacer()
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.displayedSessions) { session in
                        SessionListCard(session: session) {
                            selectedSession = session
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Session list card

private struct SessionListCard: View {
    let session: StudySession
    let onTap: () -> Void

    private var cardBg: Color {
        session.isOnline ? Color(hex: "#FFF8E8") : Color(hex: "#E8F5EE")
    }

    private var tagColor: Color {
        session.isOnline ? Color(hex: "#BA7517") : Color(hex: "#1D9E75")
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(session.isOnline ? "ONLINE" : "PHYSICAL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(tagColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(tagColor.opacity(0.12))
                    .cornerRadius(4)

                Text(session.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)

                HStack(spacing: 10) {
                    Label {
                        Text(shortDate(session.date))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    Label {
                        Text(session.startTime)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    if session.isPhysical && !session.location.isEmpty {
                        Label {
                            Text(session.location)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        } icon: {
                            Image(systemName: "mappin")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Spacer()

            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 36, height: 36)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(cardBg)
        .cornerRadius(16)
    }

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

#Preview {
    NavigationStack {
        SessionView(group: StudyGroup(
            groupId: "preview",
            name: "iOS Dev",
            subject: "iOS Development",
            major: "Computer Science",
            description: "Test",
            createdBy: "uid1",
            members: ["uid1"],
            privacy: "public",
            university: "NIBM",
            createdAt: Date()
        ))
        .environmentObject(AuthViewModel())
    }
}
