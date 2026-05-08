//
//  TabBarViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-09.
//

import SwiftUI
import Combine

class TabBarViewModel: ObservableObject {
    
    @Published var activeTab: TabModel = .home
    @Published var isTabBarHidden: Bool = false
    @Published var navigationPath = NavigationPath()
    
    var isSecondaryPage: Bool {
        activeTab == .none
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
