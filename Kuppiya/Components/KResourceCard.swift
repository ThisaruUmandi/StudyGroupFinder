//
//  KResourceCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//

import SwiftUI

struct KResourceCard: View {
    let resource: Resource
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon
                KIconBox(
                    icon: resource.iconName,
                    iconColor: Color(hex: resource.iconColor),
                    bgColor: Color(hex: resource.iconColor).opacity(0.12),
                    size: 46,
                    cornerRadius: 12,
                    iconSize: 20
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Image(systemName: "person")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text(resource.uploaderName)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text("•")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                        Text(resource.formattedDate)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "ellipsis")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        KResourceCard(resource: Resource(
            resourceId: "1", groupId: "g1",
            title: "iOS_Lec_Note.pdf",
            type: "document", url: "",
            fileExtension: "pdf",
            uploadedBy: "uid1", uploaderName: "Alex Chen",
            createdAt: Date(), likedBy: [], savedBy: []
        )) {}

        KResourceCard(resource: Resource(
            resourceId: "2", groupId: "g1",
            title: "iOS_Lec_Note.png",
            type: "media", url: "",
            fileExtension: "png",
            uploadedBy: "uid1", uploaderName: "Alex Chen",
            createdAt: Date(), likedBy: [], savedBy: []
        )) {}

        KResourceCard(resource: Resource(
            resourceId: "3", groupId: "g1",
            title: "https://iOS_Lec_Note.com",
            type: "link", url: "https://iOS_Lec_Note.com",
            fileExtension: "",
            uploadedBy: "uid1", uploaderName: "Alex Chen",
            createdAt: Date(), likedBy: [], savedBy: []
        )) {}
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
