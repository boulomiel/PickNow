//
//  PickPickApp.swift
//  PickPick
//
//  Created by Ruben Mimoun on 01/02/2024.
//

import SwiftUI
import TipKit
#if !DEBUG
import FirebaseCore
#endif

@main
struct PickPickApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        try? Tips.resetDatastore()
        try? Tips.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            PickView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
#if !DEBUG
        FirebaseApp.configure()
#endif
        return true
    }
}
