//
//  BiometricService.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-16.
//

import Foundation
import LocalAuthentication
import Security

class BiometricService {
    static let shared = BiometricService()

    private let emailKey = "kuppiya_email"
    private let passwordKey = "kuppiya_password"

    // MARK: - Check availability
    var isBiometricAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
    }

    var hasSavedCredentials: Bool {
        loadCredentials() != nil
    }

    // MARK: - Authenticate
    func authenticate() async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password"
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Log in to Kuppiya"
            )
        } catch {
            return false
        }
    }

    // MARK: - Save to Keychain
    func saveCredentials(email: String, password: String) {
        saveToKeychain(key: emailKey, value: email)
        saveToKeychain(key: passwordKey, value: password)
    }

    // MARK: - Load from Keychain
    func loadCredentials() -> (email: String, password: String)? {
        guard
            let email = loadFromKeychain(key: emailKey),
            let password = loadFromKeychain(key: passwordKey)
        else { return nil }
        return (email, password)
    }

    // MARK: - Clear Keychain
    func clearCredentials() {
        deleteFromKeychain(key: emailKey)
        deleteFromKeychain(key: passwordKey)
    }

    // MARK: - Keychain helpers
    private func saveToKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecValueData as String : data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String : true,
            kSecMatchLimit as String : kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : key
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    // Profile - biometrics

    var biometricType: LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }

    var biometricLabel: String {
        switch biometricType {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Biometrics"
        }
    }

    var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        default: return "lock.shield"
        }
    }

    var isAvailable: Bool {
        isBiometricAvailable
    }

    func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password"
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch {
            return false
        }
    }
    
}
