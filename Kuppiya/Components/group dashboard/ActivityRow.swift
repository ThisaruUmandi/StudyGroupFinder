//
//  ActivityRow.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-01.
//


import SwiftUI

struct ActivityRow: View {
    let activity: Activity
    @State private var actor: AppUser? = nil
    private let service = FirestoreService.shared

    var body: some View {
        HStack(spacing: 12) {
            KUserAvatar(
                imageURL: actor?.profileImage.isEmpty == false ? actor?.profileImage : nil,
                name: actor?.username ?? "?",
                size: 44
            )
            VStack(alignment: .leading, spacing: 3) {
                Text("\(actor?.username ?? "Someone") \(activity.displayText)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Text("\(activity.timeAgo) • \(activity.type.capitalized)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .task {
            actor = try? await service.fetchUser(uid: activity.actorId)
        }
    }
}
#Preview {
    ActivityRow(activity: Activity(
        id: "1",
        actorId: "uid1",
        action: "created a session",
        target: "Advanced iOS",
        type: "session",
        createdAt: Date()
    ))
    .padding()
}
