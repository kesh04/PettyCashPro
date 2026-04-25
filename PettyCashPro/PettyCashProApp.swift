//
//  PettyCashProApp.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-20.
//

import SwiftUI

@main
struct PettyCashProApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
