//
//  ManagerProfileView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI
import LocalAuthentication

struct ManagerProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var managerVM: ManagerViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.colorScheme) var colorScheme

    var user: AppUser { authVM.currentUser ?? SampleData.managerUser }
    let managerAccent = Color(hex: "#5856D6")

    var deviceBiometricType: String {
        let ctx = LAContext()
        var err: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else {
            return "Unavailable"
        }
        return ctx.biometryType == .faceID ? "Face ID" : "Touch ID"
    }

    var deviceHasBiometrics: Bool {
        let ctx = LAContext()
        var err: NSError?
        return ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err)
    }

    var staffMembers: [(name: String, department: String, initials: String, approved: Int, pending: Int)] {
        var seen: Set<String> = []
        var result: [(name: String, department: String, initials: String, approved: Int, pending: Int)] = []
        for req in managerVM.requests {
            if !seen.contains(req.staffName) {
                seen.insert(req.staffName)
                let approved = managerVM.requests.filter { $0.staffName == req.staffName && $0.status == "Approved" }.count
                let pending  = managerVM.requests.filter { $0.staffName == req.staffName && $0.status == "Pending" }.count
                result.append((
                    name: req.staffName,
                    department: req.staffDepartment,
                    initials: req.staffInitials,
                    approved: approved,
                    pending: pending
                ))
            }
        }
        return result.sorted { $0.name < $1.name }
    }

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
                        MiniStatCard(value: "\(managerVM.pendingRequests.count)",
                                     label: "Pending", color: .accentOrange)
                        MiniStatCard(value: "\(managerVM.requests.filter { $0.status == "Approved" }.count)",
                                     label: "Approved", color: .approvedColor)
                        MiniStatCard(value: "\(managerVM.requests.filter { $0.status == "Rejected" }.count)",
                                     label: "Rejected", color: .rejectedColor)
                    }
                    .padding(.horizontal, AppDesign.screenPadding)

        
                    VStack(alignment: .leading, spacing: 0) {
                        Text("PREFERENCES")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .tracking(0.8)
                            .padding(.horizontal, AppDesign.screenPadding)
                            .padding(.bottom, 8)

                        VStack(spacing: 1) {

              
                            ProfileToggleRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                color: .accentOrange,
                                isOn: $appSettings.isNotificationsEnabled
                            )

                           
                            ProfileToggleRow(
                                icon: colorScheme == .dark ? "moon.fill" : "sun.max.fill",
                                title: "Dark Mode",
                                color: managerAccent,
                                isOn: $appSettings.isDarkMode
                            )

                            VStack(spacing: 0) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.primaryBlue.opacity(0.12))
                                            .frame(width: 34, height: 34)
                                        Image(systemName: "faceid")
                                            .font(.system(size: 15))
                                            .foregroundColor(.primaryBlue)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Biometric Login")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.textPrimary)
                                        Text(deviceHasBiometrics
                                             ? "\(deviceBiometricType) available"
                                             : "Not available on this device")
                                            .font(.system(size: 11))
                                            .foregroundColor(deviceHasBiometrics ? .approvedColor : .rejectedColor)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $appSettings.isBiometricEnabled)
                                        .labelsHidden()
                                        .tint(.primaryBlue)
                                        .disabled(!deviceHasBiometrics)
                                        .opacity(deviceHasBiometrics ? 1 : 0.4)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.bgCard)

                                if !deviceHasBiometrics {
                                    HStack(spacing: 6) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(.accentOrange)
                                        Text("Enroll Face ID in iOS Settings → Face ID & Passcode")
                                            .font(.system(size: 11))
                                            .foregroundColor(.textSecondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 10)
                                    .background(Color.bgCard)
                                }
                            }

          
                            ProfileActionRow(
                                icon: "lock.fill",
                                title: "Change Password",
                                color: managerAccent
                            ) {}

                 
                            ProfileActionRow(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support",
                                color: .textSecondary
                            ) {}

                          
                            ProfileActionRow(
                                icon: "info.circle.fill",
                                title: "About PettyCash Pro",
                                color: .accentGreen
                            ) {}
                        }
                        .background(Color.bgCard)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                        .padding(.horizontal, AppDesign.screenPadding)
                    }

                 
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("STAFF MEMBERS")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .tracking(0.8)
                            Spacer()
                            Text("\(staffMembers.count) members")
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, AppDesign.screenPadding)

                        if staffMembers.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "person.2.slash")
                                        .font(.system(size: 32))
                                        .foregroundColor(.textSecondary.opacity(0.3))
                                    Text("No staff requests yet")
                                        .font(.system(size: 13))
                                        .foregroundColor(.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 24)
                            .background(Color.bgCard)
                            .cornerRadius(16)
                            .padding(.horizontal, AppDesign.screenPadding)
                        } else {
                            VStack(spacing: 1) {
                                ForEach(staffMembers, id: \.name) { member in
                                    StaffMemberRow(member: member, accentColor: managerAccent)
                                }
                            }
                            .background(Color.bgCard)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                            .padding(.horizontal, AppDesign.screenPadding)
                        }
                    }

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
            .task {
                await managerVM.loadAllRequests()
            }
        }
    }
}


struct StaffMemberRow: View {
    let member: (name: String, department: String, initials: String, approved: Int, pending: Int)
    let accentColor: Color

    var body: some View {
        HStack(spacing: 14) {
     
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [accentColor, accentColor.opacity(0.7)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                Text(member.initials)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }

        
            VStack(alignment: .leading, spacing: 3) {
                Text(member.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Text(member.department)
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }

            Spacer()


            HStack(spacing: 8) {
                VStack(spacing: 2) {
                    Text("\(member.approved)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.approvedColor)
                    Text("approved")
                        .font(.system(size: 9))
                        .foregroundColor(.textSecondary)
                }
                VStack(spacing: 2) {
                    Text("\(member.pending)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.accentOrange)
                    Text("pending")
                        .font(.system(size: 9))
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.bgCard)
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
