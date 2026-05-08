//
//  ReactionPicker.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import SwiftUI

struct ReactionPicker: View {
    let emojis = ["👍","❤️","😂","😮","😢","🔥"]
    let onPick: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(emojis, id: \.self) { emoji in
                Button {
                    onPick(emoji)
                } label: {
                    Text(emoji)
                        .font(.system(size: 26))
                        .padding(8)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08),
                                radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
        )
    }
}
