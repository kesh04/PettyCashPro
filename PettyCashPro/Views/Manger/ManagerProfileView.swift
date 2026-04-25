//
//  ManagerProfileView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct ManagerProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var managerVM: ManagerViewModel

    var user: AppUser { authVM.currentUser ?? SampleData.managerUser }
    let managerAccent = Color(hex: "#5856D6")

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {


                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [managerAccent, managerAccent.opacity(0.7)],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 90, height: 90)
                                .shadow(color: managerAccent.opacity(0.3), radius: 16, x: 0, y: 6)
                            Text(user.initials)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        VStack(spacing: 4) {
                            Text(user.name)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.textPrimary)
                            Text(user.email)
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                            Text("Manager · \(user.department)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(managerAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(managerAccent.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 30)

   
                    HStack(spacing: 14) {
                        MiniStatCard(value: "\(managerVM.pendingRequests.count)", label: "Pending", color: .accentOrange)
                        MiniStatCard(value: "\(managerVM.requests.filter { $0.status == .approved }.count)", label: "Approved", color: .approvedColor)
                        MiniStatCard(value: "\(managerVM.requests.filter { $0.status == .rejected }.count)", label: "Rejected", color: .rejectedColor)
                    }
                    .padding(.horizontal, AppDesign.screenPadding)


                    VStack(spacing: 1) {
                        ProfileRow(icon: "bell.fill", title: "Notification Preferences", color: .accentOrange)
                        ProfileRow(icon: "chart.bar.fill", title: "Export Monthly Report", color: managerAccent)
                        ProfileRow(icon: "faceid", title: "Biometric Login", color: .primaryBlue)
                        ProfileRow(icon: "lock.fill", title: "Change Password", color: Color(hex: "#5856D6"))
                        ProfileRow(icon: "person.2.fill", title: "Team Members", color: .accentGreen)
                        ProfileRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .textSecondary)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, AppDesign.screenPadding)


                    Button { authVM.logout() } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.backward.square.fill")
                            Text("Sign Out")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.rejectedColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.rejectedColor.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rejectedColor.opacity(0.2), lineWidth: 1))
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.bottom, 30)
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct MiniStatCard: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.08))
        .cornerRadius(14)
    }
}
