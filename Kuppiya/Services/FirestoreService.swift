import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    // -----------------------------------------------
    // MARK: - Sessions
    // -----------------------------------------------

    func fetchAllUpcomingSessions() async throws -> [StudySession] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let groupSnap = try await db
            .collection("studyGroups")
            .whereField("members", arrayContains: uid)
            .getDocuments()

        var all: [StudySession] = []
        let now = Date()

        for doc in groupSnap.documents {
            let groupId = doc.documentID
            let snap    = try await db
                .collection("studyGroups")
                .document(groupId)
                .collection("sessions")
                .getDocuments()

            let sessions = snap.documents.compactMap {
                try? $0.data(as: StudySession.self)
            }
            .filter {
                let end       = $0.date.addingTimeInterval(2 * 60 * 60)
                let isOngoing = now >= $0.date && now <= end
                let isFuture  = $0.date > now
                return isOngoing || isFuture
            }

            all.append(contentsOf: sessions)
        }

        return all.sorted { $0.date < $1.date }
    }

    func fetchUpcomingSession() async throws -> StudySession? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return nil
        }

        let groupSnap = try await db
            .collection("studyGroups")
            .whereField("members", arrayContains: uid)
            .getDocuments()

        guard !groupSnap.documents.isEmpty else { return nil }

        var candidates: [StudySession] = []

        for doc in groupSnap.documents {
            let groupId = doc.documentID
            let allSnap = try await db
                .collection("studyGroups")
                .document(groupId)
                .collection("sessions")
                .getDocuments()

            let now = Date()
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
                    let end        = $0.date.addingTimeInterval(2 * 60 * 60)
                    let isOngoing  = now >= $0.date && now <= end
                    let isUpcoming = $0.date > now
                    return isOngoing || isUpcoming
                }

            candidates.append(contentsOf: sessions)
        }

        let now = Date()
        return candidates.sorted { a, b in
            let aOngoing = now >= a.date && now <= a.date.addingTimeInterval(7200)
            let bOngoing = now >= b.date && now <= b.date.addingTimeInterval(7200)
            if aOngoing != bOngoing { return aOngoing }
            return a.date < b.date
        }.first
    }

    func fetchSessions(for groupId: String) async throws -> [StudySession] {
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

    func createSession(_ session: StudySession, in groupId: String) async throws {
        let docRef = db
            .collection("studyGroups")
            .document(groupId)
            .collection("sessions")
            .document()

        var newSession = session
        newSession.sessionId = docRef.documentID
        try docRef.setData(from: newSession)

        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await logActivity(
            groupId: groupId,
            actorId: uid,
            action: "created a session",
            target: session.title,
            type: "session"
        )

        print("Session created: \(docRef.documentID)")
    }

    func updateSessionStatus(sessionId: String, groupId: String, status: String) async throws {
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("sessions")
            .document(sessionId)
            .updateData(["status": status])
    }

    func updateSessionInfo(sessionId: String, groupId: String, title: String, description: String) async throws {
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("sessions")
            .document(sessionId)
            .updateData([
                "title":       title,
                "description": description
            ])
    }

    func deleteSession(sessionId: String, groupId: String) async throws {
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("sessions")
            .document(sessionId)
            .delete()
        print("Session deleted: \(sessionId)")
    }

    func markAttendance(sessionId: String, groupId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard !sessionId.isEmpty, !groupId.isEmpty else {
            print("markAttendance: sessionId or groupId is empty")
            return
        }
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("sessions")
            .document(sessionId)
            .updateData(["attendees": FieldValue.arrayUnion([uid])])
    }

    // -----------------------------------------------
    // MARK: - Resources
    // -----------------------------------------------

    func fetchResources(for groupId: String) async throws -> [Resource] {
        let snap = try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("resources")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snap.documents.compactMap {
            try? $0.data(as: Resource.self)
        }
    }

    func createResource(_ resource: Resource, in groupId: String) async throws {
        let ref = db
            .collection("studyGroups")
            .document(groupId)
            .collection("resources")
            .document(resource.resourceId)
        try ref.setData(from: resource)
        print("Resource created: \(resource.resourceId)")
    }

    func toggleLike(resourceId: String, groupId: String, uid: String, isLiked: Bool) async throws {
        let ref = db
            .collection("studyGroups")
            .document(groupId)
            .collection("resources")
            .document(resourceId)
        if isLiked {
            try await ref.updateData(["likedBy": FieldValue.arrayRemove([uid])])
        } else {
            try await ref.updateData(["likedBy": FieldValue.arrayUnion([uid])])
        }
    }

    func toggleSave(resourceId: String, groupId: String, uid: String, isSaved: Bool) async throws {
        let ref = db
            .collection("studyGroups")
            .document(groupId)
            .collection("resources")
            .document(resourceId)
        if isSaved {
            try await ref.updateData(["savedBy": FieldValue.arrayRemove([uid])])
        } else {
            try await ref.updateData(["savedBy": FieldValue.arrayUnion([uid])])
        }
    }

    func deleteResource(resourceId: String, groupId: String) async throws {
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("resources")
            .document(resourceId)
            .delete()
        print("Resource deleted: \(resourceId)")
    }

    // -----------------------------------------------
    // MARK: - Study Groups
    // -----------------------------------------------

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

        let docRef     = db.collection("studyGroups").document()
        let groupId    = docRef.documentID
        let inviteLink = "https://kuppiya.app/join?groupId=\(groupId)"

        var allMembers = [uid]
        for memberId in initialMembers {
            if !allMembers.contains(memberId) {
                allMembers.append(memberId)
            }
        }

        let newGroup = StudyGroup(
            groupId:     groupId,
            name:        name,
            subject:     subject,
            major:       major,
            description: description,
            createdBy:   uid,
            members:     allMembers,
            privacy:     privacy,
            university:  university,
            createdAt:   Date(),
            inviteLink:  inviteLink
        )

        try docRef.setData(from: newGroup)

        for memberId in allMembers {
            guard !memberId.isEmpty else { continue }
            try await db.collection("users")
                .document(memberId)
                .updateData(["joinedGroups": FieldValue.arrayUnion([groupId])])
        }

        try await logActivity(
            groupId: groupId,
            actorId: uid,
            action:  "created this group",
            type:    "member"
        )

        print("Group created: \(groupId)")
        return newGroup
    }

    func fetchPublicGroups(major: String? = nil, searchText: String = "") async throws -> [StudyGroup] {
        var query: Query = db
            .collection("studyGroups")
            .whereField("privacy", isEqualTo: "public")

        if let major, !major.isEmpty {
            query = query.whereField("major", isEqualTo: major)
        }

        let snap   = try await query.getDocuments()
        var groups = snap.documents.compactMap { try? $0.data(as: StudyGroup.self) }

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
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        let snap = try await db
            .collection("studyGroups")
            .whereField("members", arrayContains: uid)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: StudyGroup.self) }
    }

    func fetchGroup(groupId: String) async throws -> StudyGroup? {
        let doc = try await db
            .collection("studyGroups")
            .document(groupId)
            .getDocument()
        return try? doc.data(as: StudyGroup.self)
    }

    func updateGroup(groupId: String, data: [String: Any]) async throws {
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

    // MARK: - Group Settings

    func updateGroupInfo(groupId: String, name: String, subject: String, description: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await db.collection("studyGroups")
            .document(groupId)
            .updateData([
                "name":        name,
                "subject":     subject,
                "description": description
            ])
        try await logActivity(groupId: groupId, actorId: uid,
                              action: "updated group info", type: "update")
        print("Group info updated")
    }

    func updateGroupPrivacy(groupId: String, privacy: String) async throws {
        try await db.collection("studyGroups")
            .document(groupId)
            .updateData(["privacy": privacy])
        print("Privacy updated: \(privacy)")
    }

    func removeMemberFromGroup(groupId: String, memberId: String) async throws {
        try await db.collection("studyGroups")
            .document(groupId)
            .updateData(["members": FieldValue.arrayRemove([memberId])])
        try await db.collection("users")
            .document(memberId)
            .updateData(["joinedGroups": FieldValue.arrayRemove([groupId])])
        print("Member removed: \(memberId)")
    }

    func transferAdmin(groupId: String, newAdminId: String) async throws {
        try await db.collection("studyGroups")
            .document(groupId)
            .updateData(["createdBy": newAdminId])
        print("Admin transferred to: \(newAdminId)")
    }

    func leaveGroupAsAdmin(groupId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let group = try await fetchGroup(groupId: groupId)
        guard let group else { return }
        let remaining = group.members.filter { $0 != uid }
        if remaining.isEmpty {
            try await deleteGroup(groupId: groupId)
            print("Group deleted — last member left")
        } else {
            try await transferAdmin(groupId: groupId, newAdminId: remaining[0])
            try await leaveGroup(groupId: groupId)
            print("Admin transferred to \(remaining[0])")
        }
    }

    // MARK: - Join Requests

    func fetchPendingJoinRequests() async throws -> [JoinRequest] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

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
        return requestSnap.documents.compactMap { try? $0.data(as: JoinRequest.self) }
    }

    func sendJoinRequest(group: StudyGroup, senderName: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let existing = try await db
            .collection("joinRequests")
            .whereField("groupId",  isEqualTo: group.groupId)
            .whereField("senderId", isEqualTo: uid)
            .whereField("status",   isEqualTo: "pending")
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
        try await db.collection("joinRequests").document(requestId)
            .updateData(["status": "approved"])
        try await db.collection("studyGroups").document(request.groupId)
            .updateData(["members": FieldValue.arrayUnion([request.senderId])])
        try await db.collection("users").document(request.senderId)
            .updateData(["joinedGroups": FieldValue.arrayUnion([request.groupId])])
        try await logActivity(
            groupId: request.groupId,
            actorId: request.senderId,
            action:  "joined the group",
            type:    "member"
        )
        print("Approved: \(request.senderName)")
    }

    func rejectJoinRequest(_ request: JoinRequest) async throws {
        guard let requestId = request.id else { return }
        try await db.collection("joinRequests").document(requestId)
            .updateData(["status": "rejected"])
        print("Rejected: \(request.senderName)")
    }

    func joinPublicGroup(_ group: StudyGroup) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await db.collection("studyGroups").document(group.groupId)
            .updateData(["members": FieldValue.arrayUnion([uid])])
        try await db.collection("users").document(uid)
            .updateData(["joinedGroups": FieldValue.arrayUnion([group.groupId])])
        try await logActivity(
            groupId: group.groupId,
            actorId: uid,
            action:  "joined the group",
            type:    "member"
        )
        print("Joined: \(group.name)")
    }

    func leaveGroup(groupId: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await db.collection("studyGroups").document(groupId)
            .updateData(["members": FieldValue.arrayRemove([uid])])
        try await db.collection("users").document(uid)
            .updateData(["joinedGroups": FieldValue.arrayRemove([groupId])])
        try await logActivity(
            groupId: groupId,
            actorId: uid,
            action:  "left the group",
            type:    "member"
        )
        print("Left group: \(groupId)")
    }

    // MARK: - Activities

    func fetchActivities(for groupId: String) async throws -> [Activity] {
        let snap = try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("activities")
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .getDocuments()

        return snap.documents
            .compactMap { try? $0.data(as: Activity.self) }
            .filter { $0.type != "request" }
    }

    func logActivity(
        groupId: String,
        actorId: String,
        action:  String,
        target:  String? = nil,
        type:    String
    ) async throws {
        let data: [String: Any] = [
            "actorId"  : actorId,
            "action"   : action,
            "target"   : target ?? "",
            "type"     : type,
            "createdAt": Timestamp(date: Date())
        ]
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("activities")
            .addDocument(data: data)
    }

    // -----------------------------------------------
    // MARK: - Reviews
    // -----------------------------------------------

    func submitReview(groupId: String, rating: Int, review: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let data: [String: Any] = [
            "authorId" : uid,
            "rating"   : rating,
            "review"   : review,
            "createdAt": Timestamp(date: Date())
        ]
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("reviews")
            .addDocument(data: data)
        print("Review submitted for: \(groupId)")
    }

    func fetchReviews(for groupId: String) async throws -> [GroupReview] {
        let snap = try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("reviews")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: GroupReview.self) }
    }

    // MARK: - Storage

    func uploadGroupImage(groupId: String, image: UIImage) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.7)
        else { throw FirestoreError.invalidImage }

        let storageRef = Storage.storage().reference()
            .child("groupImages/\(groupId)/avatar.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()

        try await db.collection("studyGroups").document(groupId)
            .updateData(["groupImageURL": downloadURL.absoluteString])
        try await logActivity(groupId: groupId, actorId: uid,
                              action: "updated group photo", type: "update")
        print("Group image uploaded: \(downloadURL)")
        return downloadURL.absoluteString
    }

    func uploadProfileImage(uid: String, image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7)
        else { throw FirestoreError.invalidImage }

        let storageRef = Storage.storage().reference()
            .child("profileImages/\(uid)/avatar.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()

        try await db.collection("users").document(uid)
            .updateData(["profileImage": downloadURL.absoluteString])
        print("Profile image uploaded: \(downloadURL)")
        return downloadURL.absoluteString
    }

    // -----------------------------------------------
    // MARK: - Users
    // -----------------------------------------------

    func fetchAllUsers() async throws -> [AppUser] {
        let snap = try await db.collection("users").limit(to: 100).getDocuments()
        return snap.documents.compactMap { try? $0.data(as: AppUser.self) }
    }

    func fetchUser(uid: String) async throws -> AppUser? {
        guard !uid.isEmpty else {
            print("fetchUser called with empty uid")
            return nil
        }
        let doc = try await db.collection("users").document(uid).getDocument()
        return try? doc.data(as: AppUser.self)
    }

    func updateUser(uid: String, data: [String: Any]) async throws {
        try await db.collection("users").document(uid).updateData(data)
    }

    func searchUsers(query: String) async throws -> [AppUser] {
        let snap = try await db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: query)
            .whereField("username", isLessThanOrEqualTo: query + "\u{f8ff}")
            .limit(to: 20)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: AppUser.self) }
    }

    // -----------------------------------------------
    // MARK: - Interests
    // -----------------------------------------------

    func saveInterests(uid: String, interests: [String]) async throws {
        try await db.collection("users").document(uid)
            .updateData(["interests": interests])
        print("Interests saved: \(interests)")
    }

    func hasInterests(uid: String) async throws -> Bool {
        let user = try await fetchUser(uid: uid)
        let interests = user?.interests ?? []
        return !interests.filter { !$0.isEmpty }.isEmpty
    }

    // -----------------------------------------------
    // MARK: - Discovery
    // -----------------------------------------------

    func fetchAllGroupsForDiscovery() async throws -> [StudyGroup] {
        let snap = try await db.collection("studyGroups").getDocuments()
        return snap.documents.compactMap { doc -> StudyGroup? in
            do {
                return try doc.data(as: StudyGroup.self)
            } catch {
                print("decode failed \(doc.documentID): \(error)")
                return nil
            }
        }
    }

    func fetchScoredRecommendedGroups(user: AppUser) async throws -> [StudyGroup] {
        let all       = try await fetchAllGroupsForDiscovery()
        let notJoined = all.filter { !$0.members.contains(user.uid) }
        let interests = user.interests.filter { !$0.isEmpty && $0 != "skipped" }

        let scored: [(StudyGroup, Int)] = notJoined.map { group in
            var score = 0
            if !user.major.isEmpty,
               group.major.lowercased() == user.major.lowercased() { score += 10 }
            if !interests.isEmpty, interests.contains(where: {
                group.subject.lowercased().contains($0.lowercased()) ||
                group.name.lowercased().contains($0.lowercased())
            }) { score += 5 }
            if !user.university.isEmpty,
               group.university.lowercased() == user.university.lowercased() { score += 3 }
            return (group, score)
        }

        let results = scored.filter { $0.1 > 0 }.sorted { $0.1 > $1.1 }.map { $0.0 }
        return results.isEmpty ? notJoined : results
    }

    func fetchTrendingGroupsCombined(currentUserUid: String) async throws -> [StudyGroup] {
        let all          = try await fetchAllGroupsForDiscovery()
        let sevenDaysAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        var scored: [(StudyGroup, Double)] = []

        for group in all {
            guard let groupId = group.id else { continue }
            let activitySnap = try await db
                .collection("studyGroups").document(groupId)
                .collection("activities")
                .whereField("createdAt", isGreaterThan: Timestamp(date: sevenDaysAgo))
                .getDocuments()
            let score = Double(group.members.count) * 0.6
                      + Double(activitySnap.documents.count) * 0.4
            scored.append((group, score))
        }

        return scored.sorted { $0.1 > $1.1 }.prefix(10).map { $0.0 }
    }

    func searchAllGroups(query: String) async throws -> [StudyGroup] {
        guard !query.isEmpty else { return [] }
        let all = try await fetchAllGroupsForDiscovery()
        let q   = query.lowercased()
        return all.filter {
            $0.name.lowercased().contains(q) ||
            $0.subject.lowercased().contains(q) ||
            $0.major.lowercased().contains(q) ||
            $0.university.lowercased().contains(q)
        }
    }

    func checkPendingRequest(groupId: String) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        let snap = try await db.collection("joinRequests")
            .whereField("groupId",  isEqualTo: groupId)
            .whereField("senderId", isEqualTo: uid)
            .whereField("status",   isEqualTo: "pending")
            .getDocuments()
        return !snap.documents.isEmpty
    }
    
    // -----------------------------------------------
    // MARK: - QnA
    // -----------------------------------------------

    func fetchQuestions(groupId: String) async throws -> [Question] {
        let snap = try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("questions")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Question.self) }
    }

    func postQuestion(groupId: String, authorId: String, authorName: String,
                      title: String, description: String, tag: String) async throws {
        let questionId = UUID().uuidString
        let data: [String: Any] = [
            "questionId": questionId,
            "groupId": groupId,
            "authorId": authorId,
            "authorName": authorName,
            "title": title,
            "description": description,
            "tag": tag,
            "upvotes": [],
            "answerCount": 0,
            "bestAnswerId": NSNull(),
            "createdAt": Timestamp(date: Date()),
            "status": "unanswered"
        ]
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("questions")
            .document(questionId)
            .setData(data)

        // Award +10 points for posting question
        try await awardPoints(uid: authorId, points: 10)

        // Log activity
        try await logActivity(
            groupId: groupId,
            actorId: authorId,
            action: "posted a question",
            type: "qna"
        )
    }

    func fetchAnswers(groupId: String, questionId: String) async throws -> [Answer] {
        let snap = try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("questions")
            .document(questionId)
            .collection("answers")
            .order(by: "createdAt", descending: false)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Answer.self) }
    }

    func postAnswer(groupId: String, questionId: String, authorId: String,
                    authorName: String, body: String) async throws {
        let answerId = UUID().uuidString
        let data: [String: Any] = [
            "answerId": answerId,
            "questionId": questionId,
            "authorId": authorId,
            "authorName": authorName,
            "body": body,
            "upvotes": [],
            "isBestAnswer": false,
            "createdAt": Timestamp(date: Date())
        ]
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("questions")
            .document(questionId)
            .collection("answers")
            .document(answerId)
            .setData(data)

        // Update answer count
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("questions")
            .document(questionId)
            .updateData([
                "answerCount": FieldValue.increment(Int64(1)),
                "status": "answered"
            ])

        // Award +15 points for answering
        try await awardPoints(uid: authorId, points: 15)
    }

    func markBestAnswer(groupId: String, questionId: String,
                        answerId: String, authorId: String) async throws {
        // Unmark previous best answer if any
        let answers = try await fetchAnswers(groupId: groupId, questionId: questionId)
        for answer in answers where answer.isBestAnswer {
            try await db
                .collection("studyGroups")
                .document(groupId)
                .collection("questions")
                .document(questionId)
                .collection("answers")
                .document(answer.answerId)
                .updateData(["isBestAnswer": false])
        }

        // Mark new best answer
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("questions")
            .document(questionId)
            .collection("answers")
            .document(answerId)
            .updateData(["isBestAnswer": true])

        // Update question
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("questions")
            .document(questionId)
            .updateData(["bestAnswerId": answerId])

        // Award +25 points bonus
        try await awardPoints(uid: authorId, points: 25)
    }

    func toggleQuestionUpvote(groupId: String, questionId: String,
                              uid: String, isUpvoted: Bool) async throws {
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("questions")
            .document(questionId)
            .updateData([
                "upvotes": isUpvoted
                    ? FieldValue.arrayRemove([uid])
                    : FieldValue.arrayUnion([uid])
            ])
    }

    func toggleAnswerUpvote(groupId: String, questionId: String,
                            answerId: String, uid: String, isUpvoted: Bool) async throws {
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("questions")
            .document(questionId)
            .collection("answers")
            .document(answerId)
            .updateData([
                "upvotes": isUpvoted
                    ? FieldValue.arrayRemove([uid])
                    : FieldValue.arrayUnion([uid])
            ])
    }

    private func awardPoints(uid: String, points: Int) async throws {
        try await db
            .collection("users")
            .document(uid)
            .updateData(["points": FieldValue.increment(Int64(points))])
    }
    
    // -----------------------------------------------
    // MARK: - Polls
    // -----------------------------------------------

    func fetchPolls(groupId: String) async throws -> [Poll] {
        let snap = try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("polls")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Poll.self) }
    }

    func createPoll(
        groupId:      String,
        authorId:     String,
        authorName:   String,
        question:     String,
        options:      [String],
        correctIndex: Int,
        duration:     Int
    ) async throws {
        let pollId  = UUID().uuidString
        let endsAt  = Date().addingTimeInterval(Double(duration) * 3600)
        let pollOptions = options.enumerated().map { index, text in
            ["id": UUID().uuidString, "text": text, "voteCount": 0]
        }

        let data: [String: Any] = [
            "pollId":       pollId,
            "groupId":      groupId,
            "authorId":     authorId,
            "authorName":   authorName,
            "question":     question,
            "options":      pollOptions,
            "correctIndex": correctIndex,
            "duration":     duration,
            "endsAt":       Timestamp(date: endsAt),
            "status":       "active",
            "createdAt":    Timestamp(date: Date()),
            "totalVotes":   0
        ]

        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("polls")
            .document(pollId)
            .setData(data)

        try await awardPoints(uid: authorId, points: 15)

        try await logActivity(
            groupId: groupId,
            actorId: authorId,
            action:  "created a poll",
            type:    "poll"
        )
    }

    func vote(groupId: String, pollId: String, optionIndex: Int, uid: String) async throws {
        let voteData: [String: Any] = [
            "uid":        uid,
            "optionIndex": optionIndex,
            "votedAt":    Timestamp(date: Date())
        ]

        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("polls")
            .document(pollId)
            .collection("votes")
            .document(uid)
            .setData(voteData)

        // Increment option voteCount
        let pollRef = db
            .collection("studyGroups")
            .document(groupId)
            .collection("polls")
            .document(pollId)

        let snap = try await pollRef.getDocument()
        if var options = snap.data()?["options"] as? [[String: Any]] {
            options[optionIndex]["voteCount"] = (options[optionIndex]["voteCount"] as? Int ?? 0) + 1
            try await pollRef.updateData([
                "options":    options,
                "totalVotes": FieldValue.increment(Int64(1))
            ])
        }

        try await awardPoints(uid: uid, points: 8)
    }

    func fetchUserVote(groupId: String, pollId: String, uid: String) async throws -> Int? {
        let snap = try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("polls")
            .document(pollId)
            .collection("votes")
            .document(uid)
            .getDocument()

        return snap.data()?["optionIndex"] as? Int
    }

    func closePoll(groupId: String, pollId: String) async throws {
        try await db
            .collection("studyGroups")
            .document(groupId)
            .collection("polls")
            .document(pollId)
            .updateData(["status": "closed"])
    }
    
    // -----------------------------------------------
    // MARK: - Resource - Activity
    // -----------------------------------------------
    
    func fetchFavouriteResources() async throws -> [Resource] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        let groups = try await fetchMyGroups()
        var results: [Resource] = []
        for group in groups {
            let snap = try await db
                .collection("studyGroups")
                .document(group.groupId)
                .collection("resources")
                .whereField("likedBy", arrayContains: uid)
                .getDocuments()
            results.append(contentsOf: snap.documents.compactMap {
                try? $0.data(as: Resource.self)
            })
        }
        return results.sorted { $0.createdAt > $1.createdAt }
    }

    func fetchBookmarkedResources() async throws -> [Resource] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        let groups = try await fetchMyGroups()
        var results: [Resource] = []
        for group in groups {
            let snap = try await db
                .collection("studyGroups")
                .document(group.groupId)
                .collection("resources")
                .whereField("savedBy", arrayContains: uid)
                .getDocuments()
            results.append(contentsOf: snap.documents.compactMap {
                try? $0.data(as: Resource.self)
            })
        }
        return results.sorted { $0.createdAt > $1.createdAt }
    }

    // Expose db for ViewModel
    var db_public: Firestore { db }

}

// -----------------------------------------------
// MARK: - Errors
// -----------------------------------------------

enum FirestoreError: LocalizedError {
    case notLoggedIn
    case groupNotFound
    case sessionNotFound
    case alreadyMember
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .notLoggedIn:     return "You must be logged in."
        case .groupNotFound:   return "Study group not found."
        case .sessionNotFound: return "Session not found."
        case .alreadyMember:   return "Already a member."
        case .invalidImage:    return "Could not process image."
        }
    }
}
