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
           Text("test")
        }
        .accentColor(Color(hex: "#5856D6"))
    }
}
