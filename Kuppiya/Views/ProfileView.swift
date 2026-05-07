//
//  ProfileView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ProfileViewModel()

    @State private var navigateToPersonal     = false
    @State private var navigateToEducational  = false
    @State private var navigateToLeaderboard  = false
    @State private var showLogoutAlert        = false
    @State private var showPasswordAlert      = false
    @State private var selectedPhoto: PhotosPickerItem? = nil

    @AppStorage("biometricEnabled") private var biometricEnabled = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    profileHeader
                        .padding(.bottom, 28)

                    // Stats
                    statsRow
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)

                    // General
                    sectionLabel("GENERAL")
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        navigationRow(
                            icon:      "person.fill",
                            iconColor: Color(hex: "#0300BF"),
                            iconBg:    Color(hex: "#EEEEFF"),
                            title:     "Personal Info"
                        ) { navigateToPersonal = true }

                        Divider().padding(.leading, 72)

                        navigationRow(
                            icon:      "graduationcap.fill",
                            iconColor: Color(hex: "#6B3FD4"),
                            iconBg:    Color(hex: "#EDE7FF"),
                            title:     "Educational Info"
                        ) { navigateToEducational = true }
                    }
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                    // Privacy & Security
                    sectionLabel("PRIVACY & SECURITY")
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        // Biometric toggle
                        HStack(spacing: 14) {
                            KIconBox(
                                icon:         BiometricService.shared.biometricIcon,
                                iconColor:    Color(hex: "#1D9E75"),
                                bgColor:      Color(hex: "#E0F5EE"),
                                size:         42,
                                cornerRadius: 12,
                                iconSize:     17
                            )
                            Text(BiometricService.shared.biometricLabel)
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                            Spacer()
                            Toggle("", isOn: $biometricEnabled)
                                .tint(Color(hex: "#0300BF"))
                                .onChange(of: biometricEnabled) { _, newVal in
                                    if newVal {
                                        Task { await vm.toggleBiometric() }
                                    }
                                }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        Divider().padding(.leading, 72)

                        // Password
                        Button {
                            showPasswordAlert = true
                        } label: {
                            HStack(spacing: 14) {
                                KIconBox(
                                    icon:         "lock.fill",
                                    iconColor:    Color(hex: "#D85A30"),
                                    bgColor:      Color(hex: "#FFF0EB"),
                                    size:         42,
                                    cornerRadius: 12,
                                    iconSize:     17
                                )
                                Text("Password")
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    }
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                    // Preferences
                    sectionLabel("PREFERENCES")
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        HStack(spacing: 14) {
                            KIconBox(
                                icon:         "moon.fill",
                                iconColor:    Color(hex: "#534AB7"),
                                bgColor:      Color(hex: "#EEEEFF"),
                                size:         42,
                                cornerRadius: 12,
                                iconSize:     17
                            )
                            Text("Dark Mode")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                            Spacer()
                            Text("System")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        Divider().padding(.leading, 72)

                        // Global Leaderboard
                        Button {
                            navigateToLeaderboard = true
                        } label: {
                            HStack(spacing: 14) {
                                KIconBox(
                                    icon:         "trophy.fill",
                                    iconColor:    Color(hex: "#F5A623"),
                                    bgColor:      Color(hex: "#FFF8E8"),
                                    size:         42,
                                    cornerRadius: 12,
                                    iconSize:     17
                                )
                                Text("Global Leaderboard")
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    }
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)

                    // Log Out
                    Button {
                        showLogoutAlert = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Log Out")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "#D85A30"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color(hex: "#D85A30"), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                .padding(.top, 20)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToPersonal) {
                PersonalInfoView(vm: vm)
                    .environmentObject(authVM)
            }
            .navigationDestination(isPresented: $navigateToEducational) {
                EducationalInfoView(vm: vm)
            }
            .navigationDestination(isPresented: $navigateToLeaderboard) {
                GlobalLeaderboardView()
                    .environmentObject(authVM)
            }
        }
        .task { await vm.load() }
        .onChange(of: selectedPhoto) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await vm.uploadProfileImage(image)
                }
            }
        }
        .alert("Log Out?", isPresented: $showLogoutAlert) {
            Button("Log Out", role: .destructive) {
                try? vm.signOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out?")
        }
        .alert("Reset Password?", isPresented: $showPasswordAlert) {
            Button("Send Reset Email") {
                Task { await vm.sendPasswordReset() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("A password reset link will be sent to your email.")
        }
        .alert("Success", isPresented: $vm.showSuccess) {
            Button("OK", role: .cancel) {}
        } message: { Text(vm.successMessage) }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: { Text(vm.errorMessage) }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                if vm.isUploadingImage {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 100, height: 100)
                        .overlay(ProgressView())
                } else {
                    KUserAvatar(
                        imageURL: vm.user?.profileImage,
                        name:     vm.user?.username ?? "",
                        size:     100
                    )
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "#0300BF").opacity(0.3), lineWidth: 3)
                    )
                }

                // Edit button
                PhotosPicker(selection: $selectedPhoto,
                             matching: .images) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color(hex: "#0300BF"))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }

            Text(vm.user?.username ?? "")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)

            Text(vm.user?.email ?? "")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(
                value: "\(vm.user?.joinedGroups.count ?? 0)",
                label: "Groups"
            )
            Divider().frame(height: 40)
            statItem(
                value: vm.user?.university ?? "—",
                label: "University"
            )
            Divider().frame(height: 40)
            statItem(
                value: vm.user?.major.isEmpty == false
                       ? vm.user!.major : "—",
                label: "Major"
            )
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Navigation Row
    private func navigationRow(
        icon:      String,
        iconColor: Color,
        iconBg:    Color,
        title:     String,
        action:    @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                KIconBox(
                    icon:         icon,
                    iconColor:    iconColor,
                    bgColor:      iconBg,
                    size:         42,
                    cornerRadius: 12,
                    iconSize:     17
                )
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
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
    ProfileView()
        .environmentObject(AuthViewModel())
}
