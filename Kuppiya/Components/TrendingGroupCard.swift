//
//  TrendingGroupCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-25.
//

import SwiftUI

struct TrendingGroupCard: View {
    let group: StudyGroup
    let onTap: () -> Void

    // Cycle through icon colors like KIconBox
    private var iconColor: Color {
        let colors: [Color] = [
            Color(hex: "#378ADD"),
            Color(hex: "#6B3FD4"),
            Color(hex: "#2EAA6E"),
            Color(hex: "#F5A623"),
            Color(hex: "#D85A30"),
            Color(hex: "#D4537E")
        ]
        guard !group.name.isEmpty else { return colors[0] }
        return colors[abs(group.name.hashValue) % colors.count]
    }

    private var iconName: String {
        let icons = [
            "book.fill",
            "laptopcomputer",
            "flask.fill",
            "function",
            "globe",
            "chart.bar.fill"
        ]
        guard !group.name.isEmpty else { return icons[0] }
        return icons[abs(group.name.hashValue) % icons.count]
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {

                // Icon box — like KIconBox style
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: iconName)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(iconColor)
                }

                // Group name
                Text(group.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Description or subject
                Text(group.description.isEmpty
                     ? group.subject
                     : group.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Bottom row — member avatars + badge
                HStack(spacing: 0) {
                    // Member avatar stack
                    HStack(spacing: -8) {
                        ForEach(
                            Array(group.members.prefix(3)
                                .enumerated()),
                            id: \.offset
                        ) { index, _ in
                            KUserAvatar(
                                name: "\(group.name)\(index)",
                                size: 24
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white,
                                            lineWidth: 1.5)
                            )
                        }
                        if group.members.count > 3 {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white,
                                                    lineWidth: 1.5)
                                    )
                                Text("+\(group.members.count - 3)")
                                    .font(.system(size: 8,
                                                  weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    // Privacy badge
                    Text(group.privacy == "public"
                         ? "PUBLIC" : "PRIVATE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(
                            group.privacy == "public"
                            ? Color(hex: "#6B3FD4")
                            : Color(hex: "#E8143C")
                        )
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            group.privacy == "public"
                            ? Color(hex: "#6B3FD4").opacity(0.12)
                            : Color(hex: "#E8143C").opacity(0.12)
                        )
                        .cornerRadius(20)
                }
            }
            .padding(16)
            .frame(width: 190, height: 210)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.06),
                    radius: 8, x: 0, y: 3)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 14) {
            TrendingGroupCard(
                group: StudyGroup(
                    groupId: "1",
                    name: "Web API",
                    subject: "Web Development",
                    major: "Computer Science",
                    description: "Analyzing 20th century prose and poetic structures.",
                    createdBy: "uid",
                    members: ["1","2","3","4","5"],
                    privacy: "public",
                    university: "NIBM",
                    createdAt: Date()
                ),
                onTap: {}
            )
            TrendingGroupCard(
                group: StudyGroup(
                    groupId: "2",
                    name: "PDSA",
                    subject: "Computer Science",
                    major: "Computer Science",
                    description: "Logic, sets, and problem solving.",
                    createdBy: "uid",
                    members: ["1","2"],
                    privacy: "private",
                    university: "NIBM",
                    createdAt: Date()
                ),
                onTap: {}
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
