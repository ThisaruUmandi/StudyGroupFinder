//
//  KInitialAvatar.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct KInitialsAvatar: View {
    let name: String
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(avatarColor)
                .frame(width: size, height: size)
            Text(initials)
                .font(.system(
                    size: size * 0.32,
                    weight: .bold))
                .foregroundColor(.white)
        }
    }

    private var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
    }

    private var avatarColor: Color {
        let colors: [Color] = [
            Color(hex: "#1D9E75"),
            Color(hex: "#D85A30"),
            Color(hex: "#378ADD"),
            Color(hex: "#7F77DD"),
            Color(hex: "#D4537E")
        ]
        return colors[abs(name.hashValue) % colors.count]
    }
}
