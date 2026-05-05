//
//  QuestionDetailView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import SwiftUI

struct QuestionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = QuestionDetailViewModel()

    let question: Question
    let group:    StudyGroup

    @FocusState private var isInputFocused: Bool

    var isAuthor: Bool {
        question.authorId == authVM.currentUser?.uid ?? ""
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Question section
                    sectionLabel("QUESTION").padding(.top, 24)
                    questionCard.padding(.top, 8)

                    // Answers section
                    HStack {
                        sectionLabel("ANSWERS (\(question.answerCount))")
                        Spacer()
                        Text("+15 pts per answer")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "#6B3FD4"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(hex: "#6B3FD4").opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 24)

                    answersSection.padding(.top, 8)

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }

            answerInput
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            guard let id = question.id else { return }
            await vm.load(groupId: group.groupId, questionId: id)
        }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            Spacer()
            Text("Q&A")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Image(systemName: "chevron.left").opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemGroupedBackground))
    }

    private var questionCard: some View {
        VStack(spacing: 0) {
            // Tag + title
            VStack(alignment: .leading, spacing: 10) {
                Text(question.tag)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: "#0300BF"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#0300BF").opacity(0.1))
                    .clipShape(Capsule())

                Text(question.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)

                if !question.description.isEmpty {
                    Text(question.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
            }
            .padding(16)

            Divider().padding(.leading, 16)

            // Author row
            HStack(spacing: 10) {
                KUserAvatar(imageURL: nil, name: question.authorName, size: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text(question.authorName)
                        .font(.system(size: 13, weight: .semibold))
                    Text(question.timeAgo)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#0300BF"))
                    Text("\(question.upvoteCount)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#0300BF"))
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    private var answersSection: some View {
        Group {
            if vm.isLoading {
                ProgressView().frame(maxWidth: .infinity).padding(.vertical, 24)
            } else if vm.answers.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 28))
                        .foregroundColor(.gray.opacity(0.35))
                    Text("No answers yet — be the first!")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                VStack(spacing: 12) {
                    let bestAnswers    = vm.answers.filter { $0.isBestAnswer }
                    let regularAnswers = vm.answers.filter { !$0.isBestAnswer }
                    ForEach(bestAnswers)    { answer in answerCard(answer: answer, isBest: true) }
                    ForEach(regularAnswers) { answer in answerCard(answer: answer, isBest: false) }
                }
            }
        }
    }

    private func answerCard(answer: Answer, isBest: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Best badge
            if isBest {
                HStack(spacing: 6) {
                    KIconBox(
                        icon:         "checkmark.seal.fill",
                        iconColor:    Color(hex: "#1D9E75"),
                        bgColor:      Color(hex: "#E0F5EE"),
                        size:         28,
                        cornerRadius: 8,
                        iconSize:     13
                    )
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Best Answer")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "#1D9E75"))
                        Text("+25 pts awarded")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#1D9E75").opacity(0.8))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

                Divider().padding(.leading, 16)
            }

            // Body
            Text(answer.body)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .padding(16)

            Divider().padding(.leading, 16)

            // Author + actions
            HStack(spacing: 10) {
                KUserAvatar(imageURL: nil, name: answer.authorName, size: 28)
                VStack(alignment: .leading, spacing: 1) {
                    Text(answer.authorName)
                        .font(.system(size: 12, weight: .semibold))
                    Text(answer.timeAgo)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                Spacer()

                // Upvote
                Button {
                    Task {
                        await vm.toggleAnswerUpvote(
                            groupId:  group.groupId,
                            question: question,
                            answer:   answer
                        )
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: answer.upvotes.contains(
                            authVM.currentUser?.uid ?? "")
                              ? "hand.thumbsup.fill"
                              : "hand.thumbsup")
                            .font(.system(size: 12))
                        Text("\(answer.upvoteCount)")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(
                        answer.upvotes.contains(authVM.currentUser?.uid ?? "")
                            ? Color(hex: "#0300BF")
                            : .secondary
                    )
                }

                // Mark best — question author only
                if isAuthor && !answer.isBestAnswer {
                    Button {
                        Task {
                            await vm.markBestAnswer(
                                groupId:  group.groupId,
                                question: question,
                                answer:   answer
                            )
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal")
                                .font(.system(size: 11))
                            Text("Best")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "#1D9E75"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: "#1D9E75").opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isBest
                        ? Color(hex: "#1D9E75").opacity(0.4)
                        : Color(hex: "#6B3FD4").opacity(0.15),
                    lineWidth: isBest ? 1.5 : 1
                )
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private var answerInput: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                KUserAvatar(
                    imageURL: nil,
                    name:     authVM.currentUser?.username ?? "?",
                    size:     34
                )
                TextField("Write your answer...", text: $vm.answerText, axis: .vertical)
                    .font(.system(size: 14))
                    .lineLimit(1...4)
                    .focused($isInputFocused)

                Button {
                    Task {
                        await vm.postAnswer(
                            groupId:    group.groupId,
                            question:   question,
                            authorName: authVM.currentUser?.username ?? "Anonymous"
                        )
                        isInputFocused = false
                    }
                } label: {
                    if vm.isPosting {
                        ProgressView().scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(
                                vm.answerText.isEmpty
                                    ? .gray.opacity(0.4)
                                    : Color(hex: "#0300BF")
                            )
                    }
                }
                .disabled(vm.answerText.isEmpty || vm.isPosting)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .tracking(0.5)
    }
}

#Preview {
    NavigationStack {
        QuestionDetailView(
            question: Question(
                questionId:   "q1",
                groupId:      "g1",
                authorId:     "uid1",
                authorName:   "Alex Chen",
                title:        "What is the difference between struct and class in Swift?",
                description:  "I'm confused about when to use struct vs class in Swift. Can someone explain?",
                tag:          "iOS",
                upvotes:      ["uid2"],
                answerCount:  2,
                bestAnswerId: "a1",
                createdAt:    Date(),
                status:       "answered"
            ),
            group: StudyGroup(
                groupId:     "g1",
                name:        "iOS Dev",
                subject:     "iOS Development",
                major:       "Computer Science",
                description: "Test group",
                createdBy:   "uid1",
                members:     ["uid1"],
                privacy:     "public",
                university:  "NIBM",
                createdAt:   Date()
            )
        )
        .environmentObject(AuthViewModel())
    }
}
