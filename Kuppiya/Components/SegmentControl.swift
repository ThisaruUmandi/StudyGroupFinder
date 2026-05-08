//
//  SegmentControl.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-29.
//

import SwiftUI

struct KSegmentControl: View {
    let options: [String]
    @Binding var selected: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options.indices, id: \.self) { i in
                Button {
                    selected = i
                } label: {
                    Text(options[i])
                        .font(.system(size: 13, weight: selected == i ? .semibold : .semibold))
                        .foregroundColor(selected == i ? .white : .secondary)
                        .frame(maxWidth: .infinity) 
                        .padding(.horizontal, 35)
                        .padding(.vertical, 10)
                        .background(selected == i ? Color(hex: "#0300BF") : Color.clear)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(3)
        .background(Color(UIColor.systemBackground))
        .overlay(Capsule().stroke(Color(.systemGray4), lineWidth: 1))
        .clipShape(Capsule())
    }
}

#Preview {
    @Previewable @State var selected = 0
    KSegmentControl(
        options: ["Upcoming", "Past Sessions"],
        selected: $selected
    )
    .padding()
}
