//
//  KSessionCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct KSessionCard: View {
    let session: StudySession
    var onJoinTap: (() -> Void)? = nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(hex: "#5B3FBF"))

            VStack(alignment: .leading, spacing: 10) {

                // MARK: Tags row — from Firestore data
                HStack(spacing: 8) {
                    KTagPill(text: "NEXT SESSION")
                    KTagPill(
                        text: session.groupName
                            .prefix(4)
                            .uppercased()
                    )
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 14))
                }

                // MARK: Title — from Firestore
                Text(session.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                // MARK: Group name + type — from Firestore
                Text(
                    "\(session.groupName.uppercased()) · \(session.type.uppercased())"
                )
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .tracking(1)

                // MARK: Time + Join button — from Firestore
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 13))
                        // formattedDateTime uses date + startTime from Firestore
                        Text(session.formattedDateTime)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    Button {
                        onJoinTap?()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Join Now")
                                .font(.system(
                                    size: 13,
                                    weight: .bold))
                                .foregroundColor(
                                    Color(hex: "#5B3FBF"))
                            Image(systemName: "arrow.right")
                                .font(.system(
                                    size: 11,
                                    weight: .bold))
                                .foregroundColor(
                                    Color(hex: "#5B3FBF"))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Color.white)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(18)
        }
    }
}

// MARK: - Tag Pill
struct KTagPill: View {
    let text: String
    var bgColor: Color   = Color.white.opacity(0.2)
    var textColor: Color = .white

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(bgColor)
            .cornerRadius(20)
    }
}

// MARK: - Empty card
struct KEmptySessionCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(hex: "#5B3FBF").opacity(0.08))
                .frame(height: 90)
            Text("No upcoming sessions")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    KSessionCard(session: StudySession(
        sessionId: "123",
        groupId: "abc",
        groupName: "iOS Dev",
        title: "Advanced Mathematics",
        description: "Test",
        date: Date().addingTimeInterval(86400),
        startTime: "16:30",
        type: "online",
        joinLink: "",
        location: "",
        latitude: 0,
        longitude: 0,
        status: "upcoming",
        createdBy: "uid",
        createdByName: "Kaveen",
        attendees: []
    ))
    .padding()
}
