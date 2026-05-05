//
//  StaffProfileView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//


import SwiftUI
import LocalAuthentication

struct StaffProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.colorScheme) var colorScheme

    @State private var showBiometricInfo = false
    @State private var showChangePassword = false

    var user: AppUser { authVM.currentUser ?? SampleData.staffUser }


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
                                color: Color(hex: "#5856D6"),
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
                                            .foregroundColor(deviceHasBiometrics ? .accentGreen : .rejectedColor)
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
                                        Text("Enroll Face ID / Touch ID in iOS Settings → Face ID & Passcode")
                                            .font(.system(size: 11))
                                            .foregroundColor(.textSecondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 10)
                                    .background(Color.bgCard)
                                }
                            }

                     
                            ProfileActionRow(
                                icon: "lock.fill",
                                title: "Change Password",
                                color: Color(hex: "#5856D6")
                            ) { showChangePassword = true }

                   
                            ProfileActionRow(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support",
                                color: .accentGreen
                            ) {}

                  
                            ProfileActionRow(
                                icon: "info.circle.fill",
                                title: "About PettyCash Pro",
                                color: .textSecondary
                            ) {}
                        }
                        .background(Color.bgCard)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                        .padding(.horizontal, AppDesign.screenPadding)
                    }

                    
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


struct ProfileToggleRow: View {
    let icon: String
    let title: String
    let color: Color
    @Binding var isOn: Bool

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
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.bgCard)
    }
}


struct ProfileActionRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
            .background(Color.bgCard)
        }
        .buttonStyle(.plain)
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
        .background(Color.bgCard)
    }
}

