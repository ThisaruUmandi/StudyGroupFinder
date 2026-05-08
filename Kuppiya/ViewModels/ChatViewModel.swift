//
//  ChatViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message]  = []
    @Published var inputText: String     = ""
    @Published var replyingTo: Message?   = nil
    @Published var showReactions: Message?   = nil
    @Published var isLoading: Bool = true
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    private let service = ChatService.shared
    private var listener: ListenerRegistration?
    var currentUid: String { Auth.auth().currentUser?.uid ?? "" }

    // MARK: - Grouped messages for date separators
    struct DayGroup: Identifiable {
        var id: String // date label
        var label: String
        var messages: [Message]
    }

    var groupedMessages: [DayGroup] {
        var groups: [String: [Message]] = [:]
        var order: [String] = []

        for msg in messages {
            let label = msg.dateSeparatorLabel
            if groups[label] == nil {
                groups[label] = []
                order.append(label)
            }
            groups[label]?.append(msg)
        }

        return order.map { label in
            DayGroup(id: label, label: label, messages: groups[label] ?? [])
        }
    }

    // MARK: - Start listening
    func startListening(groupId: String) {
        isLoading = true
        listener  = service.listen(groupId: groupId) { [weak self] msgs in
            self?.messages  = msgs
            self?.isLoading = false
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - Send
    func send(groupId: String) async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let reply = replyingTo.map {
            ReplyInfo(
                messageId: $0.messageId,
                senderName: $0.senderName,
                text: $0.text
            )
        }

        inputText  = ""
        replyingTo = nil

        do {
            try await service.send(
                groupId: groupId,
                text: text,
                replyTo: reply
            )
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - React
    func toggleReaction(groupId: String, message: Message, emoji: String) async {
        guard let msgId = message.id else { return }
        do {
            try await service.toggleReaction(
                groupId: groupId,
                messageId: msgId,
                emoji: emoji,
                uid: currentUid
            )
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        showReactions = nil
    }

    // MARK: - Delete
    func delete(groupId: String, message: Message) async {
        guard let msgId = message.id else { return }
        do {
            try await service.delete(groupId: groupId, messageId: msgId)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Reply
    func startReply(to message: Message) {
        replyingTo = message
    }

    func cancelReply() {
        replyingTo = nil
    }
}
