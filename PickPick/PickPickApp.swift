//
//  PickPickApp.swift
//  PickPick
//
//  Created by Ruben Mimoun on 01/02/2024.
//

import SwiftUI
import TipKit

@main
struct PickPickApp: App {
    
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
