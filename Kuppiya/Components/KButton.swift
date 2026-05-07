//
//  KButton.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

enum KButtonStyle {
    case primary
    case secondary
    case danger
    case ghost
}

struct KButton: View {
    let title: String
    var style: KButtonStyle = .primary
    var icon: String? = nil
    var isLoading: Bool = false
    var isFullWidth: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(style == .primary ? .white : .brandPrimary)
                } else {
                    HStack(spacing: 8) {
                        if let icon {
                            Image(systemName: icon)
                                .font(.system(size: 14,
                                              weight: .medium))
                        }
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(labelColor)
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: 52)
            .padding(.horizontal, isFullWidth ? 0 : 24)
            .background(bgColor)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .disabled(isLoading)
    }

    private var bgColor: Color {
        switch style {
        case .primary: return Color(hex: "#1A1ADB")
        case .secondary: return Color(.systemBackground)
        case .danger: return Color(.systemBackground)
        case .ghost: return .clear
        }
    }
    private var labelColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .brandPrimary
        case .danger: return Color(hex: "#D4537E")
        case .ghost: return .brandPrimary
        }
    }
    private var borderColor: Color {
        switch style {
        case .primary: return .clear
        case .secondary: return .brandPrimary
        case .danger: return Color(hex: "#D4537E")
        case .ghost: return .clear
        }
    }
    private var borderWidth: CGFloat {
        switch style {
        case .primary, .ghost: return 0
        default: return 1.5
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {

            KButton(title: "Primary") {
                print("Primary tapped")
            }

            KButton(title: "Secondary", style: .secondary) {
                print("Secondary tapped")
            }

            KButton(title: "Danger", style: .danger) {
                print("Danger tapped")
            }

            KButton(title: "Ghost", style: .ghost) {
                print("Ghost tapped")
            }

//            KButton(
//                title: "With Icon",
//                icon: "arrow.right",
//                style: .primary
//            ) {
//                print("Icon tapped")
//            }

            KButton(
                title: "Loading...",
                style: .primary,
                isLoading: true
            ) {}

            KButton(
                title: "Small Button",
                style: .secondary,
                isFullWidth: false
            ) {
                print("Small tapped")
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
