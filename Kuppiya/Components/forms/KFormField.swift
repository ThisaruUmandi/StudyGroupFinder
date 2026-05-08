//
//  KFormField.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-01.
//

import SwiftUI

struct KFormField: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let placeholder: String
    let hint: String
    @Binding var text: String
    var isMultiline: Bool = false

    var body: some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: 14) {
            KIconBox(
                icon: icon,
                iconColor: iconColor,
                bgColor: iconBg,
                size: 42,
                cornerRadius: 12,
                iconSize: 18
            )
            .padding(.top, isMultiline ? 4 : 0)

            VStack(alignment: .leading, spacing: 3) {
                Text(placeholder)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)

                if isMultiline {
                    ZStack(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(hint)
                                .font(.system(size: 14))
                                .foregroundColor(Color(.placeholderText))
                        }
                        TextEditor(text: $text)
                            .frame(minHeight: 60)
                            .font(.system(size: 14))
                            .scrollContentBackground(.hidden)
                            .padding(.leading, -4)
                    }
                } else {
                    TextField(hint, text: $text)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    VStack(spacing: 0) {
        KFormField(
            icon: "book.fill",
            iconColor: Color(hex: "#1D9E75"),
            iconBg: Color(hex: "#E0F5EE"),
            placeholder: "SESSION TITLE",
            hint: "e.g. Swift Language Review",
            text: .constant("")
        )
        Divider().padding(.leading, 72)
        KFormField(
            icon: "text.alignleft",
            iconColor: Color(hex: "#D85A30"),
            iconBg: Color(hex: "#FFF0EB"),
            placeholder: "DESCRIPTION",
            hint: "e.g. Group details, goals...",
            text: .constant(""),
            isMultiline: true
        )
    }
    .background(Color(UIColor.systemBackground))
    .cornerRadius(14)
    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    .padding()
}
