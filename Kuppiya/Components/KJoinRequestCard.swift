//
//  KJoinRequestCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct KJoinRequestCard: View {
    let request: JoinRequest
    let onApprove: () -> Void
    let onReject: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            // User avatar
            KUserAvatar(
                name: request.senderName,
                size: 42
            )

            // Name + group info
            VStack(alignment: .leading, spacing: 2) {
                Text(request.senderName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text("Requested to join \(request.groupName)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()

            // Reject button
            Button(action: onReject) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#D4537E").opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "#D4537E"))
                }
            }

            // Approve button
            Button(action: onApprove) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#1D9E75").opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "#1D9E75"))
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04),
                radius: 6, x: 0, y: 2)
    }
}
