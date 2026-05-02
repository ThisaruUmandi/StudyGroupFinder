//
//  KSessionCard.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import SwiftUI

struct KSessionCard: View {
    let session: StudySession
    var onJoinTap: (() -> Void)? = nil

    // Derive from time — no Firestore status needed
    private var isOngoing: Bool {
        let now = Date()
        let end = session.date.addingTimeInterval(2 * 60 * 60)
        return now >= session.date && now <= end
    }

    // Purple for ongoing, brand blue for upcoming
    private var cardColor: Color {
        isOngoing ? Color(hex: "#5B3FBF") : Color(hex: "#0300BF")
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(cardColor)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    KTagPill(text: isOngoing ? "ONGOING" : "NEXT SESSION")
                    KTagPill(text: session.groupName.prefix(4).uppercased())
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 14))
                }

                Text(session.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text("\(session.groupName.uppercased()) · \(session.type.uppercased())")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(1)

                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 13))
                        Text(session.formattedDateTime)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()

                    if session.isOnline {
                        Button {
                            onJoinTap?()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Join Now")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(cardColor)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(cardColor)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                    } else {
                        Button {
                            openInMaps()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(cardColor)
                                Text(session.location.isEmpty ? "Get Directions" : session.location)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(cardColor)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                    }
                }
            }
            .padding(18)
        }
    }

    private func openInMaps() {
        let lat  = session.latitude
        let lon  = session.longitude
        let name = session.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(name)&ll=\(lat),\(lon)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Tag Pill

struct KTagPill: View {
    let text: String
    var bgColor: Color   = Color.white.opacity(0.2)
    var textColor: Color = .white

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(bgColor)
            .cornerRadius(20)
    }
}

// MARK: - Empty card

struct KEmptySessionCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(hex: "#0300BF").opacity(0.08))
                .frame(height: 90)
            Text("No upcoming sessions")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Previews

#Preview("Ongoing Online") {
    KSessionCard(session: StudySession(
        sessionId: "1",
        groupId: "g1",
        groupName: "iOS Dev",
        title: "Advanced iOS Development",
        description: "Test",
        date: Date().addingTimeInterval(-1800),
        startTime: "16:30",
        type: "online",
        joinLink: "https://meet.google.com/abc-defg-hij",
        location: "",
        latitude: 0,
        longitude: 0,
        status: "upcoming",
        createdBy: "uid1",
        createdByName: "Kaveen",
        attendees: []
    ))
    .padding()
}

#Preview("Ongoing Physical") {
    KSessionCard(session: StudySession(
        sessionId: "2",
        groupId: "g1",
        groupName: "Math Study",
        title: "Calculus Review",
        description: "Test",
        date: Date().addingTimeInterval(-1800),
        startTime: "14:00",
        type: "physical",
        joinLink: "",
        location: "NIBM Library",
        latitude: 6.9271,
        longitude: 79.8612,
        status: "upcoming",
        createdBy: "uid1",
        createdByName: "Umandi",
        attendees: []
    ))
    .padding()
}

#Preview("Upcoming") {
    KSessionCard(session: StudySession(
        sessionId: "3",
        groupId: "g1",
        groupName: "iOS Dev",
        title: "Advanced iOS Development",
        description: "Test",
        date: Date().addingTimeInterval(3600),
        startTime: "16:30",
        type: "online",
        joinLink: "https://meet.google.com/abc-defg-hij",
        location: "",
        latitude: 0,
        longitude: 0,
        status: "upcoming",
        createdBy: "uid1",
        createdByName: "Kaveen",
        attendees: []
    ))
    .padding()
}
