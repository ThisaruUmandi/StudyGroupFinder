//
//  QnAView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-24.
//

import SwiftUI

struct QnAView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var tabManager: TabBarViewModel
    @StateObject private var vm = QnAViewModel()

    @State private var showAskQuestion   = false
    @State private var selectedQuestion: Question?

    let group: StudyGroup

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemBackground)

            VStack(spacing: 0) {
                navBar
                filterBar.padding(.top, 16)
                KSearchBar(text: $vm.searchText, placeholder: "Search questions...")
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                questionList.padding(.top, 16)
            }

            // FAB
            Button { showAskQuestion = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color(hex: "#0300BF"))
                    .clipShape(Circle())
                    .shadow(color: Color(hex: "#0300BF").opacity(0.4),
                            radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 90)
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedQuestion) { question in
            QuestionDetailView(question: question, group: group)
                .environmentObject(authVM)
                .environmentObject(tabManager)
        }
        .navigationDestination(isPresented: $showAskQuestion) {
            AskQuestionView(group: group)
                .environmentObject(authVM)
                .environmentObject(tabManager)
        }
        .onChange(of: showAskQuestion) { _, isShowing in
            if !isShowing { Task { await vm.load(for: group.groupId) } }
        }
        .task { await vm.load(for: group.groupId) }
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
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            Spacer()
            Text("Q&A")
                .font(.system(size: 24, weight: .semibold))
            Spacer()
//            Image("upboy")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 70)
//                .offset(y: 90)
//                .padding(.trailing, 19)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.filters.indices, id: \.self) { index in
                    Button {
                        vm.selectedFilter = index
                    } label: {
                        Text(vm.filters[index])
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(vm.selectedFilter == index ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                vm.selectedFilter == index
                                    ? Color(hex: "#0300BF")
                                    : Color(.systemBackground)
                            )
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .frame(minWidth: UIScreen.main.bounds.width)
        }
    }

    private var questionList: some View {
        Group {
            if vm.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if vm.filtered.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "questionmark.bubble")
                        .font(.system(size: 36))
                        .foregroundColor(.gray.opacity(0.35))
                    Text("No questions yet")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("Be the first to ask!")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(vm.filtered) { question in
                            KQuestionCard(
                                question:   question,
                                currentUid: authVM.currentUser?.uid ?? ""
                            ) {
                                selectedQuestion = question
                            } onUpvote: {
                                Task {
                                    await vm.toggleUpvote(
                                        question: question,
                                        groupId:  group.groupId
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        QnAView(group: StudyGroup(
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
        ))
        .environmentObject(AuthViewModel())
        .environmentObject(TabBarViewModel())
    }
}
