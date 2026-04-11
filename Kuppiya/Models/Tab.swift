//
//  Tab.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-09.
//

import SwiftUI

enum TabModel: String, CaseIterable {
    case home = "home"
    case groups = "group"
    case activity = "activity"
    case profile = "profile"
    case none = "none"

    var title: String {
        switch self {
        case .home:     "Home"
        case .groups: "Groups"
        case .activity: "Activity"
        case .profile:  "Profile"
        case .none:     ""
        }
    }

    var icon: String {
        switch self {
        case .home: "home"
        case .groups: "group"
        case .activity: "activity"
        case .profile:  "profile"
        case .none:     ""
        }
    }

    // Only the 4 real tabs — used by CustomTabBar
    static var mainTabs: [TabModel] {
        [.home, .groups, .activity, .profile]
    }
}
