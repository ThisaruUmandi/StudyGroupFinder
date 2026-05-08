//
//  LandingView.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-05.
//

import SwiftUI

// MARK: - View
struct LandingView: View {
    
    @StateObject private var viewModel = LandingViewModel()
    @State private var goToOnboarding = false
    
    var body: some View {
        Group {
            if goToOnboarding {
                InstructOneView()
            } else {
                ZStack {
                    backgroundGradient
                    
                    VStack(spacing: 0) {
                        Spacer()
                        logoSection
                        Spacer().frame(height: 44)
                        titleSection
                        Spacer().frame(height: 20)
                        subtitleSection
                        Spacer()
                        getStartedButton
                        Spacer().frame(height: 56)
                    }
                    .padding(.horizontal, 32)
                }
                .ignoresSafeArea()
                .onAppear {
                    viewModel.startEntranceAnimations()
                }
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(hex: "8B8FC7").opacity(0.9), location: 0.0),
                //.init(color: Color(hex: "2A2A7A"), location: 0.35),
                .init(color: Color(hex: "0A0A3E"), location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Logo Section
    private var logoSection: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 145, height: 145)
                .blur(radius: viewModel.logoGlow ? 8 : 4)
                .scaleEffect(viewModel.logoGlow ? 1.08 : 1.0)
                .animation(
                    .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                    value: viewModel.logoGlow
                )
            
            Circle()
                .strokeBorder(Color.white.opacity(0.9), lineWidth: 2.5)
                .frame(width: 130, height: 130)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "E8EAF6"), Color(hex: "C5C8E8")],
                        center: .center,
                        startRadius: 10,
                        endRadius: 65
                    )
                )
                .frame(width: 126, height: 126)
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
        }
        .opacity(viewModel.logoAppeared ? 1 : 0)
        .animation(
            .spring(response: 0.7, dampingFraction: 0.6, blendDuration: 0).delay(0.2),
            value: viewModel.logoAppeared
        )
    }
    
    // MARK: - Title
    private var titleSection: some View {
        Text("KUPPIYA")
            .font(.system(size: 60).bold())
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(hex: "FF8C00"), Color(hex: "FF5500")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .tracking(4)
            .opacity(viewModel.titleAppeared ? 1 : 0)
            .offset(y: viewModel.titleAppeared ? 0 : 30)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.7).delay(0.55),
                value: viewModel.titleAppeared
            )
    }
    
    // MARK: - Subtitle
    private var subtitleSection: some View {
        Text("Study Group Finder, organized\nand Simplified")
            .font(.system(size: 20).bold())
            .foregroundColor(.white.opacity(0.85))
            .multilineTextAlignment(.center)
            .lineSpacing(5)
            .opacity(viewModel.subtitleAppeared ? 1 : 0)
            .offset(y: viewModel.subtitleAppeared ? 0 : 20)
            .animation(
                .easeOut(duration: 0.6).delay(0.8),
                value: viewModel.subtitleAppeared
            )
    }
    
    // MARK: - Get Started Button
    private var getStartedButton: some View {
        Button {
            goToOnboarding = true
            viewModel.handleGetStartedTap()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white)
                    .frame(height: 62)
                    .scaleEffect(
                        viewModel.buttonPressed ? 0.96 : (viewModel.buttonPulse ? 1.015 : 1.0)
                    )
                
                Text("Get Started")
                    .font(.system(size: 22).bold())
                    .foregroundColor(Color(hex: "0A0A3E"))
                    .tracking(0.5)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(viewModel.buttonAppeared ? 1 : 0)
        .offset(y: viewModel.buttonAppeared ? 0 : 40)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.65).delay(1.0),
            value: viewModel.buttonAppeared
        )
        .onAppear {
            viewModel.startButtonShimmer()
            viewModel.startButtonPulse()
        }
    }
}

// MARK: - Preview
#Preview {
    LandingView()
}
