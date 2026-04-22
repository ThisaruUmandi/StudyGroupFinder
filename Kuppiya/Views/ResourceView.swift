//
//  ResourceView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-23.
//

import SwiftUI

struct ResourceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    let group: StudyGroup

    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06),
                                radius: 4, x: 0, y: 2)
                }
                Text("Resources")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()
            Text("Resources — Coming Soon")
                .foregroundColor(.secondary)
            Spacer()
        }
        .navigationBarHidden(true)
    }
}
