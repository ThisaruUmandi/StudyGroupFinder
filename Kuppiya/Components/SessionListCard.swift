//
//  SessionListCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-01.
//

import SwiftUI

struct SessionListCard: View {
    let session: StudySession
    let group: StudyGroup
    let onTap: () -> Void

    private var cardBg: Color {
        session.isOnline
            ? Color(hex: "#BA7517").opacity(0.12)
            : Color(hex: "#1D9E75").opacity(0.12)
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
    VStack(spacing: 12) {
        SessionListCard(
            session: StudySession(
                sessionId: "1",
                groupId: "g1",
                groupName: "iOS Dev",
                title: "Advanced iOS Development",
                description: "Test",
                date: Date().addingTimeInterval(86400),
                startTime: "16:30",
                type: "online",
                joinLink: "https://meet.google.com",
                location: "",
                latitude: 0,
                longitude: 0,
                status: "upcoming",
                createdBy: "uid1",
                createdByName: "Kaveen",
                attendees: []
            ),
            group: StudyGroup(
                groupId: "g1",
                name: "iOS Dev",
                subject: "iOS Development",
                major: "Computer Science",
                description: "Test",
                createdBy: "uid1",
                members: ["uid1"],
                privacy: "public",
                university: "NIBM",
                createdAt: Date()
            ),
            onTap: {}
        )

        SessionListCard(
            session: StudySession(
                sessionId: "2",
                groupId: "g1",
                groupName: "Math Study",
                title: "Calculus Review",
                description: "Test",
                date: Date().addingTimeInterval(172800),
                startTime: "14:00",
                type: "physical",
                joinLink: "",
                location: "NIBM Library",
                latitude: 6.9271,
                longitude: 79.8612,
                status: "upcoming",
                createdBy: "uid1",
                createdByName: "Umandi",
                attendees: []
            ),
            group: StudyGroup(
                groupId: "g1",
                name: "iOS Dev",
                subject: "iOS Development",
                major: "Computer Science",
                description: "Test",
                createdBy: "uid1",
                members: ["uid1"],
                privacy: "public",
                university: "NIBM",
                createdAt: Date()
            ),
            onTap: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
