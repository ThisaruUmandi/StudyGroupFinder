//
//  SocialButton.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-16.
//

import SwiftUI

struct SocialButton: View {
    let imageName: String
    var isSystemImage: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: 52, height: 52)
                if isSystemImage {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 23)
                        .foregroundColor(.black)
                } else {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        SocialButton(imageName: "google") {
            print("Google tapped")
        }
        SocialButton(imageName: "apple.logo", isSystemImage: true) {
            print("Apple tapped")
        }
    }
    .padding()
}
