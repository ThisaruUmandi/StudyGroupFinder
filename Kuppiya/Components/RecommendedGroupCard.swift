//
//  RecommendedGroupCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-25.
//

import SwiftUI

struct RecommendedGroupCard: View {
    let group: StudyGroup
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(group.subject.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "#6B3FD4"))
                        .tracking(0.8)
                        .lineLimit(1)

                    Text(group.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text("\(group.university) • \(group.major)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Arrow — unchanged from original
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 36, height: 36)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(cardColor.opacity(0.07))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    // Color derived from groupId so same group always gets same color
    private var cardColor: Color {
        let colors: [Color] = [
            Color(hex: "#6B3FD4"), // purple
            Color(hex: "#1D9E75"), // green
            Color(hex: "#D85A30"), // orange
            Color(hex: "#378ADD"), // blue
            Color(hex: "#D4537E"), // pink
            Color(hex: "#BA7517"), // amber
            Color(hex: "#0300BF"), // brand blue
            Color(hex: "#0F6E56")  // dark green
        ]
        guard !group.groupId.isEmpty else { return colors[0] }
        return colors[abs(group.groupId.hashValue) % colors.count]
    }
}

#Preview {
    VStack(spacing: 10) {
        RecommendedGroupCard(
            group: StudyGroup(
                groupId: "1",
                name: "Swift Language Review",
                subject: "Mathematics",
                major: "Year 2",
                description: "Test",
                createdBy: "uid",
                members: ["uid"],
                privacy: "public",
                university: "NIBM",
                createdAt: Date()
            ),
            onTap: {}
        )
        RecommendedGroupCard(
            group: StudyGroup(
                groupId: "2",
                name: "iOS Development Hub",
                subject: "Computer Science",
                major: "Final Year",
                description: "Test",
                createdBy: "uid",
                members: ["uid"],
                privacy: "public",
                university: "UoJ",
                createdAt: Date()
            ),
            onTap: {}
        )
        RecommendedGroupCard(
            group: StudyGroup(
                groupId: "3",
                name: "ML learning",
                subject: "Data Science",
                major: "Year 3",
                description: "Test",
                createdBy: "uid",
                members: ["uid"],
                privacy: "private",
                university: "NIBM",
                createdAt: Date()
            ),
            onTap: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
