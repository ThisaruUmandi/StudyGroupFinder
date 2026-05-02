//
//  SettingsReadOnlyField.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-02.
//

import SwiftUI

struct SettingsReadOnlyField: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            KIconBox(
                icon: icon,
                iconColor: iconColor,
                bgColor: iconBg,
                size: 42,
                cornerRadius: 12,
                iconSize: 17
            )
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    VStack(spacing: 0) {
        SettingsReadOnlyField(
            icon: "book.fill",
            iconColor: Color(hex: "#1D9E75"),
            iconBg: Color(hex: "#E0F5EE"),
            label: "SESSION TITLE",
            value: "Swift Language Review"
        )
        Divider().padding(.leading, 72)
        SettingsReadOnlyField(
            icon: "calendar",
            iconColor: Color(hex: "#0300BF"),
            iconBg: Color(hex: "#EEEEFF"),
            label: "DATE",
            value: "01 May 2026"
        )
    }
    .background(Color.white)
    .cornerRadius(14)
    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    .padding()
}
