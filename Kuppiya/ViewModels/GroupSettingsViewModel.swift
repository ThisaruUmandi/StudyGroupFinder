import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class GroupSettingsViewModel: ObservableObject {

    // MARK: - Editable fields
    @Published var name: String = ""
    @Published var subject: String = ""
    @Published var description: String = ""
    @Published var isPublic: Bool = true

    // MARK: - Image
    @Published var showImagePicker: Bool = false
    @Published var selectedImage: UIImage? = nil
    @Published var isUploadingImage: Bool = false

    // MARK: - Members
    @Published var members: [AppUser]  = []

    // MARK: - Join Requests
    @Published var joinRequests: [JoinRequest] = []

    // MARK: - Add Members
    @Published var showAddMembers: Bool = false
    @Published var selectedMembers: [AppUser] = []

    // MARK: - Review
    @Published var showReviewSheet: Bool = false
    @Published var rating: Int = 0
    @Published var reviewText: String    = ""

    // MARK: - State
    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String?
    @Published var showLeaveConfirm: Bool = false
    @Published var didLeaveGroup: Bool = false
    //@Published var didSave: Bool = false

    private let service = FirestoreService.shared

    var currentUID: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    // MARK: - Prefill
    func prefill(from group: StudyGroup) {
        name        = group.name
        subject     = group.subject
        description = group.description
        isPublic    = group.privacy == "public"
    }

    // MARK: - Load members + join requests
    func loadData(group: StudyGroup) async {
        isLoading = true

        var loaded: [AppUser] = []
        for uid in group.members {
            if let user = try? await service.fetchUser(uid: uid) {
                loaded.append(user)
            }
        }
        members = loaded

        if group.createdBy == currentUID && group.privacy == "private" {
            do {
                let snap = try await service.db_public
                    .collection("joinRequests")
                    .whereField("groupId", isEqualTo: group.groupId)
                    .whereField("status", isEqualTo: "pending")
                    .getDocuments()
                joinRequests = snap.documents.compactMap {
                    try? $0.data(as: JoinRequest.self)
                }
                print("Join requests: \(joinRequests.count)")
            } catch {
                print("Join requests error: \(error)")
            }
        }

        isLoading = false
    }

    // MARK: - Save group info
    func saveGroupInfo(groupId: String) async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Group name cannot be empty."
            showError = true
            return
        }
        isSaving = true
        do {
            try await service.updateGroupInfo(
                groupId: groupId,
                name: name.trimmingCharacters(in: .whitespaces),
                subject: subject.trimmingCharacters(in: .whitespaces),
                description: description.trimmingCharacters(in: .whitespaces)
            )
            //didSave = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isSaving = false
    }

    // MARK: - Save privacy
    func savePrivacy(groupId: String) async {
        do {
            try await service.updateGroupPrivacy(
                groupId: groupId,
                privacy: isPublic ? "public" : "private"
            )
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Upload group image   ← add this
    func uploadGroupImage(groupId: String) async {
        guard let image = selectedImage else { return }
        isUploadingImage = true
        do {
            let url = try await service.uploadGroupImage(
                groupId: groupId,
                image: image
            )
            print("Group image saved: \(url)")
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Upload error: \(error)")
        }
        isUploadingImage = false
    }

    // MARK: - Remove member
    func removeMember(_ user: AppUser, groupId: String) async {
        do {
            try await service.removeMemberFromGroup(
                groupId: groupId,
                memberId: user.uid
            )
            members.removeAll { $0.uid == user.uid }
            print("Removed: \(user.username)")
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Add selected members
    func addSelectedMembers(groupId: String) async {
        for user in selectedMembers {
            guard !members.contains(where: { $0.uid == user.uid })
            else { continue }
            do {
                try await service.db_public
                    .collection("studyGroups")
                    .document(groupId)
                    .updateData([
                        "members": FieldValue.arrayUnion([user.uid])
                    ])
                try await service.db_public
                    .collection("users")
                    .document(user.uid)
                    .updateData([
                        "joinedGroups": FieldValue.arrayUnion([groupId])
                    ])
                members.append(user)
                print("Added: \(user.username)")
            } catch {
                print("Add member error: \(error)")
            }
        }
        selectedMembers = []
    }

    // MARK: - Approve / Reject join request
    func approveRequest(_ request: JoinRequest) async {
        do {
            try await service.approveJoinRequest(request)
            joinRequests.removeAll { $0.id == request.id }
            if let user = try? await service.fetchUser(
                uid: request.senderId) {
                members.append(user)
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func rejectRequest(_ request: JoinRequest) async {
        do {
            try await service.rejectJoinRequest(request)
            joinRequests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Leave group
    func leaveGroup(group: StudyGroup) async {
        do {
            if group.createdBy == currentUID {
                try await service.leaveGroupAsAdmin(
                    groupId: group.groupId
                )
            } else {
                try await service.leaveGroup(groupId: group.groupId)
            }
            didLeaveGroup = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Submit review
    func submitReview(groupId: String) async {
        guard rating > 0 else {
            errorMessage = "Please select a rating."
            showError = true
            return
        }
        do {
            try await service.submitReview(
                groupId: groupId,
                rating: rating,
                review: reviewText
            )
            showReviewSheet = false
            rating = 0
            reviewText = ""
            print("Review submitted")
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
