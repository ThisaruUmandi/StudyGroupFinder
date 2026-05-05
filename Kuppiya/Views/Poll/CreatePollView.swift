//
//  CreatePollView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import SwiftUI

struct CreatePollView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var tabManager: TabBarViewModel
    @StateObject private var vm = CreatePollViewModel()

    let group: StudyGroup
    private let letters = ["A", "B", "C", "D", "E", "F"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Points banner
                pointsBanner
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                // Question section
                VStack(alignment: .leading, spacing: 8) {
                    sectionLabel("QUESTION")
                    questionCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                // Options section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        sectionLabel("OPTIONS")
                        Spacer()
                        Text("\(vm.options.count)/6")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    optionsCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                // Hint
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#1D9E75"))
                    Text("Tap ○ next to an option to mark it as the correct answer.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Post button scrolls with content
                Button {
                    Task {
                        await vm.post(
                            groupId:    group.groupId,
                            authorName: authVM.currentUser?.username ?? "Anonymous"
                        ) { dismiss() }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if vm.isPosting {
                            ProgressView().tint(.white).scaleEffect(0.85)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 15))
                            Text("Create Poll · +15 pts")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        vm.isValid
                            ? Color(hex: "#0300BF")
                            : Color(.systemGray4)
                    )
                    .clipShape(Capsule())
                }
                .disabled(!vm.isValid || vm.isPosting)
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .safeAreaInset(edge: .top) {
            navBar
                .background(Color.white)
        }
        .navigationBarHidden(true)
        .onAppear   { tabManager.isTabBarHidden = true  }
        .onDisappear { tabManager.isTabBarHidden = false }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage)
        }
    }

    // MARK: - Nav Bar
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
            Text("Create Poll")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Image(systemName: "chevron.left").opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Points Banner
    private var pointsBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#F5A623").opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "star.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#F5A623"))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("+15 pts for creating · +8 pts per vote")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#BA7517"))
                Text("Points are awarded automatically to all participants.")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#BA7517").opacity(0.7))
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "#FFF8E7"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "#F5A623").opacity(0.25), lineWidth: 1)
                )
        )
    }

    // MARK: - Question Card
    private var questionCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#0300BF").opacity(0.08))
                        .frame(width: 36, height: 36)
                    Image(systemName: "questionmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#0300BF"))
                }
                .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("YOUR QUESTION")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .tracking(0.5)
                    TextField("e.g. Enter your question here?", text: $vm.question, axis: .vertical)
                        .font(.system(size: 15))
                        .lineLimit(1...4)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Options Card
    private var optionsCard: some View {
        VStack(spacing: 0) {
            ForEach(vm.options.indices, id: \.self) { index in
                optionRow(index: index)
                if index < vm.options.count - 1 {
                    Divider().padding(.leading, 58)
                }
            }

            // Add option button
            if vm.options.count < 6 {
                Divider().padding(.leading, 16)
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        vm.options.append("")
                    }
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#0300BF").opacity(0.08))
                                .frame(width: 28, height: 28)
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "#0300BF"))
                        }
                        Text("Add option")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#0300BF"))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func optionRow(index: Int) -> some View {
        let isCorrect = vm.correctIndex == index
        return HStack(spacing: 12) {
            Text(letters[safe: index] ?? "\(index + 1)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isCorrect ? Color(hex: "#1D9E75") : Color(hex: "#0300BF"))
                .frame(width: 28, height: 28)
                .background(
                    (isCorrect ? Color(hex: "#1D9E75") : Color(hex: "#0300BF")).opacity(0.1)
                )
                .clipShape(Circle())

            TextField("Option \(index + 1)", text: $vm.options[index])
                .font(.system(size: 14))

            Spacer()

            Button {
                withAnimation(.spring(response: 0.25)) {
                    vm.correctIndex = index
                }
            } label: {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isCorrect ? Color(hex: "#1D9E75") : Color(.systemGray4))
                    .animation(.spring(response: 0.25), value: isCorrect)
            }

            if vm.options.count > 2 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        vm.options.remove(at: index)
                        if vm.correctIndex >= vm.options.count {
                            vm.correctIndex = vm.options.count - 1
                        }
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 22, height: 22)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .tracking(0.5)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack {
        CreatePollView(group: StudyGroup(
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
