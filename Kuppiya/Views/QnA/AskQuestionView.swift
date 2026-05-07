//
//  AskQuestionView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-05.
//

import SwiftUI

struct AskQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var tabManager: TabBarViewModel
    @StateObject private var vm = AskQuestionViewModel()

    let group: StudyGroup

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                navBar

                // Mascot + points banner
                ZStack(alignment: .bottomTrailing) {
                    HStack(spacing: 12) {
                        KIconBox(
                            icon:         "star.fill",
                            iconColor:    Color(hex: "#FFD400"),
                            bgColor:      Color(hex: "#FFD400").opacity(0.06),
                            size:         42,
                            cornerRadius: 12,
                            iconSize:     18
                        )
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Earn +10 points!")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(hex: "#F5A623"))
                            Text("Auto-awarded when you post a question.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color(hex: "#FFF8E7"))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "#F5A623").opacity(0.3), lineWidth: 1)
                    )

//                    Image("oboy_l")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 64)
//                        .offset(x: -12, y: 20)
                }
                .padding(.top, 24)
                .padding(.bottom, 10)

                sectionLabel("QUESTION DETAILS").padding(.top, 24)

                VStack(spacing: 0) {
                    SettingsFormField(
                        icon:      "questionmark.circle",
                        iconColor: Color(hex: "#E01F20"),
                        iconBg:    Color(hex: "#E01F20").opacity(0.06),
                        label:     "YOUR QUESTION",
                        text:      $vm.title
                    )
                    Divider().padding(.leading, 72)
                    SettingsFormField(
                        icon:        "text.alignleft",
                        iconColor:   Color(hex: "#1893DD"),
                        iconBg:      Color(hex: "#1893DD").opacity(0.06),
                        label:       "DESCRIPTION (OPTIONAL)",
                        text:        $vm.description,
                        isMultiline: true
                    )
                }
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
                .padding(.top, 8)

                // Post button
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
                            ProgressView().tint(.white).scaleEffect(0.8)
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text("Post Question")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(Color(uiColor: .systemBackground))
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
                .padding(.top, 32)

                Spacer(minLength: 60)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.systemGroupedBackground).opacity(0.1).ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear   { tabManager.isTabBarHidden = true  }
        .onDisappear { tabManager.isTabBarHidden = false }
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
                    .shadow(color: .primary.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            Spacer()
            Text("Ask a Question")
                .font(.system(size: 22, weight: .semibold))
            Spacer()
            Image(systemName: "chevron.left").opacity(0)
        }
        .padding(.top, 16)
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
        AskQuestionView(group: StudyGroup(
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
