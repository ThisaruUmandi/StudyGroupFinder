import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    // ─────────────────────────────────────────────
    // MARK: - Sessions
    // ─────────────────────────────────────────────

    func fetchUpcomingSession() async throws -> StudySession? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return nil
        }

        print("🔍 UID: \(uid)")

        let groupSnap = try await db
            .collection("studyGroups")
            .whereField("members", arrayContains: uid)
            .getDocuments()

        print("Groups found: \(groupSnap.documents.count)")

        guard !groupSnap.documents.isEmpty else {
            print("UID not in any group members[]")
            return nil
        }

        var upcoming: [StudySession] = []

        for doc in groupSnap.documents {
            let groupId = doc.documentID
            print("Group: \(groupId)")

            let allSnap = try await db
                .collection("studyGroups")
                .document(groupId)
                .collection("sessions")
                .getDocuments()

            print("Total sessions: \(allSnap.documents.count)")

            let sessions = allSnap.documents
                .compactMap { d -> StudySession? in
                    do {
                        return try d.data(as: StudySession.self)
                    } catch {
                        print("Decode error: \(error)")
                        return nil
                    }
                }
                .filter {
                    $0.status == "upcoming" &&
                    $0.date > Date()
                }

            print("Upcoming filtered: \(sessions.count)")
            upcoming.append(contentsOf: sessions)
        }

        let result = upcoming.sorted { $0.date < $1.date }.first
        print("Session: \(result?.title ?? "none")")
        return result
    }

    func fetchSessions(
        for groupId: String
    ) async throws -> [StudySession] {
        let snap = try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("sessions")
            .order(by: "date")
            .getDocuments()

        return snap.documents.compactMap {
            try? $0.data(as: StudySession.self)
        }
    }

    func createSession(
        _ session: StudySession,
        in groupId: String
    ) async throws {
        let docRef = db
            .collection("studyGroups")
            .document(groupId)
            .collection("sessions")
            .document()

        var newSession = session
        newSession.sessionId = docRef.documentID
        try docRef.setData(from: newSession)
        print("Session created: \(docRef.documentID)")
    }

    func updateSessionStatus(
        sessionId: String,
        groupId: String,
        status: String
    ) async throws {
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("sessions")
            .document(sessionId)
            .updateData(["status": status])
    }

    func deleteSession(
        sessionId: String,
        groupId: String
    ) async throws {
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("sessions")
            .document(sessionId)
            .delete()
        print("Session deleted: \(sessionId)")
    }

    // ─────────────────────────────────────────────
    // MARK: - Study Groups
    // ─────────────────────────────────────────────

    func createGroup(
        name: String,
        subject: String,
        major: String,
        description: String,
        privacy: String,
        university: String,
        initialMembers: [String] = []
    ) async throws -> StudyGroup {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw FirestoreError.notLoggedIn
        }

        let docRef = db.collection("studyGroups").document()
        let groupId = docRef.documentID
        let inviteLink = "https://kuppiya.app/join?groupId=\(groupId)"

        // Always include creator, add initial members without dupes
        var allMembers = [uid]
        for memberId in initialMembers {
            if !allMembers.contains(memberId) {
                allMembers.append(memberId)
            }
        }

        let newGroup = StudyGroup(
            groupId: groupId,
            name: name,
            subject: subject,
            major: major,
            description: description,
            createdBy: uid,
            members: allMembers,
            privacy: privacy,
            university: university,
            createdAt: Date(),
            inviteLink: inviteLink
        )

        try docRef.setData(from: newGroup)

        // Update joinedGroups for all members
        for memberId in allMembers {
            guard !memberId.isEmpty else {
                print("Skipping empty memberId")
                continue
            }
            try await db.collection("users")
                .document(memberId)
                .updateData([
                    "joinedGroups": FieldValue.arrayUnion([groupId])
                ])
        }

        print("Group created: \(groupId)")
        return newGroup
    }

    func fetchPublicGroups(
        major: String? = nil,
        searchText: String = ""
    ) async throws -> [StudyGroup] {
        var query: Query = db
            .collection("studyGroups")
            .whereField("privacy", isEqualTo: "public")

        if let major, !major.isEmpty {
            query = query.whereField("major", isEqualTo: major)
        }

        let snap = try await query.getDocuments()
        var groups = snap.documents.compactMap {
            try? $0.data(as: StudyGroup.self)
        }

        if !searchText.isEmpty {
            let q = searchText.lowercased()
            groups = groups.filter {
                $0.name.lowercased().contains(q) ||
                $0.subject.lowercased().contains(q) ||
                $0.major.lowercased().contains(q)
            }
        }
        return groups
    }

    func fetchMyGroups() async throws -> [StudyGroup] {
        guard let uid = Auth.auth().currentUser?.uid else {
            return []
        }
        let snap = try await db
            .collection("studyGroups")
            .whereField("members", arrayContains: uid)
            .getDocuments()

        return snap.documents.compactMap {
            try? $0.data(as: StudyGroup.self)
        }
    }

    func fetchGroup(groupId: String) async throws -> StudyGroup? {
        let doc = try await db
            .collection("studyGroups")
            .document(groupId)
            .getDocument()
        return try? doc.data(as: StudyGroup.self)
    }

    func updateGroup(
        groupId: String,
        data: [String: Any]
    ) async throws {
        try await db
            .collection("studyGroups")
            .document(groupId)
            .updateData(data)
    }

    func deleteGroup(groupId: String) async throws {
        try await db
            .collection("studyGroups")
            .document(groupId)
            .delete()
        print("Group deleted: \(groupId)")
    }

    // ─────────────────────────────────────────────
    // MARK: - Join Requests
    // ─────────────────────────────────────────────

    func fetchPendingJoinRequests() async throws -> [JoinRequest] {
        guard let uid = Auth.auth().currentUser?.uid else {
            return []
        }

        let groupSnap = try await db
            .collection("studyGroups")
            .whereField("createdBy", isEqualTo: uid)
            .getDocuments()

        let groupIds = groupSnap.documents.map { $0.documentID }
        print("Admin of \(groupIds.count) groups")

        guard !groupIds.isEmpty else { return [] }

        let requestSnap = try await db
            .collection("joinRequests")
            .whereField("groupId", in: groupIds)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()

        print("Pending requests: \(requestSnap.documents.count)")

        return requestSnap.documents.compactMap {
            try? $0.data(as: JoinRequest.self)
        }
    }

    func sendJoinRequest(
        group: StudyGroup,
        senderName: String
    ) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let existing = try await db
            .collection("joinRequests")
            .whereField("groupId", isEqualTo: group.groupId)
            .whereField("senderId", isEqualTo: uid)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()

        guard existing.documents.isEmpty else {
            print("Request already sent")
            return
        }

        let request: [String: Any] = [
            "groupId"   : group.groupId,
            "groupName" : group.name,
            "senderId"  : uid,
            "senderName": senderName,
            "status"    : "pending",
            "createdAt" : Timestamp(date: Date())
        ]

        try await db.collection("joinRequests").addDocument(data: request)
        print("Join request sent to: \(group.name)")
    }

    func approveJoinRequest(_ request: JoinRequest) async throws {
        guard let requestId = request.id else { return }

        try await db.collection("joinRequests")
            .document(requestId)
            .updateData(["status": "approved"])

        try await db.collection("studyGroups")
            .document(request.groupId)
            .updateData(["members": FieldValue.arrayUnion([request.senderId])])

        try await db.collection("users")
            .document(request.senderId)
            .updateData(["joinedGroups": FieldValue.arrayUnion([request.groupId])])

        print("Approved: \(request.senderName)")
    }

    func rejectJoinRequest(_ request: JoinRequest) async throws {
        guard let requestId = request.id else { return }

        try await db.collection("joinRequests")
            .document(requestId)
            .updateData(["status": "rejected"])

        print("Rejected: \(request.senderName)")
    }

    func joinPublicGroup(_ group: StudyGroup) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        try await db.collection("studyGroups")
            .document(group.groupId)
            .updateData(["members": FieldValue.arrayUnion([uid])])

        try await db.collection("users")
            .document(uid)
            .updateData(["joinedGroups": FieldValue.arrayUnion([group.groupId])])

        print("Joined: \(group.name)")
    }

    func leaveGroup(groupId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        try await db.collection("studyGroups")
            .document(groupId)
            .updateData(["members": FieldValue.arrayRemove([uid])])

        try await db.collection("users")
            .document(uid)
            .updateData(["joinedGroups": FieldValue.arrayRemove([groupId])])

        print("Left group: \(groupId)")
    }

    // ─────────────────────────────────────────────
    // MARK: - Users
    // ─────────────────────────────────────────────

    func fetchAllUsers() async throws -> [AppUser] {
        let snap = try await db
            .collection("users")
            .limit(to: 100)
            .getDocuments()
        return snap.documents.compactMap {
            try? $0.data(as: AppUser.self)
        }
    }

    func fetchUser(uid: String) async throws -> AppUser? {
        let doc = try await db
            .collection("users")
            .document(uid)
            .getDocument()
        return try? doc.data(as: AppUser.self)
    }

    func updateUser(uid: String, data: [String: Any]) async throws {
        try await db.collection("users")
            .document(uid)
            .updateData(data)
    }

    func searchUsers(query: String) async throws -> [AppUser] {
        let snap = try await db
            .collection("users")
            .whereField("username", isGreaterThanOrEqualTo: query)
            .whereField("username", isLessThanOrEqualTo: query + "\u{f8ff}")
            .limit(to: 20)
            .getDocuments()

        return snap.documents.compactMap {
            try? $0.data(as: AppUser.self)
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Errors
// ─────────────────────────────────────────────
enum FirestoreError: LocalizedError {
    case notLoggedIn
    case groupNotFound
    case sessionNotFound
    case alreadyMember

    var errorDescription: String? {
        switch self {
        case .notLoggedIn:     return "You must be logged in."
        case .groupNotFound:   return "Study group not found."
        case .sessionNotFound: return "Session not found."
        case .alreadyMember:   return "Already a member."
        }
    }
}
