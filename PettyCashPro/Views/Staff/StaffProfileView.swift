//
//  StaffProfileView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct StaffProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var user: AppUser { authVM.currentUser ?? SampleData.staffUser }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color.primaryBlue, Color.darkBlue],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 90, height: 90)
                                .shadow(color: Color.primaryBlue.opacity(0.3), radius: 16, x: 0, y: 6)
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
                            Text(user.department)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primaryBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color.lightBlue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 30)


                    VStack(spacing: 1) {
                        ProfileRow(icon: "bell.fill", title: "Notifications", color: .accentOrange)
                        ProfileRow(icon: "faceid", title: "Biometric Login", color: .primaryBlue)
                        ProfileRow(icon: "lock.fill", title: "Change Password", color: Color(hex: "#5856D6"))
                        ProfileRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .accentGreen)
                        ProfileRow(icon: "info.circle.fill", title: "About PettyCash Pro", color: .textSecondary)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, AppDesign.screenPadding)

  
                    Button {
                        authVM.logout()
                    } label: {
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

struct ProfileRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(color)
            }
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textSecondary.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
    }
}
