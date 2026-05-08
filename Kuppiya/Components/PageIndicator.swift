//
//  PageIndicator.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-05.
//

import SwiftUI

struct PageIndicatorView: View {

    let currentIndex: Int   // 0-based
    let totalPages: Int

    private let activeColor  = Color(hex: "0300BF")
    private let inactiveColor = Color(hex: "0300BF").opacity(0.3)

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalPages, id: \.self) { index in
                if index == currentIndex {
                    Capsule()
                        .fill(activeColor)
                        .frame(width: 32, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentIndex)
                } else {
                    Circle()
                        .fill(inactiveColor)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentIndex)
    }
}

#Preview {
    PageIndicatorView(currentIndex: 0, totalPages: 5)
        .padding()
}
