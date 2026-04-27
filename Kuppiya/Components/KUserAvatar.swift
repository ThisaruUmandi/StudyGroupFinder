//
//  KUserAvatar.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct KUserAvatar: View {
    var imageURL: String? = nil
    var name: String      = ""
    var size: CGFloat     = 46

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
                        letterView
                    case .empty:
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(size / 46)
                    @unknown default:
                        letterView
                    }
                }
                .frame(width: size, height: size)
                .clipShape(Circle())
            } else {
                letterView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    // MARK: - First letter
    private var letterView: some View {
        Text(firstLetter)
            .font(.system(
                size: size * 0.4,
                weight: .bold))
            .foregroundColor(.white)
    }

    private var firstLetter: String {
        String(name.prefix(1).uppercased())
    }

    // MARK: - Consistent color from name
    private var avatarColor: Color {
        let colors: [Color] = [
            Color(hex: "#1D9E75"),
            Color(hex: "#D85A30"),
            Color(hex: "#378ADD"),
            Color(hex: "#7F77DD"),
            Color(hex: "#D4537E"),
            Color(hex: "#BA7517"),
            Color(hex: "#534AB7"),
            Color(hex: "#0F6E56")
        ]
        guard !name.isEmpty else {
            return colors[0]
        }
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // With image URL
        KUserAvatar(
            imageURL: "https://example.com/photo.jpg",
            name: "Kaveen",
            size: 60
        )

        // No image - shows letter
        KUserAvatar(name: "Kaveen", size: 60)
        KUserAvatar(name: "Jordan", size: 60)
        KUserAvatar(name: "Emma", size: 60)

        // Different sizes
        HStack(spacing: 12) {
            KUserAvatar(name: "Kaveen", size: 30)
            KUserAvatar(name: "Kaveen", size: 46)
            KUserAvatar(name: "Kaveen", size: 60)
            KUserAvatar(name: "Kaveen", size: 80)
            KUserAvatar(name: "Kaveen", size: 100)
        }
    }
    .padding()
}
