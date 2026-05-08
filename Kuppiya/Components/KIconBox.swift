//
//  KIconBox.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-21.
//

import SwiftUI

struct KIconBox: View {
    let icon: String
    let iconColor: Color
    let bgColor: Color
    var size: CGFloat    = 40
    var cornerRadius: CGFloat = 10
    var iconSize: CGFloat = 16

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: iconSize, weight: .medium))
            .foregroundColor(iconColor)
            .frame(width: size, height: size)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
