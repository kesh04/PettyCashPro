//
//  StaffDashboardView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//


import SwiftUI
import AppIntents

struct StaffDashboardView: View {
    @EnvironmentObject var staffVM: StaffViewModel
    @EnvironmentObject var authVM: AuthViewModel

    @Binding var selectedTab: Int
    @State private var animateIn = false

    var user: AppUser { authVM.currentUser ?? SampleData.staffUser }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good morning,")
                                .font(.system(size: 16))
                                .foregroundColor(.textSecondary)
                            Text(user.name.components(separatedBy: " ").first ?? user.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primaryBlue)
                            Text("Employee · \(user.department)")
                                .font(.system(size: 13))
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color.primaryBlue, Color.darkBlue],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 48, height: 48)
                            Text(user.initials)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("MY PENDING REQUESTS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .tracking(0.8)

                        if staffVM.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            HStack(alignment: .lastTextBaseline, spacing: 8) {
                                Text("\(staffVM.pendingCount)")
                                    .font(.system(size: 52, weight: .bold))
                                    .foregroundColor(.textPrimary)
                                Text("awaiting approval")
                                    .font(.system(size: 16))
                                    .foregroundColor(.textSecondary)
                                    .padding(.bottom, 8)
                            }

                            HStack(spacing: 20) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.approvedColor)
                                    Text("\(staffVM.approvedCount) approved this month")
                                        .font(.system(size: 13))
                                        .foregroundColor(.textSecondary)
                                }
                                HStack(spacing: 6) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.rejectedColor)
                                    Text("\(staffVM.rejectedCount) rejected")
                                        .font(.system(size: 13))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                    }
                    .padding(AppDesign.cardPadding)
                    .cardStyle()
                    .padding(.horizontal, AppDesign.screenPadding)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)

                    HStack(spacing: 14) {
                        StatCard(
                            title: "APPROVED",
                            value: "LKR \(Int(staffVM.approvedThisMonth / 1000))K",
                            subtitle: "This month",
                            valueColor: .approvedColor
                        )
                        StatCard(
                            title: "PENDING",
                            value: "LKR \(Int(staffVM.pendingAmount / 1000))K",
                            subtitle: "Under review",
                            valueColor: .pendingColor
                        )
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 25)

                    VStack(spacing: 14) {
                        SectionHeader(title: "Recent Requests") {}
                            .padding(.horizontal, AppDesign.screenPadding)

                        if staffVM.myRequests.isEmpty && !staffVM.isLoading {
                            Text("No requests yet. Submit your first one!")
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                                .padding()
                        } else {
                            ForEach(Array(staffVM.myRequests.prefix(3))) { request in
                                APIRequestRowItem(request: request)
                                    .padding(.horizontal, AppDesign.screenPadding)
                            }
                        }
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 30)

                    VStack(spacing: 12) {
                        Button {
                            selectedTab = 1
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Submit new expense")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(colors: [Color.primaryBlue, Color.darkBlue],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 4)
                        }

                        SiriShortcutCard()
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.bottom, 20)
                    .opacity(animateIn ? 1 : 0)
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
            .task {
                await staffVM.loadMyRequests()
            }
            .refreshable {
                await staffVM.loadMyRequests()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.1)) {
                animateIn = true
            }
        }
    }
}


struct APIRequestRowItem: View {
    let request: APIExpenseRequest

    var categoryEnum: ExpenseCategory {
        ExpenseCategory(rawValue: request.category) ?? .other
    }

    var statusColor: Color {
        switch request.status {
        case "Approved": return .approvedColor
        case "Rejected": return .rejectedColor
        default: return .pendingColor
        }
    }

    var statusIcon: String {
        switch request.status {
        case "Approved": return "checkmark.circle.fill"
        case "Rejected": return "xmark.circle.fill"
        default: return "clock.fill"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(categoryEnum.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: categoryEnum.icon)
                    .font(.system(size: 18))
                    .foregroundColor(categoryEnum.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(request.reason)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                Text("\(request.category) · \(request.formattedDate)")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(request.formattedAmount)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textPrimary)
                HStack(spacing: 4) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 10))
                    Text(request.status)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(statusColor.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}



struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let valueColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.textSecondary)
                .tracking(0.6)
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(valueColor)
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDesign.cardPadding)
        .cardStyle()
    }
}



struct RequestRowItem: View {
    let request: ExpenseRequest

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(request.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: request.category.icon)
                    .font(.system(size: 18))
                    .foregroundColor(request.category.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(request.reason)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                Text("\(request.category.rawValue) · \(request.formattedDate)")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(request.formattedAmount)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textPrimary)
                StatusBadge(status: request.status)
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}


struct SiriShortcutCard: View {

    @State private var showSiriTip = false

    var body: some View {
        Button {
            showSiriTip = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#5E5CE6"), Color(hex: "#BF5AF2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    Image(systemName: "mic.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Use Siri to Submit")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text("\"Submit a petty cash request\"")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#5E5CE6"))
                        .italic()
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }
            .padding(14)
            .background(Color.bgCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#5E5CE6").opacity(0.4), Color(hex: "#BF5AF2").opacity(0.4)],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color(hex: "#5E5CE6").opacity(0.12), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSiriTip) {
            SiriHowToUseSheet()
        }
    }
}


struct SiriHowToUseSheet: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#5E5CE6"), Color(hex: "#BF5AF2")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 90, height: 90)
                        Image(systemName: "mic.fill")
                            .font(.system(size: 38))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 30)

                    VStack(spacing: 6) {
                        Text("Siri Shortcuts")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text("Submit and check requests with your voice")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 14) {
                        SiriCommandCard(
                            phrase: "Submit a petty cash request in PettyCash Pro",
                            description: "Siri will ask for the amount, category, and reason, then submit it for you.",
                            icon: "paperplane.fill",
                            color: Color(hex: "#5E5CE6")
                        )
                        SiriCommandCard(
                            phrase: "Check my petty cash status in PettyCash Pro",
                            description: "Siri will tell you how many requests are pending, approved, or rejected.",
                            icon: "clock.fill",
                            color: Color(hex: "#BF5AF2")
                        )
                    }
                    .padding(.horizontal, 20)

                 
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How to use")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.textPrimary)

                        SiriStep(number: "1", text: "Make sure you are logged in to PettyCash Pro.")
                        SiriStep(number: "2", text: "Press the side button or say \"Hey Siri\".")
                        SiriStep(number: "3", text: "Say the phrase shown above exactly.")
                        SiriStep(number: "4", text: "Siri will ask for details — just speak your answer.")
                        SiriStep(number: "5", text: "Siri will confirm when your request is submitted!")
                    }
                    .padding(20)
                    .background(Color.bgCard)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 20)
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#5E5CE6"))
                }
            }
        }
    }
}



struct SiriCommandCard: View {
    let phrase: String
    let description: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundColor(color)
                }
                Text("Say to Siri:")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textSecondary)
            }

            Text("\" \(phrase) \"")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(color.opacity(0.08))
                .cornerRadius(10)

            Text(description)
                .font(.system(size: 13))
                .foregroundColor(.textSecondary)
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}


struct SiriStep: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#5E5CE6").opacity(0.15))
                    .frame(width: 28, height: 28)
                Text(number)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#5E5CE6"))
            }
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
