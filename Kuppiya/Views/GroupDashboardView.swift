//
//  GroupDashboardView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct GroupDashboardView: View {
    let group: StudyGroup
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()

            VStack {
                Text(group.name)
                    .font(.system(size: 22, weight: .bold))
                Text("Group Dashboard — coming soon")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
