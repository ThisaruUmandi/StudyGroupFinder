//
//  HomeView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-07.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = HomeViewModel()

    @State private var navigateToCreate    = false
    @State private var navigateToDiscover  = false
    @State private var navigateToInterests = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView()
                } else {
                    scrollContent
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToCreate) {
                CreateGroupView().environmentObject(authVM)
            }
            .navigationDestination(isPresented: $navigateToInterests) {
                PickInterestsView {
                    navigateToInterests = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        navigateToDiscover = true
                    }
                }
                .environmentObject(authVM)
            }
            .navigationDestination(isPresented: $navigateToDiscover) {
                DiscoverGroupsView().environmentObject(authVM)
            }
        }
        .task { await viewModel.loadHomeData() }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // Pulled out so body stays readable
    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                HomeHeaderView(user: authVM.currentUser)

                HomeGreetingView()
                    .padding(.horizontal, 20)

                KSearchBar(text: $viewModel.searchText)
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 20)

                HStack(spacing: 12) {
                    KActionCard(
                        icon: "folder.badge.plus",
                        title: "Create Group",
                        subtitle: "Start a study pod",
                        bgColor: Color(hex: "#EDE7FF")
                    ) {
                        navigateToCreate = true
                    }
                    KActionCard(
                        icon: "magnifyingglass",
                        title: "Browse Groups",
                        subtitle: "Discover communities",
                        bgColor: Color(hex: "#E0F5EE")
                    ) {
                        Task { await browseGroups() }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                VStack(alignment: .leading, spacing: 12) {
                    HomeSectionHeader(title: "Upcoming Sessions")
                        .padding(.horizontal, 20)

                    if let session = viewModel.upcomingSession {
                        KSessionCard(session: session)
                            .padding(.horizontal, 20)
                    } else {
                        KEmptySessionCard()
                            .padding(.horizontal, 20)
                    }
                }

                if !viewModel.joinRequests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HomeSectionHeader(
                            title: "Join Requests",
                            badge: "\(viewModel.pendingCount) PENDING"
                        )
                        .padding(.horizontal, 20)

                        ForEach(viewModel.joinRequests) { request in
                            KJoinRequestCard(
                                request: request,
                                onApprove: {
                                    Task { await viewModel.approveRequest(request) }
                                },
                                onReject: {
                                    Task { await viewModel.rejectRequest(request) }
                                }
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                }

                Spacer(minLength: 80)
            }
            .padding(.top, 16)
        }
    }

    private func browseGroups() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            navigateToDiscover = true
            return
        }
        do {
            let hasInterests = try await FirestoreService.shared.hasInterests(uid: uid)
            navigateToInterests = !hasInterests
            if hasInterests { navigateToDiscover = true }
        } catch {
            navigateToDiscover = true
        }
    }
}

// MARK: - Supporting views

struct HomeHeaderView: View {
    let user: AppUser?

    var body: some View {
        HStack(spacing: 12) {
            KUserAvatar(
                imageURL: user?.profileImage,
                name: user?.username ?? "User",
                size: 46
            )
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text("Hi, \(user?.username ?? "User")")
                        .font(.system(size: 15, weight: .semibold))
                    Text("👋")
                }
                Text("WELCOME TO KUPPIYA")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
                    .tracking(1.2)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

struct HomeGreetingView: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("What would you")
                    .font(.system(size: 28, weight: .bold))
                Text("like to do today?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#6B3FD4"))
            }
            Spacer()
            Image("home_girl")
                .resizable()
                .scaledToFit()
                .frame(width: 105, height: 110)
                .padding(.horizontal)
                .padding(.bottom, -25)
                .zIndex(1)
        }
    }
}

struct HomeSectionHeader: View {
    let title: String
    var badge: String?          = nil
    var badgeBg: Color          = Color(hex: "#FAEEDA")
    var badgeTextColor: Color   = Color(hex: "#BA7517")
    var actionTitle: String?    = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)

            if let badge {
                Text(badge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(badgeTextColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(badgeBg)
                    .cornerRadius(20)
            }
            Spacer()
            if let actionTitle, let onAction {
                Button(action: onAction) {
                    Text(actionTitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#0300BF"))
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
