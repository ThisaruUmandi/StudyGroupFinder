//
//  CustomTextField.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-16.
//

import SwiftUI

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool
    var showToggle: Bool
    @Binding var showPassword: Bool

    init(icon: String, placeholder: String,
         text: Binding<String>, isSecure: Bool,
         showToggle: Bool,
         showPassword: Binding<Bool> = .constant(false)) {
        self.icon = icon
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.showToggle = showToggle
        self._showPassword = showPassword
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 15))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .autocapitalization(.none)
                    .keyboardType(
                        placeholder == "Email"
                        ? .emailAddress : .default)
            }

            if showToggle {
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 55)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .cornerRadius(30)
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @State var showPassword = false

    VStack(spacing: 16) {
        CustomTextField(icon: "person", placeholder: "Username",
                        text: $text, isSecure: false, showToggle: false)
        CustomTextField(icon: "envelope", placeholder: "Email",
                        text: $text, isSecure: false, showToggle: false)
        CustomTextField(icon: "lock", placeholder: "Password",
                        text: $text, isSecure: !showPassword,
                        showToggle: true, showPassword: $showPassword)
    }
    .padding()
}
