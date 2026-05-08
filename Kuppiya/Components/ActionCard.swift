//
//  ActionCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct KActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let bgColor: Color
    let iconColor: Color
    let action: () -> Void

    init(
        icon: String,
        title: String,
        subtitle: String,
        bgColor: Color,
        iconColor: Color = Color(hex: "#0300BF"),
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle  = subtitle
        self.bgColor = bgColor
        self.iconColor = iconColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.08))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A2E"))
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#1A1A2E").opacity(0.6))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(bgColor)
            .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        KActionCard(
            icon: "book.fill",
            title: "My Courses",
            subtitle: "Continue learning",
            bgColor: Color(hex: "#EDE7FF")
        ) {
            print("My Courses tapped")
        }

        KActionCard(
            icon: "person.3.fill",
            title: "Study Groups",
            subtitle: "Join discussions",
            bgColor: Color(hex: "#E8F7F1")
        ) {
            print("Study Groups tapped")
        }

        KActionCard(
            icon: "chart.bar.fill",
            title: "Progress",
            subtitle: "Track performance",
            bgColor: Color(hex: "#FFF4E5")
        ) {
            print("Progress tapped")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
#Preview {
    VStack(spacing: 16) {
        KActionCard(
            icon: "book.fill",
            title: "My Courses",
            subtitle: "Continue learning",
            bgColor: Color(hex: "#EDE7FF")
        ) {
            print("My Courses tapped")
        }

        KActionCard(
            icon: "person.3.fill",
            title: "Study Groups",
            subtitle: "Join discussions",
            bgColor: Color(hex: "#E8F7F1")
        ) {
            print("Study Groups tapped")
        }

        KActionCard(
            icon: "chart.bar.fill",
            title: "Progress",
            subtitle: "Track performance",
            bgColor: Color(hex: "#FFF4E5")
        ) {
            print("Progress tapped")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
