//
//  KQuestionCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

//
//  KQuestionCard.swift
//  Kuppiya
//

import SwiftUI

struct KQuestionCard: View {
    let question:   Question
    let currentUid: String
    let onTap:      () -> Void
    let onUpvote:   () -> Void

    var isUpvoted: Bool { question.upvotes.contains(currentUid) }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text(question.tag)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: "#0300BF"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#0300BF").opacity(0.1))
                        .clipShape(Capsule())
                    Spacer()
                    HStack(spacing: 4) {
                        Circle()
                            .fill(question.isAnswered
                                  ? Color(hex: "#1D9E75")
                                  : Color(hex: "#BA7517"))
                            .frame(width: 6, height: 6)
                        Text(question.isAnswered ? "Answered" : "Unanswered")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(question.isAnswered
                                             ? Color(hex: "#1D9E75")
                                             : Color(hex: "#BA7517"))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        (question.isAnswered
                         ? Color(hex: "#1D9E75")
                         : Color(hex: "#BA7517")).opacity(0.1)
                    )
                    .clipShape(Capsule())
                }

                Text(question.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    KUserAvatar(imageURL: nil, name: question.authorName, size: 22)
                    Text("\(question.authorName) · \(question.timeAgo)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Divider()

                HStack(spacing: 16) {
                    Button(action: onUpvote) {
                        HStack(spacing: 4) {
                            Image(systemName: isUpvoted
                                  ? "hand.thumbsup.fill"
                                  : "hand.thumbsup.up")
                                .font(.system(size: 13))
                                .foregroundColor(isUpvoted
                                                 ? Color(hex: "#0300BF")
                                                 : .secondary)
                            Text("\(question.upvoteCount)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(isUpvoted
                                                 ? Color(hex: "#0300BF")
                                                 : .secondary)
                        }
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text("\(question.answerCount) answers")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("+10 pts")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: "#6B3FD4"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "#6B3FD4").opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    KQuestionCard(
        question: Question(
            questionId:   "q1",
            groupId:      "g1",
            authorId:     "uid1",
            authorName:   "Alex Chen",
            title:        "What is the difference between struct and class in Swift?",
            description:  "I'm confused about when to use struct vs class.",
            tag:          "iOS",
            upvotes:      ["uid2", "uid3"],
            answerCount:  3,
            bestAnswerId: nil,
            createdAt:    Date(),
            status:       "answered"
        ),
        currentUid: "uid2"
    ) {} onUpvote: {}
    .padding()
}
