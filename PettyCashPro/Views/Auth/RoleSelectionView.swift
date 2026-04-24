import SwiftUI

struct RoleSelectionView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var animateIn = false

    var body: some View {
        NavigationStack {
            ZStack {
              
                LinearGradient(
                    colors: [Color(hex: "#EBF2FF"), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color.primaryBlue, Color.darkBlue],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 100, height: 100)
                                .shadow(color: Color.primaryBlue.opacity(0.4), radius: 20, x: 0, y: 10)

                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(animateIn ? 1 : 0.6)
                        .opacity(animateIn ? 1 : 0)

                        VStack(spacing: 6) {
                            Text("PettyCash Pro")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.textPrimary)

                            Text("Enterprise Financial Management")
                                .font(.system(size: 15))
                                .foregroundColor(.textSecondary)
                        }
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                    }

                    Spacer()
                    Spacer()

              
                    VStack(spacing: 16) {
                        Text("Select your role to continue")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .opacity(animateIn ? 1 : 0)

                        NavigationLink {
                            LoginView(role: .staff)
                        } label: {
                            RoleCard(
                                title: "Staff",
                                subtitle: "Submit & track expenses",
                                icon: "person.fill",
                                color: Color.primaryBlue,
                                isSelected: false
                            )
                        }
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 30)

                        NavigationLink {
                            LoginView(role: .manager)
                        } label: {
                            RoleCard(
                                title: "Manager",
                                subtitle: "Approve & control budget",
                                icon: "person.badge.shield.checkmark.fill",
                                color: Color(hex: "#5856D6"),
                                isSelected: false
                            )
                        }
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 40)
                    }
                    .padding(.horizontal, AppDesign.screenPadding)

                    Spacer()

               
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.accentGreen)
                            .font(.system(size: 13))
                        Text("Secure Endpoint · Biometric Protected")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    .opacity(animateIn ? 1 : 0)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
                animateIn = true
            }
        }
    }
}

struct RoleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(color.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textSecondary.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}
