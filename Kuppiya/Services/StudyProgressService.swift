//
//  StudyProgressService.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-06.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class StudyProgressService {
    static let shared = StudyProgressService()
    private let db = Firestore.firestore()

    // MARK: - Document references
    private func groupStatRef(groupId: String, uid: String) -> DocumentReference {
        db.collection("groupStats")
          .document(GroupStat.docId(groupId: groupId, uid: uid))
    }

    private func userStatRef(uid: String) -> DocumentReference {
        db.collection("userStats").document(uid)
    }

    // MARK: - Initialize when user joins group
    func initGroupStat(
        uid: String, groupId: String, username: String
    ) async throws {
        let ref = groupStatRef(groupId: groupId, uid: uid)
        let snap = try await ref.getDocument()
        guard !snap.exists else { return }

        let empty = GroupStat.empty(uid: uid, groupId: groupId, username: username)
        try await ref.setData(encode(empty))

        // Also init userStats if not exists
        let userSnap = try await userStatRef(uid: uid).getDocument()
        if !userSnap.exists {
            try await userStatRef(uid: uid).setData([
                "uid": uid,
                "username": username,
                "profileImage": "",
                "totalPoints": 0,
                "weeklyPoints": 0,
                "totalStudyHours": 0.0,
                "lastUpdated": Timestamp(date: Date())
            ])
        }
    }

    // MARK: - Fetch my group stat
    func fetchGroupStat(uid: String, groupId: String) async throws -> GroupStat {
        let snap = try await groupStatRef(groupId: groupId, uid: uid).getDocument()
        guard let data = snap.data() else {
            return GroupStat.empty(uid: uid, groupId: groupId, username: "")
        }
        return decodeGroupStat(data: data, uid: uid, groupId: groupId)
    }

    // MARK: - Fetch group leaderboard
    func fetchGroupLeaderboard(
        groupId: String, weekly: Bool = false
    ) async throws -> [LeaderboardEntry] {
        let sortField = weekly ? "weeklyPoints" : "totalPoints"
        let snap = try await db
            .collection("groupStats")
            .whereField("groupId", isEqualTo: groupId)
            .order(by: sortField, descending: true)
            .limit(to: 50)
            .getDocuments()

        return snap.documents.enumerated().compactMap { index, doc in
            let d = doc.data()
            guard
                let uid = d["uid"]          as? String,
                let username = d["username"]      as? String
            else { return nil }
            return LeaderboardEntry(
                uid: uid,
                username: username,
                profileImage: d["profileImage"] as? String ?? "",
                totalPoints:  d["totalPoints"]  as? Int ?? 0,
                weeklyPoints: d["weeklyPoints"] as? Int ?? 0,
                rank: index + 1,
                qnaPoints: d["qnaPoints"]    as? Int ?? 0,
                pollPoints: d["pollPoints"]   as? Int ?? 0,
                sessionPoints: d["sessionPoints"] as? Int ?? 0
            )
        }
    }

    // MARK: - Fetch global leaderboard
    func fetchGlobalLeaderboard(
        weekly: Bool = false
    ) async throws -> [LeaderboardEntry] {
        let sortField = weekly ? "weeklyPoints" : "totalPoints"
        let snap = try await db
            .collection("userStats")
            .order(by: sortField, descending: true)
            .limit(to: 100)
            .getDocuments()

        return snap.documents.enumerated().compactMap { index, doc in
            let d = doc.data()
            guard
                let uid = d["uid"] as? String,
                let username = d["username"] as? String
            else { return nil }
            return LeaderboardEntry(
                uid: uid,
                username: username,
                profileImage: d["profileImage"] as? String ?? "",
                totalPoints: d["totalPoints"]  as? Int ?? 0,
                weeklyPoints: d["weeklyPoints"] as? Int ?? 0,
                rank: index + 1
            )
        }
    }

    // MARK: - Update streak
    func updateStreak(uid: String, groupId: String) async throws {
        let ref = groupStatRef(groupId: groupId, uid: uid)
        let snap = try await ref.getDocument()
        let data = snap.data() ?? [:]

        let lastActive  = (data["lastActiveDate"] as? Timestamp)?.dateValue()
                          ?? Date.distantPast
        let current = data["currentStreak"] as? Int ?? 0
        let longest = data["longestStreak"]  as? Int ?? 0
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(lastActive)
        let isYesterday = calendar.isDateInYesterday(lastActive)

        if isToday { return }
        let newStreak  = isYesterday ? current + 1 : 1
        let newLongest = max(longest, newStreak)

        try await ref.setData([
            "currentStreak": newStreak,
            "longestStreak": newLongest,
            "lastActiveDate": Timestamp(date: Date())
        ], merge: true)
    }

    // MARK: - Check and reset weekly if needed
    func checkAndResetWeekly(uid: String, groupId: String) async throws {
        let ref  = groupStatRef(groupId: groupId, uid: uid)
        let snap = try await ref.getDocument()
        let data = snap.data() ?? [:]

        let lastReset = (data["lastWeeklyReset"] as? Timestamp)?.dateValue()
                          ?? Date.distantPast
        let calendar = Calendar.current
        let lastWeek = calendar.component(.weekOfYear, from: lastReset)
        let currentWeek = calendar.component(.weekOfYear, from: Date())

        guard lastWeek != currentWeek else { return }

        try await ref.setData([
            "weeklyPoints":     0,
            "weeklyStudyHours": 0.0,
            "weeklyActivity": [
                "Mon": 0.0, "Tue": 0.0, "Wed": 0.0,
                "Thu": 0.0, "Fri": 0.0, "Sat": 0.0, "Sun": 0.0
            ],
            "lastWeeklyReset": Timestamp(date: Date())
        ], merge: true)

        // Also reset userStats weekly
        try await userStatRef(uid: uid).setData([
            "weeklyPoints": 0
        ], merge: true)
    }

    // MARK: - Set weekly goal
    func setWeeklyGoal(
        uid: String, groupId: String, hours: Double
    ) async throws {
        try await groupStatRef(groupId: groupId, uid: uid)
            .setData(["weeklyGoalHours": hours], merge: true)
    }

    // MARK: - Log session attendance
    func logSessionAttendance(
        uid: String, groupId: String,
        username: String, durationHours: Double
    ) async throws {
        let day = weekdayKey()
        let pts = 20

        try await groupStatRef(groupId: groupId, uid: uid).setData([
            "uid": uid,
            "groupId": groupId,
            "username": username,
            "sessionsAttended": FieldValue.increment(Int64(1)),
            "totalStudyHours": FieldValue.increment(durationHours),
            "weeklyStudyHours": FieldValue.increment(durationHours),
            "weeklyActivity.\(day)": FieldValue.increment(durationHours),
            "sessionPoints": FieldValue.increment(Int64(pts)),
            "totalPoints": FieldValue.increment(Int64(pts)),
            "weeklyPoints": FieldValue.increment(Int64(pts))
        ], merge: true)

        try await updateUserStats(uid: uid, pointsDelta: pts, hoursDelta: durationHours)
        try await updateStreak(uid: uid, groupId: groupId)
    }

    // MARK: - Log poll vote
    func logPollVote(
        uid: String, groupId: String,
        username: String, isCorrect: Bool
    ) async throws {
        let pts = 8
        let ref = groupStatRef(groupId: groupId, uid: uid)

        // Fetch current to recalculate accuracy
        let snap = try await ref.getDocument()
        let data = snap.data() ?? [:]
        let voted = (data["totalPollsVoted"] as? Int ?? 0) + 1
        let correct = (data["totalCorrect"]    as? Int ?? 0) + (isCorrect ? 1 : 0)
        let accuracy = Double(correct) / Double(voted)

        var updates: [String: Any] = [
            "uid": uid,
            "groupId": groupId,
            "username": username,
            "totalPollsVoted": FieldValue.increment(Int64(1)),
            "pollPoints": FieldValue.increment(Int64(pts)),
            "totalPoints": FieldValue.increment(Int64(pts)),
            "weeklyPoints": FieldValue.increment(Int64(pts)),
            "pollAccuracy": accuracy
        ]
        if isCorrect {
            updates["totalCorrect"] = FieldValue.increment(Int64(1))
        }

        try await ref.setData(updates, merge: true)
        try await updateUserStats(uid: uid, pointsDelta: pts, hoursDelta: 0)
        try await updateStreak(uid: uid, groupId: groupId)
    }

    // MARK: - Log answer
    func logAnswer(
        uid: String, groupId: String, username: String
    ) async throws {
        let pts = 15
        try await groupStatRef(groupId: groupId, uid: uid).setData([
            "uid": uid,
            "groupId": groupId,
            "username": username,
            "totalAnswers": FieldValue.increment(Int64(1)),
            "qnaPoints": FieldValue.increment(Int64(pts)),
            "totalPoints": FieldValue.increment(Int64(pts)),
            "weeklyPoints": FieldValue.increment(Int64(pts))
        ], merge: true)

        try await updateUserStats(uid: uid, pointsDelta: pts, hoursDelta: 0)
        try await updateStreak(uid: uid, groupId: groupId)
    }

    // MARK: - Log best answer
    func logBestAnswer(
        uid: String, groupId: String, username: String
    ) async throws {
        let pts = 25
        try await groupStatRef(groupId: groupId, uid: uid).setData([
            "uid": uid,
            "groupId": groupId,
            "username": username,
            "bestAnswers": FieldValue.increment(Int64(1)),
            "qnaPoints": FieldValue.increment(Int64(pts)),
            "totalPoints": FieldValue.increment(Int64(pts)),
            "weeklyPoints": FieldValue.increment(Int64(pts))
        ], merge: true)

        try await updateUserStats(uid: uid, pointsDelta: pts, hoursDelta: 0)
    }

    // MARK: - Update userStats (global aggregate)
    private func updateUserStats(
        uid: String, pointsDelta: Int, hoursDelta: Double
    ) async throws {
        let userDoc = try await db.collection("users").document(uid).getDocument()
        let username = userDoc.data()?["username"]     as? String ?? ""
        let image = userDoc.data()?["profileImage"] as? String ?? ""

        var updates: [String: Any] = [
            "uid": uid,
            "username": username,
            "profileImage": image,
            "totalPoints": FieldValue.increment(Int64(pointsDelta)),
            "weeklyPoints": FieldValue.increment(Int64(pointsDelta)),
            "lastUpdated":  Timestamp(date: Date())
        ]
        if hoursDelta > 0 {
            updates["totalStudyHours"] = FieldValue.increment(hoursDelta)
        }
        try await userStatRef(uid: uid).setData(updates, merge: true)
    }

    // MARK: - Helpers
    private func weekdayKey() -> String {
        let days  = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        let index = Calendar.current.component(.weekday, from: Date()) - 1
        return days[index]
    }

    private func encode(_ stat: GroupStat) -> [String: Any] {
        [
            "uid": stat.uid,
            "groupId": stat.groupId,
            "username": stat.username,
            "totalPoints": stat.totalPoints,
            "weeklyPoints": stat.weeklyPoints,
            "qnaPoints": stat.qnaPoints,
            "pollPoints": stat.pollPoints,
            "sessionPoints": stat.sessionPoints,
            "currentStreak": stat.currentStreak,
            "longestStreak": stat.longestStreak,
            "lastActiveDate": Timestamp(date: stat.lastActiveDate),
            "lastWeeklyReset": Timestamp(date: stat.lastWeeklyReset),
            "totalStudyHours": stat.totalStudyHours,
            "weeklyStudyHours": stat.weeklyStudyHours,
            "weeklyGoalHours": stat.weeklyGoalHours,
            "sessionsAttended": stat.sessionsAttended,
            "totalSessions": stat.totalSessions,
            "attendanceRate": stat.attendanceRate,
            "totalPollsVoted": stat.totalPollsVoted,
            "totalCorrect": stat.totalCorrect,
            "pollAccuracy": stat.pollAccuracy,
            "totalAnswers": stat.totalAnswers,
            "bestAnswers": stat.bestAnswers,
            "weeklyActivity": stat.weeklyActivity
        ]
    }

    private func decodeGroupStat(
        data: [String: Any], uid: String, groupId: String
    ) -> GroupStat {
        func int(_ k: String) -> Int { data[k] as? Int    ?? 0    }
        func dbl(_ k: String) -> Double { data[k] as? Double ?? 0.0  }
        func date(_ k: String) -> Date {
            (data[k] as? Timestamp)?.dateValue() ?? Date()
        }
        func strDbl(_ k: String) -> [String: Double] {
            guard let raw = data[k] as? [String: Any] else { return [:] }
            var result: [String: Double] = [:]
            for (key, val) in raw {
                if let d = val as? Double { result[key] = d }
                else if let i = val as? Int { result[key] = Double(i) }
                else if let n = val as? NSNumber { result[key] = n.doubleValue }
            }
            return result
        }

        var activity = strDbl("weeklyActivity")
        for day in ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"] {
            if activity[day] == nil { activity[day] = 0 }
        }

        return GroupStat(
            uid: data["uid"] as? String ?? uid,
            groupId: data["groupId"]  as? String ?? groupId,
            username: data["username"] as? String ?? "",
            totalPoints: int("totalPoints"),
            weeklyPoints: int("weeklyPoints"),
            qnaPoints: int("qnaPoints"),
            pollPoints: int("pollPoints"),
            sessionPoints: int("sessionPoints"),
            currentStreak: int("currentStreak"),
            longestStreak: int("longestStreak"),
            lastActiveDate: date("lastActiveDate"),
            lastWeeklyReset: date("lastWeeklyReset"),
            totalStudyHours: dbl("totalStudyHours"),
            weeklyStudyHours: dbl("weeklyStudyHours"),
            weeklyGoalHours: dbl("weeklyGoalHours") == 0
                              ? 3.0 : dbl("weeklyGoalHours"),
            sessionsAttended: int("sessionsAttended"),
            totalSessions: int("totalSessions"),
            attendanceRate: dbl("attendanceRate"),
            totalPollsVoted: int("totalPollsVoted"),
            totalCorrect: int("totalCorrect"),
            pollAccuracy: dbl("pollAccuracy"),
            totalAnswers: int("totalAnswers"),
            bestAnswers: int("bestAnswers"),
            weeklyActivity: activity
        )
    }
}
