//
//  GlobalLeaderboardView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import SwiftUI

struct GlobalLeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = GlobalLeaderboardViewModel()

    var body: some View {
        VStack(spacing: 0) {
            navBar

            KSegmentControl(
                options:  ["All Time", "This Week"],
                selected: $vm.selectedTab
            )
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)

            ScrollView(showsIndicators: false) {
                if vm.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else if vm.entries.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "trophy")
                            .font(.system(size: 36))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("No rankings yet")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 16) {
                        if vm.top3.count >= 2 {
                            KPodiumView(
                                entries:    vm.top3,
                                currentUid: authVM.currentUser?.uid ?? "",
                                weeklyMode: vm.selectedTab == 1
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
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .task { await vm.load() }
        .onChange(of: vm.selectedTab) { _, _ in
            Task { await vm.load() }
        }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: { Text(vm.errorMessage) }
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .primary.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            Spacer()
            Text("Global Leaderboard")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemGroupedBackground))
    }

    private var rankList: some View {
        VStack(spacing: 0) {
            ForEach(vm.entries) { entry in
                rankRow(entry)
                if entry.id != vm.entries.last?.id {
                    Divider().padding(.leading, 68)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .primary.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func rankRow(_ entry: LeaderboardEntry) -> some View {
        let isMe = entry.uid == authVM.currentUser?.uid
        let pts  = vm.selectedTab == 0
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
                Text("\(entry.totalPoints) total pts")
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
}
