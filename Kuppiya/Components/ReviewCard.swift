//
//  ReviewCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-27.
//

import SwiftUI

struct ReviewCard: View {
    let review: GroupReview

    @State private var authorName = ""

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            KUserAvatar(name: authorName, size: 44)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .center) {
                    Text(authorName.isEmpty ? "Loading..." : authorName)
                        .font(.system(size: 13, weight: .semibold))
                    Spacer()
                    Text(String(format: "%.1f", Double(review.rating)))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    starsRow(review.rating)
                }
                Text(review.review)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .task { await fetchAuthorName() }
    }

    private func starsRow(_ rating: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: i < rating ? "star.fill" : "star")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#F5A623"))
            }
        }
    }

    private func fetchAuthorName() async {
        guard !review.authorId.isEmpty else { return }
        do {
            let user = try await FirestoreService.shared.fetchUser(uid: review.authorId)
            authorName = user?.username ?? "Unknown"
        } catch {
            authorName = "Unknown"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ReviewCard(review: GroupReview(
            authorId: "Karan Peak",
            rating: 4,
            review: "Dr. Blackwell is a knowledgeable and caring cardiologist who explains everything clearly and takes time to listen. Highly recommended.",
            createdAt: Date()
        ))
        ReviewCard(review: GroupReview(
            authorId: "Jordan Lee",
            rating: 5,
            review: "Great group energy and very focused sessions. Would recommend to anyone serious about the subject.",
            createdAt: Date()
        ))
    }
    .padding()
}
