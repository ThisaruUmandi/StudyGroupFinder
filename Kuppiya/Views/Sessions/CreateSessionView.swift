//
//  CreateSessionView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-29.
//

import SwiftUI

struct CreateSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    let group: StudyGroup

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("New Session")
                        .font(.system(size: 17, weight: .semibold))
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "[calendar.badge.plus](http://calendar.badge.plus)")
                        .font(.system(size: 52))
                        .foregroundColor(Color(hex: "#0300BF").opacity(0.25))
                    Text("Create Session")
                        .font(.system(size: 20, weight: .bold))
                    Text("Coming soon")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    CreateSessionView(group: StudyGroup(
        groupId: "preview",
        name: "iOS Dev",
        subject: "iOS Development",
        major: "Computer Science",
        description: "Test",
        createdBy: "uid1",
        members: ["uid1"],
        privacy: "public",
        university: "NIBM",
        createdAt: Date()
    ))
    .environmentObject(AuthViewModel())
}
