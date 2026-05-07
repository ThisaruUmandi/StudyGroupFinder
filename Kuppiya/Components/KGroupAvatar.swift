//
//  KGroupAvatar.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-22.
//

import SwiftUI

struct KGroupAvatar: View {
    var imageURL: String? = nil
    var name: String = ""
    var size: CGFloat = 46

    var body: some View {
        ZStack {
            Circle()
                .fill(avatarColor)
                .frame(width: size, height: size)

            if let urlStr = imageURL,
               !urlStr.isEmpty,
               let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    case .failure:
                        defaultIcon
                    case .empty:
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(size / 46)
                    @unknown default:
                        defaultIcon
                    }
                }
                .frame(width: size, height: size)
                .clipShape(Circle())
            } else {
                defaultIcon
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    // ← Group icon instead of letter
    private var defaultIcon: some View {
        Image(systemName: "person.2.fill")
            .font(.system(size: size * 0.35, weight: .medium))
            .foregroundColor(.white.opacity(0.9))
    }

    private var avatarColor: Color {
        let colors: [Color] = [
            Color(hex: "#1D9E75"), Color(hex: "#D85A30"),
            Color(hex: "#378ADD"), Color(hex: "#7F77DD"),
            Color(hex: "#D4537E"), Color(hex: "#BA7517"),
            Color(hex: "#534AB7"), Color(hex: "#0F6E56")
        ]
        guard !name.isEmpty else { return colors[0] }
        return colors[abs(name.hashValue) % colors.count]
    }
}

#Preview {
    HStack(spacing: 12) {
        KGroupAvatar(name: "iOS Dev", size: 50)
        KGroupAvatar(name: "Math Study", size: 50)
        KGroupAvatar(name: "CS Group", size: 50)
    }.padding()
}
