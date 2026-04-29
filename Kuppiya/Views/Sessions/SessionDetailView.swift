//
//  SessionDetailView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-29.
//

import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let session: StudySession

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 16) {
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
                    Text("Session Detail")
                        .font(.system(size: 17, weight: .semibold))
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 48))
                    .foregroundColor(Color(hex: "#0300BF").opacity(0.3))
                Text(session.title)
                    .font(.system(size: 20, weight: .bold))
                Text("Session detail coming soon")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
