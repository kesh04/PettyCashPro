//
//  StaffTabView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct StaffTabView: View {
    @EnvironmentObject var staffVM: StaffViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StaffDashboardView()
                           .tabItem {
                               Label("Home", systemImage: "house.fill")
                           }
                           .tag(0)
            .accentColor(.primaryBlue)
        }
    }
}
