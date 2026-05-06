//
//  ProgressView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-24.
//

import SwiftUI

struct GroupProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM:     AuthViewModel
    @EnvironmentObject var tabManager: TabBarViewModel

    @StateObject private var progressVM    = StudyProgressViewModel()
    @StateObject private var leaderboardVM = GroupLeaderboardViewModel()

    @State private var selectedTab = 0

    let group: StudyGroup

    var body: some View {
        VStack(spacing: 0) {
            tabToggle
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 4)

            if selectedTab == 0 {
                myProgressTab
                    .transition(.opacity)
            } else {
                leaderboardTab
                    .transition(.opacity)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .safeAreaInset(edge: .top) {
            navBar.background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .onAppear { tabManager.isTabBarHidden = true  }
        .onDisappear { tabManager.isTabBarHidden = false }
        .task {
            guard let uid = authVM.currentUser?.uid else { return }
            async let p: () = progressVM.load(uid: uid, groupId: group.groupId)
            async let l: () = leaderboardVM.load(groupId: group.groupId)
            _ = await (p, l)
        }
        .onChange(of: leaderboardVM.selectedTab) { _, _ in
            Task { await leaderboardVM.load(groupId: group.groupId) }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
        .sheet(isPresented: $progressVM.showGoalSheet) {
            GoalSetterSheet(
                currentGoal: progressVM.stat?.weeklyGoalHours ?? 3.0
            ) { newGoal in
                Task {
                    guard let uid = authVM.currentUser?.uid else { return }
                    await progressVM.updateGoal(
                        uid:     uid,
                        groupId: group.groupId,
                        hours:   newGoal
                    )
                }
            }
        }
        .alert("Error", isPresented: $progressVM.showError) {
            Button("OK", role: .cancel) {}
        } message: { Text(progressVM.errorMessage) }
    }

    // MARK: - Nav Bar
    private var navBar: some View {
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
            Text("Progress")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            if selectedTab == 0 {
                Button { progressVM.showGoalSheet = true } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                }
            } else {
                Color.clear.frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Tab Toggle
    private var tabToggle: some View {
        KSegmentControl(
            options:  ["My Progress", "Leaderboard"],
            selected: $selectedTab
        )
    }

    // MARK: - My Progress Tab
    private var myProgressTab: some View {
        ScrollView(showsIndicators: false) {
            if progressVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            } else if let s = progressVM.stat {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        streakCard(s)
                        weeklyGoalCard(s)
                    }
                    .padding(.horizontal, 20)

                    pointsCard(s)
                        .padding(.horizontal, 20)

                    studyStatsCard(s)
                        .padding(.horizontal, 20)

                    activityCard(s)
                        .padding(.horizontal, 20)

                    performanceCard(s)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
                .padding(.top, 12)
            } else {
                emptyState.padding(.top, 60)
            }
        }
    }

    // MARK: - Streak Card
    private func streakCard(_ s: GroupStat) -> some View {
        VStack(spacing: 6) {
            Text("🔥")
                .font(.system(size: 36))
            Text("\(s.currentStreak)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: "#0300BF"))
            Text("Day Streak")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Text("Best: \(s.longestStreak) days")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Weekly Goal Card
    private func weeklyGoalCard(_ s: GroupStat) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 10)
                    .frame(width: 80, height: 80)
                Circle()
                    .trim(from: 0, to: CGFloat(s.weeklyGoalProgress))
                    .stroke(
                        Color(hex: "#0300BF"),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: s.weeklyGoalProgress)
                Text("\(s.weeklyGoalPct)%")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
            }
            Text("Weekly Goal")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
            Text(String(format: "%.1fh / %.0fh",
                        s.weeklyStudyHours, s.weeklyGoalHours))
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Points Card
    private func pointsCard(_ s: GroupStat) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Total Points")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(s.totalPoints) pts")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#0300BF"))
            }
            HStack(spacing: 8) {
                pointsPillar(label: "Q&A",     value: s.qnaPoints,     color: Color(hex: "#0300BF"))
                pointsPillar(label: "Polls",    value: s.pollPoints,    color: Color(hex: "#1D9E75"))
                pointsPillar(label: "Sessions", value: s.sessionPoints, color: Color(hex: "#D85A30"))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func pointsPillar(label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.06))
        .cornerRadius(12)
    }

    // MARK: - Study Stats Card
    private func studyStatsCard(_ s: GroupStat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("STUDY STATS")
            HStack(spacing: 0) {
                statItem(
                    icon:  "clock.fill",
                    color: Color(hex: "#0300BF"),
                    value: String(format: "%.1fh", s.totalStudyHours),
                    label: "Study Hours"
                )
                Divider().frame(height: 40)
                statItem(
                    icon:  "checkmark.circle.fill",
                    color: Color(hex: "#1D9E75"),
                    value: "\(s.sessionsAttended)",
                    label: "Sessions"
                )
                Divider().frame(height: 40)
                statItem(
                    icon:  "person.2.fill",
                    color: Color(hex: "#D85A30"),
                    value: "\(s.attendancePct)%",
                    label: "Attendance"
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func statItem(
        icon: String, color: Color, value: String, label: String
    ) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Weekly Activity Chart
    private func activityCard(_ s: GroupStat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("WEEKLY ACTIVITY")

            let days   = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
            let values = days.map { s.weeklyActivity[$0] ?? 0 }
            let maxVal = values.max() ?? 1

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(days.indices, id: \.self) { i in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                values[i] > 0
                                    ? Color(hex: "#0300BF")
                                    : Color(.systemGray5)
                            )
                            .frame(height: max(8,
                                CGFloat(values[i] / max(maxVal, 0.1)) * 60
                            ))
                            .animation(.easeInOut(duration: 0.6), value: values[i])
                        Text(String(days[i].prefix(1)))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 80)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Performance Card
    private func performanceCard(_ s: GroupStat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("PERFORMANCE")
            VStack(spacing: 10) {
                performanceRow(
                    icon:   "checkmark.seal.fill",
                    color:  Color(hex: "#1D9E75"),
                    label:  "Poll Accuracy",
                    value:  "\(s.pollAccuracyPct)%",
                    detail: "\(s.totalCorrect)/\(s.totalPollsVoted) correct"
                )
                Divider()
                performanceRow(
                    icon:   "bubble.left.fill",
                    color:  Color(hex: "#0300BF"),
                    label:  "Answers Given",
                    value:  "\(s.totalAnswers)",
                    detail: "\(s.bestAnswers) best answers ⭐️"
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func performanceRow(
        icon: String, color: Color,
        label: String, value: String, detail: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
        }
    }

    // MARK: - Leaderboard Tab
    private var leaderboardTab: some View {
        VStack(spacing: 0) {
            KSegmentControl(
                options:  ["All Time", "This Week"],
                selected: $leaderboardVM.selectedTab
            )
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)

            ScrollView(showsIndicators: false) {
                if leaderboardVM.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else if leaderboardVM.entries.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "trophy")
                            .font(.system(size: 36))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("No rankings yet")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text("Start participating to appear here!")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 16) {
                        if leaderboardVM.top3.count >= 2 {
                            KPodiumView(
                                entries:    leaderboardVM.top3,
                                currentUid: authVM.currentUser?.uid ?? "",
                                weeklyMode: leaderboardVM.selectedTab == 1
                            )
                            .padding(.top, 8)
                        }
                        rankList
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
    }

    // MARK: - Rank List
    private var rankList: some View {
        VStack(spacing: 0) {
            ForEach(leaderboardVM.entries) { entry in
                rankRow(entry)
                if entry.id != leaderboardVM.entries.last?.id {
                    Divider().padding(.leading, 68)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func rankRow(_ entry: LeaderboardEntry) -> some View {
        let isMe = entry.uid == authVM.currentUser?.uid
        let pts  = leaderboardVM.selectedTab == 0
                   ? entry.totalPoints
                   : entry.weeklyPoints

        return HStack(spacing: 12) {
            Text("#\(entry.rank)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(entry.rank <= 3 ? Color(hex: "#0300BF") : .secondary)
                .frame(width: 32, alignment: .leading)

            KUserAvatar(
                imageURL: entry.profileImage.isEmpty ? nil : entry.profileImage,
                name:     entry.username,
                size:     36
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(entry.username)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    if isMe {
                        Text("You")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#0300BF"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "#0300BF").opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                Text("\(entry.qnaPoints) Q&A · \(entry.pollPoints) Poll · \(entry.sessionPoints) Session")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(pts)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "#0300BF"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isMe ? Color(hex: "#0300BF").opacity(0.04) : Color.clear)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 36))
                .foregroundColor(.gray.opacity(0.3))
            Text("No progress data yet")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Text("Attend sessions, vote on polls and answer questions!")
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        GroupProgressView(group: StudyGroup(
            groupId:     "g1",
            name:        "iOS Dev",
            subject:     "iOS Development",
            major:       "Computer Science",
            description: "Test",
            createdBy:   "uid1",
            members:     ["uid1"],
            privacy:     "public",
            university:  "NIBM",
            createdAt:   Date()
        ))
        .environmentObject(AuthViewModel())
        .environmentObject(TabBarViewModel())
    }
}
