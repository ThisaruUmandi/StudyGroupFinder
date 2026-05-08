//
//  ChatView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-22.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM:     AuthViewModel
    @EnvironmentObject var tabManager: TabBarViewModel
    @StateObject private var vm = ChatViewModel()

    let group: StudyGroup

    @State private var showReactionPicker = false
    @State private var reactingTo:   Message? = nil
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ZStack(alignment: .bottom) {
                let groupId = group.groupId

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.groupedMessages) { dayGroup in
                                dateSeparator(dayGroup.label)

                                ForEach(dayGroup.messages) { msg in
                                    MessageBubble(
                                        message:    msg,
                                        currentUid: vm.currentUid,
                                        onReply: {
                                            vm.startReply(to: msg)
                                            inputFocused = true
                                        },
                                        onReact: {
                                            reactingTo         = msg
                                            showReactionPicker = true
                                        },
                                        onDelete: {
                                            Task {
                                                await vm.delete(
                                                    groupId: groupId,
                                                    message: msg
                                                )
                                            }
                                        }
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                    .id(msg.messageId)
                                }
                            }
                            Color.clear
                                .frame(height: 80)
                                .id("bottom")
                        }
                        .padding(.top, 12)
                    }
                    .onChange(of: vm.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onTapGesture {
                        inputFocused       = false
                        showReactionPicker = false
                    }
                    .task {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }

                // Reaction picker overlay
                if showReactionPicker, let msg = reactingTo {
                    Color.primary.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showReactionPicker = false
                            reactingTo        = nil
                        }

                    ReactionPicker(
                        onPick: { emoji in
                            Task {
                                await vm.toggleReaction(
                                    groupId: groupId,
                                    message: msg,
                                    emoji:   emoji
                                )
                            }
                            showReactionPicker = false
                            reactingTo        = nil
                        },
                        onDismiss: {
                            showReactionPicker = false
                            reactingTo        = nil
                        }
                    )
                    .padding(.bottom, 90)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .animation(.spring(response: 0.3), value: showReactionPicker)
                }
            }

            inputBar
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            tabManager.isTabBarHidden = true
            vm.startListening(groupId: group.groupId)
        }
        .onDisappear {
            tabManager.isTabBarHidden = false
            vm.stopListening()
        }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: { Text(vm.errorMessage) }
    }

    // MARK: - Nav Bar
    private var navBar: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .primary.opacity(0.06), radius: 4, x: 0, y: 2)
            }

            KGroupAvatar(
                imageURL: group.groupImageURL,
                name:     group.name,
                size:     36
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text("\(group.members.count) members")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .shadow(color: .primary.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        VStack(spacing: 0) {
            // Reply preview
            if let reply = vm.replyingTo {
                HStack(spacing: 10) {
                    Rectangle()
                        .fill(Color(hex: "#0300BF"))
                        .frame(width: 3)
                        .cornerRadius(2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Replying to \(reply.senderName)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "#0300BF"))
                        Text(reply.text)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Button { vm.cancelReply() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(hex: "#0300BF").opacity(0.06))
            }

            Divider()

            HStack(spacing: 12) {
                TextField("Message...", text: $vm.inputText, axis: .vertical)
                    .font(.system(size: 15))
                    .lineLimit(1...5)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .focused($inputFocused)

                Button {
                    Task { await vm.send(groupId: group.groupId) }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(uiColor: .systemBackground))
                        .frame(width: 36, height: 36)
                        .background(
                            vm.inputText.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                                ? Color(.systemGray4)
                                : Color(hex: "#0300BF")
                        )
                        .clipShape(Circle())
                }
                .disabled(
                    vm.inputText.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty
                )
                .animation(.easeInOut(duration: 0.2), value: vm.inputText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(UIColor.systemBackground))
        }
    }

    // MARK: - Date Separator
    private func dateSeparator(_ label: String) -> some View {
        HStack {
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 0.5)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(UIColor.systemGray6))
                )
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        ChatView(group: StudyGroup(
            groupId:     "g1",
            name:        "iOS Dev",
            subject:     "iOS Development",
            major:       "Computer Science",
            description: "Test",
            createdBy:   "uid1",
            members:     ["uid1", "uid2"],
            privacy:     "public",
            university:  "NIBM",
            createdAt:   Date()
        ))
        .environmentObject(AuthViewModel())
        .environmentObject(TabBarViewModel())
    }
}
