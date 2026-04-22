//
//  HomeView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-07.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = HomeViewModel()
    @State private var navigateToCreate = false
    @State private var navigateToBrowse = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.white).ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {

                            // MARK: Header
                            HomeHeaderView(user: authVM.currentUser)

                            // MARK: Greeting
                            HomeGreetingView()
                                .padding(.horizontal, 20)

                            // MARK: Search
                            KSearchBar(text: $viewModel.searchText)
                                .padding(.horizontal, 20)
                                .padding(.top, 6)
                                .padding(.bottom, 20)

                            // MARK: Action Cards
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
                                    navigateToBrowse = true
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)

                            // MARK: Upcoming Sessions
                            VStack(alignment: .leading, spacing: 12) {
                                HomeSectionHeader(
                                    title: "Upcoming Sessions"
                                )
                                .padding(.horizontal, 20)

                                if let session = viewModel.upcomingSession {
                                    KSessionCard(session: session)
                                        .padding(.horizontal, 20)
                                } else {
                                    KEmptySessionCard()
                                        .padding(.horizontal, 20)
                                }
                            }

                            // MARK: Join Requests
                            if !viewModel.joinRequests.isEmpty {
                                VStack(alignment: .leading,
                                       spacing: 12) {
                                    HomeSectionHeader(
                                        title: "Join Requests",
                                        badge: "\(viewModel.pendingCount) PENDING"
                                    )
                                    .padding(.horizontal, 20)

                                    ForEach(viewModel.joinRequests) { request in
                                        KJoinRequestCard(
                                            request: request,
                                            onApprove: {
                                                Task {
                                                    await viewModel
                                                        .approveRequest(request)
                                                }
                                            },
                                            onReject: {
                                                Task {
                                                    await viewModel
                                                        .rejectRequest(request)
                                                }
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
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToCreate) {
                //Text("Create Group — coming soon")
                CreateGroupView()
                    .environmentObject(authVM)
            }
            .navigationDestination(isPresented: $navigateToBrowse) {
                Text("Browse Groups — coming soon")
                    .environmentObject(authVM)
            }
        }
        .task {
            await viewModel.loadHomeData()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Section Header
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
                        .foregroundColor(Color(hex: "#1A1ADB"))
                }
            }
        }
    }
}

// MARK: - Header
struct HomeHeaderView: View {
    let user: AppUser?

    var body: some View {
        HStack(spacing: 12) {

            // ← KUserAvatar handles image OR first letter
            KUserAvatar(
                imageURL: user?.profileImage,
                name: user?.username ?? "User",
                size: 46
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text("Hi, \(user?.username ?? "User")")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                    Text("👋")
                        .font(.system(size: 15))
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

// MARK: - Greeting
struct HomeGreetingView: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("What would you")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
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

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
