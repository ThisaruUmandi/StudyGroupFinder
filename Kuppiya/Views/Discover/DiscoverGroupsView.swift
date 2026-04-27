//
//  DiscoverGroupsView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-25.
//

import SwiftUI

struct DiscoverGroupsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = DiscoverGroupsViewModel()

    @State private var selectedGroup: StudyGroup?

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView().scaleEffect(1.2)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        header

                        KSearchBar(text: $viewModel.searchText, placeholder: "Search groups...")
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 8)

                        if viewModel.isSearchActive {
                            searchSection
                        } else {
                            recommendedSection
                            trendingSection
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedGroup) { group in
            GroupDetailView(group: group).environmentObject(authVM)
        }
        .task {
            guard let user = authVM.currentUser else { return }
            await viewModel.load(user: user)
        }
        .onChange(of: viewModel.searchText) { _, _ in viewModel.search() }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(UIColor.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                }
                .padding(.bottom, 10)

                Text("Discover a")
                    .font(.system(size: 28, weight: .bold))
                Text("suitable Group")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#6B3FD4"))
            }

            Spacer()

            Image("oboy_l")
                .resizable()
                .scaledToFit()
                .frame(width: 110)
                .padding(.bottom, -8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color(UIColor.systemGroupedBackground))
    }

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Search Results")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                if viewModel.isSearching { ProgressView().scaleEffect(0.8) }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            if viewModel.searchResults.isEmpty && !viewModel.isSearching {
                emptyState(icon: "magnifyingglass",
                           message: "No groups found for\n\"\(viewModel.searchText)\"")
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.searchResults) { group in
                        RecommendedGroupCard(group: group) { selectedGroup = group }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Groups")
                .font(.system(size: 17, weight: .bold))
                .padding(.horizontal, 20)
                .padding(.top, 24)

            if viewModel.recommendedGroups.isEmpty {
                emptyState(icon: "sparkles",
                           message: "No recommendations yet.\nUpdate your interests in Profile.")
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.recommendedGroups) { group in
                        RecommendedGroupCard(group: group) { selectedGroup = group }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trending Groups")
                .font(.system(size: 17, weight: .bold))
                .padding(.horizontal, 20)
                .padding(.top, 28)

            if viewModel.trendingGroups.isEmpty {
                emptyState(icon: "flame", message: "No trending groups yet.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(viewModel.trendingGroups) { group in
                            TrendingGroupCard(group: group) { selectedGroup = group }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func emptyState(icon: String, message: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.gray.opacity(0.4))
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 32)
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        DiscoverGroupsView().environmentObject(AuthViewModel())
    }
}
