//
//  TabBarView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-09.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var tabManager = TabBarViewModel()

    var body: some View {
        if #available(iOS 18, *) {
            ZStack(alignment: .bottom) {
                TabView(selection: $tabManager.activeTab) {
                    Tab(value: .home) {
                        //Text("Home")
                        HomeView()
                            .environmentObject(authVM)
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                    Tab(value: .groups) {
                        //Text("My Groups")
                        GroupsView()
                            .environmentObject(authVM)
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                    Tab(value: .activity) {
                        //Text("Activity")
                        ActivityView()
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                    Tab(value: .profile) {
                        //Text("Profile")
                        ProfileView()
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                }

                if !tabManager.isTabBarHidden {
                    CustomTabBar(activeTab: $tabManager.activeTab)
                        .shadow(color: .black.opacity(0.15), radius: 10)
                        .padding(.bottom, 8)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .environmentObject(tabManager)
        }
    }
}

// MARK: - UIView Extension
extension UIView {
    var tabController: UITabBarController? {
        if let controller = sequence(first: self, next: { $0.next })
            .first(where: { $0 is UITabBarController }) as? UITabBarController {
            return controller
        }
        return nil
    }
}

#Preview {
    TabBarView()
        .environmentObject(AuthViewModel())
}
