//
//  AppError.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-16.
//

// Centralized typed error system — used across all layers

import Foundation

enum AppError: LocalizedError {
    // Auth errors
    case invalidEmail
    case weakPassword
    case usernameTaken
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case signInCancelled

    // Network / Firestore
    case networkUnavailable
    case firestoreWriteFailed(String)
    case firestoreReadFailed(String)

    // Storage
    case imageUploadFailed(String)

    // Validation
    case emptyField(String)
    case invalidUsername      // < 3 chars or invalid chars

    // Generic
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Please enter a valid email address."
        case .weakPassword: return "Password must be at least 8 characters."
        case .usernameTaken: return "This username is already taken."
        case .emailAlreadyInUse: return "An account with this email already exists."
        case .userNotFound: return "No account found with this email."
        case .wrongPassword: return "Incorrect password. Please try again."
        case .signInCancelled: return "Sign-in was cancelled."
        case .networkUnavailable: return "No internet connection. Please try again."
        case .firestoreWriteFailed(let msg): return "Failed to save data: \(msg)"
        case .firestoreReadFailed(let msg): return "Failed to load data: \(msg)"
        case .imageUploadFailed(let msg): return "Image upload failed: \(msg)"
        case .emptyField(let field): return "\(field) cannot be empty."
        case .invalidUsername: return "Username must be 3–20 characters (letters, numbers, underscores only)."
        case .unknown(let msg): return msg
        }
    }
}
