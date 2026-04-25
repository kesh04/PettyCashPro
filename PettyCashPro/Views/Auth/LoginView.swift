import SwiftUI

struct LoginView: View {
    let role: UserRole
    @EnvironmentObject var authVM: AuthViewModel
    @State private var animateIn = false
    @Environment(\.dismiss) var dismiss

    var accentColor: Color { role == .staff ? .primaryBlue : Color(hex: "#5856D6") }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
            
                    VStack(spacing: 20) {
                  
                        HStack {
                            Spacer()
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [accentColor, accentColor.opacity(0.7)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 72, height: 72)
                                        .shadow(color: accentColor.opacity(0.35), radius: 14, x: 0, y: 6)
                                    Image(systemName: "building.columns.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                }
                                Text("PettyCash Pro")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.textPrimary)
                            }
                            Spacer()
                        }
                        .padding(.top, 20)

                        VStack(spacing: 6) {
                            Text("Welcome Back")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.textPrimary)
                            Text("Access your fluid ledger dashboard")
                                .font(.system(size: 15))
                                .foregroundColor(.textSecondary)
                        }

                
                        HStack(spacing: 8) {
                            Image(systemName: role == .staff ? "person.fill" : "person.badge.shield.checkmark.fill")
                                .font(.system(size: 13))
                            Text("Signing in as \(role.rawValue)")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(accentColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(accentColor.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : -20)
                    .padding(.horizontal, AppDesign.screenPadding)

                    Spacer().frame(height: 36)

         
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("EMAIL ADDRESS")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .tracking(0.8)
                            InputField(placeholder: "name@company.com",
                                       text: $authVM.email,
                                       keyboardType: .emailAddress)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("PASSWORD")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                    .tracking(0.8)
                                Spacer()
                                Button("Forgot Password?") {}
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(accentColor)
                            }
                            InputField(placeholder: "••••••••",
                                       text: $authVM.password,
                                       isSecure: true)
                        }

                        if let error = authVM.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                Text(error)
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.rejectedColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

              
                        Button {
                            authVM.selectedRole = role
                            authVM.login()
                        } label: {
                            HStack {
                                if authVM.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Log In")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(colors: [accentColor, accentColor.opacity(0.8)],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(14)
                            .shadow(color: accentColor.opacity(0.3), radius: 10, x: 0, y: 4)
                        }

               
                        Button {
                            authVM.selectedRole = role
                            authVM.loginWithBiometrics()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "faceid")
                                    .font(.system(size: 18))
                                Text("Use Biometrics")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.bgPrimary)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.borderColor, lineWidth: 1)
                            )
                        }
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)
                    .padding(.horizontal, AppDesign.screenPadding)

                    Spacer().frame(height: 40)

        
                    HStack {
                        Text("Need help?")
                            .foregroundColor(.textSecondary)
                        Button("Contact Support") {}
                            .foregroundColor(accentColor)
                    }
                    .font(.system(size: 14))
                    .opacity(animateIn ? 1 : 0)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateIn = true
            }
        }
    }
}
