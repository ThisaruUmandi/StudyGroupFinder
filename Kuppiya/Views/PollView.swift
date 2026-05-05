//
//  PollView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-24.
//

import SwiftUI

struct PollView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var tabManager: TabBarViewModel
    @StateObject private var vm = PollViewModel()

    @State private var showCreate = false

    let group: StudyGroup

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                filterBar.padding(.top, 16)
                pollList.padding(.top, 16)
            }

            Button { showCreate = true } label: {
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
        .navigationDestination(isPresented: $showCreate) {
            CreatePollView(group: group)
                .environmentObject(authVM)
                .environmentObject(tabManager)
        }
        .onChange(of: showCreate) { _, isShowing in
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
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            Spacer()
            Text("Polls")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
//            Image("oboy_r")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 54)
//                .offset(y: -6)
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
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(vm.selectedFilter == index ? .white : .primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                vm.selectedFilter == index
                                    ? Color(hex: "#0300BF")
                                    : Color.white
                            )
                            .clipShape(Capsule())
                            .padding(.horizontal, 5)
                            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .frame(minWidth: UIScreen.main.bounds.width)
            .multilineTextAlignment(.center)
        }
    }

    private var pollList: some View {
        Group {
            if vm.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if vm.filtered.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 36))
                        .foregroundColor(.gray.opacity(0.35))
                    Text("No polls here")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("Create one to get started!")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(vm.filtered) { poll in
                            KPollCard(
                                poll: poll,
                                userVote: vm.userVotes[poll.pollId],
                                currentUid: authVM.currentUser?.uid ?? ""
                            ) { optionIndex in
                                Task {
                                    await vm.vote(
                                        poll: poll,
                                        optionIndex: optionIndex,
                                        groupId: group.groupId
                                    )
                                }
                            } onClose: {
                                Task {
                                    await vm.closePoll(
                                        poll: poll,
                                        groupId: group.groupId
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
        PollView(group: StudyGroup(
            groupId: "g1",
            name: "iOS Dev",
            subject: "iOS Development",
            major: "Computer Science",
            description: "Test group",
            createdBy: "uid1",
            members: ["uid1"],
            privacy: "public",
            university: "NIBM",
            createdAt: Date()
        ))
        .environmentObject(AuthViewModel())
        .environmentObject(TabBarViewModel())
    }
}
