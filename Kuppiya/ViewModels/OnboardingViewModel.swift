//
//  OnboardingViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-05.
//

import SwiftUI
import Foundation
import Combine

class OnboardingViewModel: ObservableObject {

    // MARK: - Data
    let pages: [Onboarding] = [
        Onboarding(id: 1, imageName: "splash1",  title: "Find Your Tribe", subtitle: "Discover and join study groups based on your subjects, university, and interests."),
        Onboarding(id: 2, imageName: "splash2", title: "Coordinate with Ease", subtitle: "Plan sessions, share schedules, and stay organized with your group members."),
        Onboarding(id: 3, imageName: "splash3", title: "Share & Success", subtitle: "Exchange notes, resources, and knowledge to learn faster together."),
        Onboarding(id: 4, imageName: "splash4", title: "Smart Navigation", subtitle: "Find and navigate to live study sessions with ease."),
        Onboarding(id: 5, imageName: "splash5", title: "Track Your Progress", subtitle: "Monitor your study activity and stay consistent with your learning goals.")
    ]

    // MARK: - Published
    @Published var currentIndex: Int = 0
    @Published var navigateToSetup: Bool = false

    // MARK: - Computed
    var currentPage: Onboarding {
        pages[currentIndex]
    }

    var totalPages: Int {
        pages.count
    }

    var isLastPage: Bool {
        currentIndex == totalPages - 1
    }

    // MARK: - Actions

    func goToNext() {
        if isLastPage {
            navigateToSetup = true
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
            }
        }
    }

    func skip() {
        navigateToSetup = true
    }
}
