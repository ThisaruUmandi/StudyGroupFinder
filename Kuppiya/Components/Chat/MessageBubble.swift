//
//  MessageBubble.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import SwiftUI

struct MessageBubble: View {
    let message:    Message
    let currentUid: String
    let onReply:    () -> Void
    let onReact:    () -> Void
    let onDelete:   () -> Void

    @State private var showActions = false

    private var isMe: Bool { message.senderId == currentUid }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {

            // Avatar — others only
            if !isMe {
                KUserAvatar(
                    name: message.senderName,
                    size: 32
                )
            }

            VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {

                // Sender name — others only
                if !isMe {
                    Text(message.senderName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#0300BF"))
                        .padding(.leading, 4)
                }

                // Reply preview
                if let reply = message.replyTo {
                    replyBanner(reply)
                }

                // Bubble
                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundColor(isMe ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isMe
                            ? Color(hex: "#0300BF").opacity(0.5)
                            : Color(UIColor.systemGray6)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .onLongPressGesture {
                        withAnimation(.spring(response: 0.3)) {
                            showActions = true
                        }
                    }
                    .overlay(alignment: isMe ? .bottomLeading : .bottomTrailing) {
                        if showActions {
                            actionMenu
                                .offset(y: 44)
                                .zIndex(10)
                        }
                    }

                // Reactions row
                if !message.activeReactions.isEmpty {
                    reactionsRow
                }

                // Timestamp
                Text(message.timeLabel)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            .frame(
                maxWidth: UIScreen.main.bounds.width * 0.7,
                alignment: isMe ? .trailing : .leading
            )

            if isMe {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: isMe ? .trailing : .leading)
        .onTapGesture {
            if showActions {
                withAnimation { showActions = false }
            }
        }
    }

    // MARK: - Reply Banner
    private func replyBanner(_ reply: ReplyInfo) -> some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(Color(hex: "#0300BF"))
                .frame(width: 3)
                .cornerRadius(2)
            VStack(alignment: .leading, spacing: 2) {
                Text(reply.senderName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "#0300BF"))
                Text(reply.text)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "#0300BF").opacity(0.07))
        )
    }

    // MARK: - Action Menu
    private var actionMenu: some View {
        HStack(spacing: 0) {
            actionButton(icon: "arrowshape.turn.up.left", label: "Reply") {
                showActions = false
                onReply()
            }
            Divider().frame(height: 32)
            actionButton(icon: "face.smiling", label: "React") {
                showActions = false
                onReact()
            }
            if message.senderId == currentUid {
                Divider().frame(height: 32)
                actionButton(
                    icon:  "trash",
                    label: "Delete",
                    color: Color(hex: "#D85A30")
                ) {
                    showActions = false
                    onDelete()
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
    }

    private func actionButton(
        icon: String, label: String,
        color: Color = Color(hex: "#0300BF").opacity(0.5),
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(color)
            }
            .frame(width: 56, height: 44)
        }
    }

    // MARK: - Reactions Row
    private var reactionsRow: some View {
        HStack(spacing: 4) {
            ForEach(message.activeReactions, id: \.emoji) { item in
                Text("\(item.emoji) \(item.count)")
                    .font(.system(size: 12))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(UIColor.systemGray6))
                            .overlay(
                                Capsule().stroke(
                                    message.hasReacted(item.emoji, uid: currentUid)
                                    ? Color(hex: "#0300BF").opacity(0.5)
                                        : Color.clear,
                                    lineWidth: 1.5
                                )
                            )
                    )
            }
        }
    }
}
