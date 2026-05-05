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

    var hasVoted:  Bool { userVote != nil }
    var isAuthor:  Bool { poll.authorId == currentUid }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider()

            VStack(spacing: 8) {
                ForEach(poll.options.indices, id: \.self) { index in
                    if hasVoted || poll.isClosed {
                        votedRow(index: index)
                    } else {
                        unvotedRow(index: index)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            //Divider()

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
                // Status badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(poll.isClosed ? Color(hex: "#E84040") : Color(hex: "#1D9E75"))
                        .frame(width: 6, height: 6)
                    Text(poll.isClosed ? "Closed" : poll.timeLeft)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(poll.isClosed ? Color(hex: "#E84040") : Color(hex: "#1D9E75"))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    (poll.isClosed ? Color(hex: "#E84040") : Color(hex: "#1D9E75")).opacity(0.1)
                )
                .clipShape(Capsule())

                Spacer()

                Text("\(poll.totalVotes) votes")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Text(poll.question)
                .font(.system(size: 16, weight: .bold))
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
            HStack(spacing: 10) {
                // Letter circle
                Text(letters[index])
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#0300BF"))
                    .frame(width: 28, height: 28)
                    .background(Color(hex: "#0300BF").opacity(0.08))
                    .clipShape(Circle())

                Text(poll.options[index].text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#0300BF").opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Voted Row
    private func votedRow(index: Int) -> some View {
        let pct       = poll.percentage(for: index)
        let isCorrect = index == poll.correctIndex
        let isMyVote  = userVote == index
        let isWrong   = isMyVote && !isCorrect

        let barColor: Color = isCorrect
            ? Color(hex: "#1D9E75")
            : isWrong
                ? Color(hex: "#E84040")
                : Color(hex: "#0300BF")

        let bgColor: Color = isCorrect
            ? Color(hex: "#1D9E75").opacity(0.07)
            : isWrong
                ? Color(hex: "#E84040").opacity(0.07)
                : Color(UIColor.systemGroupedBackground)

        return ZStack(alignment: .leading) {
            // Background track
            RoundedRectangle(cornerRadius: 12)
                .fill(bgColor)

            // Progress fill
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 12)
                    .fill(barColor.opacity(0.18))
                    .frame(width: max(0, geo.size.width * CGFloat(pct / 100)))
                    .animation(.easeInOut(duration: 0.7), value: pct)
            }

            // Content on top
            HStack(spacing: 10) {
                // Letter or result icon
                ZStack {
                    Circle()
                        .fill(barColor.opacity(0.15))
                        .frame(width: 28, height: 28)

                    if isCorrect {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(barColor)
                    } else if isWrong {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(barColor)
                    } else {
                        Text(letters[index])
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(barColor)
                    }
                }

                Text(poll.options[index].text)
                    .font(.system(size: 14, weight: isCorrect ? .semibold : .medium))
                    .foregroundColor(isCorrect || isWrong ? barColor : .primary)

                Spacer()

                Text("\(Int(pct))%")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(barColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .frame(height: 48)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isCorrect || isWrong
                        ? barColor.opacity(0.3)
                        : Color.clear,
                    lineWidth: 1.5
                )
        )
    }

    // MARK: - Footer
    private var footer: some View {
        HStack(spacing: 10) {
            if !hasVoted && !poll.isClosed {
                Label("Vote to gain points", systemImage: "star.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "#F5A623"))
                    .padding(.bottom, 4)
            } else if hasVoted {
                Label("Voted", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "#1D9E75"))
                    .padding(.bottom, 4)
            }

            Spacer()

            if isAuthor && !poll.isClosed {
                Button { onClose() } label: {
                    Text("Close Poll")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#E84040"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#E84040").opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }

    private let letters = ["A", "B", "C", "D", "E", "F"]
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            // Unvoted poll
            KPollCard(
                poll: Poll(
                    pollId: "p1", groupId: "g1", authorId: "uid1", authorName: "Alex Chen",
                    question: "What is the output of print(2 + 2) in Swift?",
                    options: [
                        PollOption(id: "1", text: "4",     voteCount: 10),
                        PollOption(id: "2", text: "22",    voteCount: 3),
                        PollOption(id: "3", text: "Error", voteCount: 2),
                        PollOption(id: "4", text: "None",  voteCount: 1)
                    ],
                    correctIndex: 0, duration: 24,
                    endsAt: Date().addingTimeInterval(3600 * 20),
                    status: "active", createdAt: Date(), totalVotes: 16
                ),
                userVote: nil, currentUid: "uid2"
            ) { _ in } onClose: {}

            // Voted poll — correct
            KPollCard(
                poll: Poll(
                    pollId: "p2", groupId: "g1", authorId: "uid1", authorName: "Alex Chen",
                    question: "Which keyword is used to define a constant in Swift?",
                    options: [
                        PollOption(id: "1", text: "var",   voteCount: 5),
                        PollOption(id: "2", text: "let",   voteCount: 20),
                        PollOption(id: "3", text: "const", voteCount: 2),
                        PollOption(id: "4", text: "def",   voteCount: 1)
                    ],
                    correctIndex: 1, duration: 24,
                    endsAt: Date().addingTimeInterval(3600 * 10),
                    status: "active", createdAt: Date(), totalVotes: 28
                ),
                userVote: 1, currentUid: "uid2"
            ) { _ in } onClose: {}

            // Voted poll — wrong
            KPollCard(
                poll: Poll(
                    pollId: "p3", groupId: "g1", authorId: "uid1", authorName: "Alex Chen",
                    question: "Which keyword is used to define a constant in Swift?",
                    options: [
                        PollOption(id: "1", text: "var",   voteCount: 5),
                        PollOption(id: "2", text: "let",   voteCount: 20),
                        PollOption(id: "3", text: "const", voteCount: 2),
                        PollOption(id: "4", text: "def",   voteCount: 1)
                    ],
                    correctIndex: 1, duration: 24,
                    endsAt: Date().addingTimeInterval(3600 * 10),
                    status: "active", createdAt: Date(), totalVotes: 28
                ),
                userVote: 0, currentUid: "uid2"
            ) { _ in } onClose: {}
        }
        .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
}
