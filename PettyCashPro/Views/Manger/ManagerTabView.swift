//
//  ManagerTabView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct ManagerTabView: View {
    @EnvironmentObject var managerVM: ManagerViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ManagerDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)

            ApprovalListView()
                .tabItem {
                    Label("Approvals", systemImage: "checkmark.seal.fill")
                }
                .badge(managerVM.pendingRequests.count)
                .tag(1)

            BudgetControlView()
                .tabItem {
                    Label("Budget", systemImage: "chart.pie.fill")
                }
                .tag(2)

            ManagerProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(Color(hex: "#5856D6"))
    }
}
