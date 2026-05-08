//
//  OTPViewModel.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-17.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class OTPViewModel: ObservableObject {

    @Published var otpDigits: [String] = Array(
        repeating: "", count: 6
    )
    @Published var isLoading: Bool = false
    @Published var isVerified: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var resendTimer: Int = 30

    private var timerTask: Task<Void, Never>?

    var isComplete: Bool {
        otpDigits.allSatisfy { $0.count == 1 }
    }

    // MARK: - Check email verification
    // Per Firebase docs: reload user then check isEmailVerified
    func checkVerification() async {
        isLoading = true
        do {
            try await Auth.auth().currentUser?.reload()
            if Auth.auth().currentUser?.isEmailVerified == true {
                isVerified = true
            } else {
                errorMessage = "Email not verified yet.\nPlease check your inbox and spam folder."
                showError = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    // MARK: - Resend verification email
    func resendCode() async {
        do {
            try await Auth.auth().currentUser?
                .sendEmailVerification()
            startTimer()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Countdown timer
    func startTimer() {
        resendTimer = 30
        timerTask?.cancel()
        timerTask = Task {
            while resendTimer > 0 && !Task.isCancelled {
                try? await Task.sleep(
                    nanoseconds: 1_000_000_000
                )
                resendTimer -= 1
            }
        }
    }
}
