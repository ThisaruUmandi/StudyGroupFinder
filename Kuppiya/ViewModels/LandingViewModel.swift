//
//  LandingViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-05.
//

import SwiftUI
import Combine

// MARK: - ViewModel
@MainActor
final class LandingViewModel: ObservableObject {
    
    // MARK: - Animation States (Published → drives the View)
    @Published var logoAppeared = false
    @Published var titleAppeared = false
    @Published var subtitleAppeared = false
    @Published var buttonAppeared = false
    
    @Published var logoGlow = false
    @Published var buttonPressed = false
    @Published var buttonShimmerOffset: CGFloat = -300
    @Published var buttonPulse = false
    
    // MARK: - Navigation
    @Published var didTapGetStarted = false
    
    // MARK: - Entrance Sequence
    func startEntranceAnimations() {
        logoAppeared = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) { [weak self] in
            self?.titleAppeared = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.subtitleAppeared = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) { [weak self] in
            self?.buttonAppeared = true
        }
    }
    
    // MARK: - Logo Glow Loop
    func startLogoGlow() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.9)) {
            logoGlow = true
        }
    }
    
    // MARK: - Button Shimmer Loop
    func startButtonShimmer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
            self?.runShimmerCycle()
        }
    }
    
    private func runShimmerCycle() {
        buttonShimmerOffset = -300
        withAnimation(.easeInOut(duration: 1.3)) {
            buttonShimmerOffset = 400
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            self?.runShimmerCycle()
        }
    }
    
    // MARK: - Button Pulse Loop
    func startButtonPulse() {
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(1.2)) {
            buttonPulse = true
        }
    }
    
    // MARK: - Button Tap
    func handleGetStartedTap() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            buttonPressed = true
        }
        triggerHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                self?.buttonPressed = false
            }
            // Signal navigation after bounce settles
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.didTapGetStarted = true
            }
        }
    }
    
    // MARK: - Private Helpers
    private func triggerHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}
