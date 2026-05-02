//
//  KInfoRow.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-01.
//

import SwiftUI

struct KInfoRow: View {
    let icon: String
    let iconColor: Color
    let bgColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            KIconBox(
                icon: icon,
                iconColor: iconColor,
                bgColor: bgColor,
                size: 34,
                cornerRadius: 17,
                iconSize: 14
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.3)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(14)
    }
}

#Preview {
    VStack(spacing: 0) {
        KInfoRow(
            icon: "book.fill",
            iconColor: Color(hex: "#1D9E75"),
            bgColor: Color(hex: "#E0F5EE"),
            label: "SESSION TITLE",
            value: "Swift Language Review"
        )
        Divider().padding(.leading, 54)
        KInfoRow(
            icon: "calendar",
            iconColor: Color(hex: "#0300BF"),
            bgColor: Color(hex: "#EEEEFF"),
            label: "DATE",
            value: "01 Mar 2026"
        )
    }
    .background(Color.white)
    .cornerRadius(14)
    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    .padding()
}
