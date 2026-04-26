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

            SubmitRequestView()
                .tabItem {
                    Label("Submit", systemImage: "plus.circle.fill")
                }
                .tag(1)

            MyRequestsView()
                .tabItem {
                    Label("Requests", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(2)
            
            ATMFinderView()
                .tabItem {
                    Label("ATMs", systemImage: "banknote.fill")
                }
                .tag(3)

            StaffProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(.primaryBlue)
    }
}

