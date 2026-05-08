//
//  KPodiumView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import SwiftUI

struct KPodiumView: View {
    let entries: [LeaderboardEntry]
    let currentUid: String
    let weeklyMode: Bool

    private var first:  LeaderboardEntry? { entries.count > 0 ? entries[0] : nil }
    private var second: LeaderboardEntry? { entries.count > 1 ? entries[1] : nil }
    private var third:  LeaderboardEntry? { entries.count > 2 ? entries[2] : nil }

    var body: some View {
        ZStack {
            // Blue radial glow behind #1
            if first != nil {
                RadialGradient(
                    colors: [Color(hex: "#0300BF").opacity(0.2), .clear],
                    center: .center,
                    startRadius: 10,
                    endRadius: 110
                )
                .frame(width: 240, height: 240)
                .offset(y: -10)
            }

            HStack(alignment: .bottom, spacing: 0) {
                // 2nd place
                if let second {
                    KPodiumAvatar(
                        entry: second,
                        rankNum: 2,
                        size: 72,
                        isFirst: false,
                        currentUid: currentUid,
                        weeklyMode: weeklyMode
                    )
                    .offset(y: 24)
                }

                // 1st place
                if let first {
                    KPodiumAvatar(
                        entry: first,
                        rankNum: 1,
                        size: 96,
                        isFirst: true,
                        currentUid: currentUid,
                        weeklyMode: weeklyMode
                    )
                }

                // 3rd place
                if let third {
                    KPodiumAvatar(
                        entry: third,
                        rankNum: 3,
                        size: 72,
                        isFirst: false,
                        currentUid: currentUid,
                        weeklyMode: weeklyMode
                    )
                    .offset(y: 24)
                }
            }
        }
        .frame(height: 210)
        .padding(.vertical, 8)
    }
}

// MARK: - Single Podium Avatar

struct KPodiumAvatar: View {
    let entry: LeaderboardEntry
    let rankNum: Int
    let size: CGFloat
    let isFirst: Bool
    let currentUid: String
    let weeklyMode: Bool

    private var isMe: Bool { entry.uid == currentUid }

    private var rankColor: Color {
        switch rankNum {
        case 1:  return Color(hex: "#0300BF")
        case 2:  return Color(.systemGray3)
        default: return Color(hex: "#CD7F32")
        }
    }

    private var pts: Int {
        weeklyMode ? entry.weeklyPoints : entry.totalPoints
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                // Sparkles for #1
                if isFirst {
                    sparkles
                }

                // Avatar with white ring
                KUserAvatar(
                    imageURL: entry.profileImage.isEmpty ? nil : entry.profileImage,
                    name: entry.username,
                    size: size
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isFirst ? 4 : 3)
                        .shadow(
                            color: isFirst
                                ? Color(hex: "#0300BF").opacity(0.3)
                                : .black.opacity(0.1),
                            radius: isFirst ? 8 : 4,
                            x: 0, y: 2
                        )
                )

                // Rank bubble
                Text("\(rankNum)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(rankColor)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(y: 13)
            }
            .padding(.bottom, 13)

            // Name
            Text(entry.username)
                .font(.system(size: isFirst ? 14 : 12, weight: isMe ? .bold : .semibold))
                .foregroundColor(isMe ? Color(hex: "#0300BF") : .primary)
                .lineLimit(1)

            // Points
            Text("\(pts) pts")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sparkles
    private var sparkles: some View {
        ZStack {
            Image(systemName: "sparkle")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "#0300BF"))
                .offset(x: -32, y: -18)
            Image(systemName: "sparkle")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "#0300BF"))
                .offset(x: 28, y: -32)
            Image(systemName: "sparkle")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "#0300BF"))
                .offset(x: 40, y: -6)
            Image(systemName: "sparkle")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color(hex: "#0300BF"))
                .offset(x: -40, y: -4)
        }
    }
}

// MARK: - Preview
#Preview {
    KPodiumView(
        entries: [
            LeaderboardEntry(uid: "1", username: "Claire",  profileImage: "", totalPoints: 500, weeklyPoints: 120, rank: 1),
            LeaderboardEntry(uid: "2", username: "Irma",    profileImage: "", totalPoints: 300, weeklyPoints: 80,  rank: 2),
            LeaderboardEntry(uid: "3", username: "Bessie",  profileImage: "", totalPoints: 200, weeklyPoints: 60,  rank: 3)
        ],
        currentUid: "1",
        weeklyMode: false
    )
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
