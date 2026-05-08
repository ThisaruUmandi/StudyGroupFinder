//
//  StudyProgress.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import Foundation
import FirebaseFirestore

// MARK: - Group Stats (per user per group)
struct GroupStat: Codable {
    var uid: String
    var groupId: String
    var username: String

    // Points
    var totalPoints: Int = 0
    var weeklyPoints: Int = 0
    var qnaPoints: Int = 0
    var pollPoints: Int = 0
    var sessionPoints: Int = 0

    // Streak
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastActiveDate: Date = Date()
    var lastWeeklyReset: Date = Date()

    // Study hours
    var totalStudyHours: Double = 0
    var weeklyStudyHours: Double = 0
    var weeklyGoalHours: Double = 3.0

    // Sessions
    var sessionsAttended: Int = 0
    var totalSessions: Int = 0
    var attendanceRate: Double = 0

    // Polls
    var totalPollsVoted: Int = 0
    var totalCorrect: Int = 0
    var pollAccuracy: Double = 0

    // Q&A
    var totalAnswers: Int = 0
    var bestAnswers: Int = 0

    // Weekly activity map
    var weeklyActivity:   [String: Double] = [
        "Mon": 0, "Tue": 0, "Wed": 0,
        "Thu": 0, "Fri": 0, "Sat": 0, "Sun": 0
    ]

    // Computed
    var weeklyGoalProgress: Double {
        guard weeklyGoalHours > 0 else { return 0 }
        return min(weeklyStudyHours / weeklyGoalHours, 1.0)
    }
    var weeklyGoalPct: Int { Int(weeklyGoalProgress * 100) }
    var pollAccuracyPct: Int { Int(pollAccuracy * 100) }
    var attendancePct: Int { Int(attendanceRate * 100) }

    static func docId(groupId: String, uid: String) -> String {
        "\(groupId)_\(uid)"
    }

    static func empty(uid: String, groupId: String, username: String) -> GroupStat {
        GroupStat(uid: uid, groupId: groupId, username: username)
    }
}

// MARK: - User Stats (global aggregated)
struct UserStat: Codable, Identifiable {
    var id: String  { uid }
    var uid: String
    var username: String
    var profileImage: String  = ""
    var totalPoints: Int  = 0
    var weeklyPoints: Int = 0
    var totalStudyHours: Double  = 0
    var lastUpdated: Date = Date()
}

// MARK: - Leaderboard Entry
struct LeaderboardEntry: Identifiable {
    var id: String { uid }
    var uid: String
    var username: String
    var profileImage: String
    var totalPoints: Int
    var weeklyPoints: Int
    var rank: Int
    // Group leaderboard extras
    var qnaPoints: Int = 0
    var pollPoints: Int = 0
    var sessionPoints: Int = 0
}
