//
//  ReviewSheet.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-23.
//

import SwiftUI

struct ReviewSheet: View {
    @Binding var rating: Int
    @Binding var reviewText: String
    var title: String = "How is Your Group ?"
    var subtitle: String = "Please take a moment to rate and review\nyour experience in this group."
    var placeholder: String = "Type a review"
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 24) {

            // Handle
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            // Title
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)

            // Subtitle
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Star rating
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        rating = star
                    } label: {
                        Image(systemName: star <= rating
                              ? "star.fill" : "star")
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: "#F5A623"))
                            .animation(.spring(duration: 0.2), value: rating)
                    }
                }
            }

            // Text input + submit
            HStack(spacing: 12) {
                TextField(placeholder, text: $reviewText)
                    .font(.system(size: 14))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.systemGroupedBackground))
                    .cornerRadius(12)

                Button(action: onSubmit) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#6B3FD4"))
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .presentationDetents([.fraction(0.45)])
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    @Previewable @State var rating = 3
    @Previewable @State var reviewText = ""

    ReviewSheet(rating: $rating, reviewText: $reviewText) {
        print("Submitted")
    }
}
