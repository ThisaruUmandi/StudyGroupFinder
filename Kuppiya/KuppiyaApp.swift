//
//  KuppiyaApp.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-04-01.
//

//import SwiftUI
//import Firebase
//
//@main
//struct KuppiyaApp: App {
//    
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    
////    init(){
////        FirebaseApp.configure()
////        print("Configured Firebase!")
////    }
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//        //print("Configured Firebase!")
//        return true
//    }
//}

//  KuppiyaApp.swift
//  Kuppiya

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct KuppiyaApp: App {
    @StateObject private var authVM = AuthViewModel()

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
        }
        // Required for Google Sign-In URL handling
//        .onOpenURL { url in
//            GIDSignIn.sharedInstance.handle(url)
//        }
    }
}
