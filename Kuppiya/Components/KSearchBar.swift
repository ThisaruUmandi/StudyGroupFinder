//
//  KSearchBar.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct KSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(hex: "#0300BF"))
                //.foregroundColor(Color.gray.opacity(0.5))
                .font(.system(size: 16))

            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .autocorrectionDisabled()
                .foregroundColor(Color(hex: "#0300BF"))

            Spacer()

            Button {
                // mic action
            } label: {
                Image(systemName: "mic.fill")
                    .foregroundColor(Color(hex: "#0300BF"))
                    //.foregroundColor(Color.gray.opacity(0.6))
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(Color.white)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)               .stroke(Color(hex: "#1A1ADB"), lineWidth: 1.5)
                //.stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
        )
    }
}

#Preview {
    KSearchBar(text: .constant(""))
        .padding()
        //.background(Color.gray.opacity(0.1))
}
