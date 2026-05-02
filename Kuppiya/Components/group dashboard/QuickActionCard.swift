//
//  QuickActionCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct QuickActionCard: View {
    let imageName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuickActionCard(imageName: "session", label: "Sessions") { }
        .frame(width: 100)
        .padding()
}
