//
//  PersonalInfoView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import SwiftUI

struct PersonalInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @ObservedObject var vm: ProfileViewModel

    @State private var username = ""
    @State private var email    = ""
    @State private var showSaveAlert = false

    var hasChanges: Bool {
        username != (vm.user?.username ?? "") ||
        email    != (vm.user?.email    ?? "")
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                navBar
                    .padding(.bottom, 24)

                sectionLabel("PERSONAL INFO")
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                VStack(spacing: 0) {
                    SettingsFormField(
                        icon: "person.fill",
                        iconColor: Color(hex: "#0300BF"),
                        iconBg: Color(hex: "#EEEEFF"),
                        label: "USERNAME",
                        text: $username
                    )
                    Divider().padding(.leading, 72)
                    SettingsFormField(
                        icon: "envelope.fill",
                        iconColor: Color(hex: "#1D9E75"),
                        iconBg: Color(hex: "#E0F5EE"),
                        label: "EMAIL",
                        text: $email
                    )
                }
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: .primary.opacity(0.05), radius: 8, x: 0, y: 3)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)

                // Save button
                Button {
                    showSaveAlert = true
                } label: {
                    Text("Save Changes")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(uiColor: .systemBackground))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            hasChanges
                                ? Color(hex: "#0300BF")
                                : Color(.systemGray4)
                        )
                        .clipShape(Capsule())
                }
                .disabled(!hasChanges)
                .padding(.horizontal, 20)
            }
            .padding(.top, 16)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            username = vm.user?.username ?? ""
            email    = vm.user?.email    ?? ""
        }
        .alert("Save Changes?", isPresented: $showSaveAlert) {
            Button("Save") {
                Task {
                    if username != vm.user?.username {
                        await vm.updateUsername(username)
                    }
                    if email != vm.user?.email {
                        await vm.updateEmail(email)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to save these changes?")
        }
        .alert("Success", isPresented: $vm.showSuccess) {
            Button("OK", role: .cancel) {}
        } message: { Text(vm.successMessage) }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: { Text(vm.errorMessage) }
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
                    .shadow(color: .primary.opacity(0.06), radius: 4, x: 0, y: 2)
            }
            Spacer()
            Text("Personal Info")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let vm  = ProfileViewModel()
    vm.user = AppUser(
        id: "1",
        uid: "uid1",
        username: "Kaveen De Silva",
        email: "kaveen@gmail.com",
        profileImage: "",
        university: "NIBM",
        major: "Computer Science",
        joinedGroups: ["g1", "g2"],
        interests: ["iOS", "Swift"],
        createdAt: Date(),
        fcmToken: ""
    )
    return NavigationStack {
        PersonalInfoView(vm: vm)
            .environmentObject(AuthViewModel())
    }
}
