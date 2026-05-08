//
//  KuppiyaApp.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-01.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct KuppiyaApp: App {
    @StateObject private var authVM = AuthViewModel()
    @AppStorage("appColorScheme") private var appColorScheme = "system"

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isLoggedIn {
                    TabBarView()
                        .environmentObject(authVM)
                } else {
                    AppNavigationView()
                        .environmentObject(authVM)
                }
            }
            .preferredColorScheme(colorScheme)
        }
        // Required for Google Sign-In URL handling
//        .onOpenURL { url in
//            GIDSignIn.sharedInstance.handle(url)
//        }
    }
    private var colorScheme: ColorScheme? {
            switch appColorScheme {
            case "light": return .light
            case "dark": return .dark
            default: return nil  // nil = follows system
            }
        }
}
