//
//  OnboardingView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-05.
//


import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var currentScreen: AppNavigationView.Screen

    private let buttonColor = Color(hex: "0300BF")

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Top Bar
                HStack {
                    PageIndicatorView(
                        currentIndex: viewModel.currentIndex,
                        totalPages: viewModel.totalPages
                    )
                    Spacer()
                    Button {
                        viewModel.skip()
                    } label: {
                        Text("Skip")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(buttonColor)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // MARK: - Illustration
                Image(viewModel.currentPage.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 320)
                    .transition(.opacity.combined(
                        with: .scale(scale: 0.95)))
                    .id(viewModel.currentPage.id)
                    .padding(.bottom, 40)

                // MARK: - Text
                VStack(spacing: 12) {
                    Text(viewModel.currentPage.title)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                        .id("title_\(viewModel.currentPage.id)")

                    Text(viewModel.currentPage.subtitle)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color(red: 0.45,
                                               green: 0.45,
                                               blue: 0.45))
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                        .id("subtitle_\(viewModel.currentPage.id)")
                }
                .padding(.horizontal, 32)

                Spacer()

                // MARK: - Next / Get Started Button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.goToNext()
                    }
                } label: {
                    // ← Show "Get Started" on last page
                    Text(viewModel.isLastPage ? "Get Started" : "Next")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(buttonColor)
                        )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .onChange(of: viewModel.navigateToSetup) { navigate in
            if navigate {
                currentScreen = .signup
            }
        }
    }
}

#Preview {
    OnboardingView(currentScreen: .constant(.onboarding))
}
