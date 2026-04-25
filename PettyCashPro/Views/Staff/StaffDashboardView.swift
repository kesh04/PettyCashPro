//
//  StaffDashboardView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct StaffDashboardView: View {
    @EnvironmentObject var staffVM: StaffViewModel
    @EnvironmentObject var authVM: AuthViewModel
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
                    .padding(AppDesign.cardPadding)
                    .cardStyle()
                    .padding(.horizontal, AppDesign.screenPadding)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)

                    // Stats row
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
                        SectionHeader(title: "Recent Requests", actionTitle: "View All") {}
                            .padding(.horizontal, AppDesign.screenPadding)

                        ForEach(Array(staffVM.myRequests.prefix(3))) { request in
                            RequestRowItem(request: request)
                                .padding(.horizontal, AppDesign.screenPadding)
                        }
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 30)

       
//                    NavigationLink(destination: SubmitRequestView()) {
//                        HStack(spacing: 10) {
//                            Image(systemName: "plus.circle.fill")
//                                .font(.system(size: 20))
//                            Text("Submit new expense")
//                                .font(.system(size: 16, weight: .semibold))
//                        }
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 56)
//                        .background(
//                            LinearGradient(colors: [Color.primaryBlue, Color.darkBlue],
//                                           startPoint: .leading, endPoint: .trailing)
//                        )
//                        .cornerRadius(16)
//                        .shadow(color: Color.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 4)
//                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.bottom, 20)
                    .opacity(animateIn ? 1 : 0)
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.1)) {
                animateIn = true
            }
        }
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
        .cardStyle()
    }
}
