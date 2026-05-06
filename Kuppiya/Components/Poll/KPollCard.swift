//
//  KPollCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import SwiftUI

struct KPollCard: View {
    let poll:       Poll
    let userVote:   Int?
    let currentUid: String
    let onVote:     (Int) -> Void
    let onClose:    () -> Void

    var hasVoted: Bool { userVote != nil }
    var isAuthor: Bool { poll.authorId == currentUid }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider()

            VStack(spacing: 10) {
                ForEach(poll.options.indices, id: \.self) { index in
                    if hasVoted || poll.isClosed {
                        votedRow(index: index)
                    } else {
                        unvotedRow(index: index)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()

            footer
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(poll.isClosed
                              ? Color(hex: "#E84040")
                              : Color(hex: "#1D9E75"))
                        .frame(width: 6, height: 6)
                    Text(poll.isClosed ? "Closed" : poll.timeLeft)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(poll.isClosed
                                         ? Color(hex: "#E84040")
                                         : Color(hex: "#1D9E75"))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    (poll.isClosed
                     ? Color(hex: "#E84040")
                     : Color(hex: "#1D9E75")).opacity(0.1)
                )
                .clipShape(Capsule())

                // Multiple choice badge
                if poll.allowMultiple {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.square")
                            .font(.system(size: 10, weight: .semibold))
                        Text("Multiple choice")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "#6B3FD4"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#6B3FD4").opacity(0.1))
                    .clipShape(Capsule())
                }

                Spacer()

                Text("\(poll.totalVotes) votes")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Text(poll.question)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("by \(poll.authorName) · \(poll.timeAgo)")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Unvoted Row
    private func unvotedRow(index: Int) -> some View {
        Button { onVote(index) } label: {
            HStack(spacing: 0) {
                Text(poll.options[index].text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                Spacer()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Voted Row (pill style)
    private func votedRow(index: Int) -> some View {
        let pct      = poll.percentage(for: index)
        let maxVotes = poll.options.map(\.voteCount).max() ?? 0
        let isMyVote = userVote == index

        // For multiple choice: highlight most voted
        // For single choice: show correct/wrong
        let isCorrect: Bool = {
            if poll.allowMultiple {
                return poll.options[index].voteCount == maxVotes && maxVotes > 0
            }
            return index == poll.correctIndex
        }()

        let isWrong: Bool = {
            if poll.allowMultiple { return false }
            return isMyVote && !isCorrect
        }()

        let fillColor: Color = {
            if isCorrect { return Color(hex: "#1D9E75") }
            if isWrong   { return Color(hex: "#E84040") }
            return Color(.systemGray4)
        }()

        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Base track
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGroupedBackground))

                // Pill fill
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isCorrect
                            ? Color(hex: "#1D9E75").opacity(0.85)
                            : isWrong
                                ? Color(hex: "#E84040").opacity(0.85)
                                : Color(.systemGray4).opacity(0.4)
                    )
                    .frame(width: max(
                        pct > 0 ? 48 : 0,
                        geo.size.width * CGFloat(pct / 100)
                    ))
                    .animation(.easeInOut(duration: 0.7), value: pct)

                // Content row
                HStack {
                    // Result icon
                    if isCorrect {
                        Image(systemName: poll.allowMultiple ? "trophy.fill" : "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Circle())
                            .padding(.leading, 10)
                    } else if isWrong {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Circle())
                            .padding(.leading, 10)
                    } else {
                        Spacer().frame(width: 16)
                    }

                    Text(poll.options[index].text)
                        .font(.system(size: 14,
                                      weight: isCorrect ? .semibold : .medium))
                        .foregroundColor(
                            isCorrect || isWrong ? .white : .primary
                        )
                        .padding(.leading, isCorrect || isWrong ? 6 : 0)

                    Spacer()

                    // Vote count + %
                    HStack(spacing: 4) {
                        Text("\(poll.options[index].voteCount)")
                            .font(.system(size: 11))
                            .foregroundColor(
                                isCorrect || isWrong
                                    ? .white.opacity(0.8) : .secondary
                            )
                        Text("·")
                            .foregroundColor(
                                isCorrect || isWrong
                                    ? .white.opacity(0.6) : Color(.systemGray4)
                            )
                        Text("\(Int(pct))%")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(
                                isCorrect || isWrong ? .white : fillColor
                            )
                    }
                    .padding(.trailing, 12)
                }
            }
            .frame(height: 48)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isCorrect
                            ? Color(hex: "#1D9E75").opacity(0.3)
                            : isWrong
                                ? Color(hex: "#E84040").opacity(0.3)
                                : Color(.systemGray5),
                        lineWidth: 1
                    )
            )
        }
        .frame(height: 48)
    }

    // MARK: - Footer
    private var footer: some View {
        HStack(spacing: 10) {
            if hasVoted {
                Label("Voted", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "#1D9E75"))
            } else if !poll.isClosed {
                Label("+8 pts to vote", systemImage: "star.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "#F5A623"))
            }

            Spacer()

            if !poll.isClosed {
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.system(size: 11))
                    Text("\(poll.totalVotes) votes")
                        .font(.system(size: 11))
                }
                .foregroundColor(.secondary)
            }

            if isAuthor && !poll.isClosed {
                Button { onClose() } label: {
                    Text("Close Poll")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#E84040"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: "#E84040").opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            // Unvoted - single choice
            KPollCard(
                poll: Poll(
                    pollId: "p1", groupId: "g1",
                    authorId: "uid1", authorName: "Alex Chen",
                    question: "What is the output of print(2 + 2) in Swift?",
                    options: [
                        PollOption(id: "1", text: "4",     voteCount: 10),
                        PollOption(id: "2", text: "22",    voteCount: 3),
                        PollOption(id: "3", text: "Error", voteCount: 2),
                        PollOption(id: "4", text: "None",  voteCount: 1)
                    ],
                    correctIndex: 0, duration: 168,
                    endsAt: Date().addingTimeInterval(3600 * 20),
                    status: "active", createdAt: Date(), totalVotes: 16
                ),
                userVote: nil, currentUid: "uid2"
            ) { _ in } onClose: {}

            // Voted correct - single choice
            KPollCard(
                poll: Poll(
                    pollId: "p2", groupId: "g1",
                    authorId: "uid1", authorName: "Alex Chen",
                    question: "Which keyword defines a constant in Swift?",
                    options: [
                        PollOption(id: "1", text: "var",   voteCount: 5),
                        PollOption(id: "2", text: "let",   voteCount: 20),
                        PollOption(id: "3", text: "const", voteCount: 2),
                        PollOption(id: "4", text: "def",   voteCount: 1)
                    ],
                    correctIndex: 1, duration: 168,
                    endsAt: Date().addingTimeInterval(3600 * 10),
                    status: "active", createdAt: Date(), totalVotes: 28
                ),
                userVote: 1, currentUid: "uid2"
            ) { _ in } onClose: {}

            // Voted wrong - single choice
            KPollCard(
                poll: Poll(
                    pollId: "p3", groupId: "g1",
                    authorId: "uid1", authorName: "Alex Chen",
                    question: "Which keyword defines a constant in Swift?",
                    options: [
                        PollOption(id: "1", text: "var",   voteCount: 5),
                        PollOption(id: "2", text: "let",   voteCount: 20),
                        PollOption(id: "3", text: "const", voteCount: 2),
                        PollOption(id: "4", text: "def",   voteCount: 1)
                    ],
                    correctIndex: 1, duration: 168,
                    endsAt: Date().addingTimeInterval(3600 * 10),
                    status: "active", createdAt: Date(), totalVotes: 28
                ),
                userVote: 0, currentUid: "uid2"
            ) { _ in } onClose: {}

            // Multiple choice - voted
            KPollCard(
                poll: Poll(
                    pollId: "p4", groupId: "g1",
                    authorId: "uid1", authorName: "Alex Chen",
                    question: "Which topics should we cover next session?",
                    options: [
                        PollOption(id: "1", text: "SwiftUI Animations", voteCount: 18),
                        PollOption(id: "2", text: "Combine Framework",  voteCount: 12),
                        PollOption(id: "3", text: "Core Data",          voteCount: 8),
                        PollOption(id: "4", text: "Networking",         voteCount: 15)
                    ],
                    correctIndex: -1, duration: 168,
                    allowMultiple: true,
                    endsAt: Date().addingTimeInterval(3600 * 48),
                    status: "active", createdAt: Date(), totalVotes: 53
                ),
                userVote: 0, currentUid: "uid2"
            ) { _ in } onClose: {}
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
}
