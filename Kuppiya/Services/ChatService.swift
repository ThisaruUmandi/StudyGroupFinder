//
//  ChatService.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ChatService {
    static let shared = ChatService()
    private let db = Firestore.firestore()

    private func ref(groupId: String) -> CollectionReference {
        db.collection("studyGroups")
          .document(groupId)
          .collection("messages")
    }

    // MARK: - Real-time listener
    func listen(
        groupId: String,
        onUpdate: @escaping ([Message]) -> Void
    ) -> ListenerRegistration {
        ref(groupId: groupId)
            .order(by: "createdAt", descending: false)
            .limit(toLast: 100)
            .addSnapshotListener { snap, _ in
                guard let docs = snap?.documents else { return }
                let uid = Auth.auth().currentUser?.uid ?? ""

                print("Current UID: \(uid)")

                let messages = docs.compactMap { doc -> Message? in
                    guard var msg = try? doc.data(as: Message.self) else { return nil }
                    print("Message senderId: \(msg.senderId) | isMe: \(msg.senderId == uid)")
                    msg.isMe = msg.senderId == uid
                    return msg
                }
                onUpdate(messages)
            }
    }

    // MARK: - Send message
    func send(
        groupId: String,
        text:    String,
        replyTo: ReplyInfo? = nil
    ) async throws {
        guard let user = Auth.auth().currentUser else { return }
        let msgId = UUID().uuidString

        // Fetch username from Firestore
        let userDoc  = try await db
            .collection("users")
            .document(user.uid)
            .getDocument()
        let username = userDoc.data()?["username"] as? String ?? "Unknown"

        var data: [String: Any] = [
            "messageId":  msgId,
            "senderId":   user.uid,
            "senderName": username,
            "text":       text.trimmingCharacters(in: .whitespacesAndNewlines),
            "createdAt":  Timestamp(date: Date()),
            "reactions":  [String: [String]]()
        ]

        if let reply = replyTo {
            data["replyTo"] = [
                "messageId":  reply.messageId,
                "senderName": reply.senderName,
                "text":       reply.text
            ]
        }

        try await ref(groupId: groupId)
            .document(msgId)
            .setData(data)
    }

    // MARK: - Toggle reaction
    func toggleReaction(
        groupId:   String,
        messageId: String,
        emoji:     String,
        uid:       String
    ) async throws {
        let ref  = ref(groupId: groupId).document(messageId)
        let snap = try await ref.getDocument()
        var reactions = snap.data()?["reactions"] as? [String: [String]] ?? [:]

        var users = reactions[emoji] ?? []
        if users.contains(uid) {
            users.removeAll { $0 == uid }
        } else {
            users.append(uid)
        }

        if users.isEmpty {
            reactions.removeValue(forKey: emoji)
        } else {
            reactions[emoji] = users
        }

        try await ref.updateData(["reactions": reactions])
    }

    // MARK: - Delete message
    func delete(groupId: String, messageId: String) async throws {
        try await ref(groupId: groupId).document(messageId).delete()
    }
}
