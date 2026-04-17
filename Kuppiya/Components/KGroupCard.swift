//
//  KGroupCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct KGroupCard: View {
    let group: StudyGroup
    var sessionCount: Int = 0
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {

                // Group avatar
                KUserAvatar(
                    name: group.name,
                    size: 52
                )

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        // Member count
                        HStack(spacing: 3) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Text("\(group.memberCount) members")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }

                        Text("·")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))

                        // Session count
                        HStack(spacing: 3) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            Text("\(sessionCount) sessions this week")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04),
                    radius: 6, x: 0, y: 2)
        }
    }
}

#Preview {
    KGroupCard(
        group: StudyGroup(
            groupId: "1",
            name: "iOS App Dev",
            subject: "iOS",
            major: "Computer Science",
            description: "iOS study group",
            createdBy: "uid",
            members: ["1","2","3","4","5","6","7","8"],
            privacy: "public",
            //mode: "online",
            university: "NIBM",
            createdAt: Date()
        ),
        sessionCount: 3
    )
    .padding()
}
