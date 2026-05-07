//
//  EducationalInfoView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import SwiftUI

struct EducationalInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: ProfileViewModel

    @State private var university = ""
    @State private var major = ""
    @State private var showSaveAlert = false

    var hasChanges: Bool {
        university != (vm.user?.university ?? "") ||
        major != (vm.user?.major      ?? "")
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                navBar
                    .padding(.bottom, 24)

                sectionLabel("EDUCATIONAL INFO")
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                VStack(spacing: 0) {
                    SettingsFormField(
                        icon: "building.columns.fill",
                        iconColor: Color(hex: "#D85A30"),
                        iconBg: Color(hex: "#FFF0EB"),
                        label: "UNIVERSITY",
                        text: $university
                    )
                    Divider().padding(.leading, 72)
                    SettingsFormField(
                        icon: "graduationcap.fill",
                        iconColor: Color(hex: "#6B3FD4"),
                        iconBg: Color(hex: "#EDE7FF"),
                        label: "MAJOR",
                        text: $major
                    )
                    Divider().padding(.leading, 72)
                    SettingsReadOnlyField(
                        icon: "star.fill",
                        iconColor: Color(hex: "#BA7517"),
                        iconBg: Color(hex: "#FAEEDA"),
                        label: "INTERESTS",
                        value: vm.user?.interests
                                     .filter { !$0.isEmpty }
                                     .joined(separator: ", ")
                                   ?? "Not set"
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
            university = vm.user?.university ?? ""
            major      = vm.user?.major      ?? ""
        }
        .alert("Save Changes?", isPresented: $showSaveAlert) {
            Button("Save") {
                Task {
                    if university != vm.user?.university {
                        await vm.updateUniversity(university)
                    }
                    if major != vm.user?.major {
                        await vm.updateMajor(major)
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
            Text("Educational Info")
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
        interests: ["iOS", "Swift", "SwiftUI"],
        createdAt: Date(),
        fcmToken: ""
    )
    return NavigationStack {
        EducationalInfoView(vm: vm)
    }
}
