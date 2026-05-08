//
//  ManagerDashboardView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//


import SwiftUI

struct ManagerDashboardView: View {
    @EnvironmentObject var managerVM: ManagerViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var animateIn = false

    let managerAccent = Color(hex: "#5856D6")
    var user: AppUser { authVM.currentUser ?? SampleData.managerUser }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {


                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Manager Overview")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.textPrimary)
                            Text(user.name)
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [managerAccent, managerAccent.opacity(0.7)],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 48, height: 48)
                            Text(user.initials)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.top, 20)


                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(managerAccent.opacity(0.12))
                                .frame(width: 52, height: 52)
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(managerAccent)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text("\(managerVM.pendingRequests.count)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.textPrimary)
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.accentOrange)
                                    .font(.system(size: 16))
                            }
                            Text("PENDING APPROVALS")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.textSecondary)
                                .tracking(0.6)
                            Text("Action required")
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(AppDesign.cardPadding)
                    .cardStyle()
                    .padding(.horizontal, AppDesign.screenPadding)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)


                    VStack(spacing: 14) {
                        HStack(spacing: 14) {
                            StatCard(
                                title: "TOTAL APPROVED",
                                value: "LKR \(Int(managerVM.totalApproved / 1000))K",
                                subtitle: "This month",
                                valueColor: .approvedColor
                            )
                            StatCard(
                                title: "APPROVED COUNT",
                                value: "\(managerVM.requests.filter { $0.status == "Approved" }.count)",
                                subtitle: "Requests",
                                valueColor: managerAccent
                            )
                        }

        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TOTAL SPENT")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                                .tracking(0.6)
                            Text("LKR \(Int(managerVM.totalSpent).formattedWithSeparator)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)

     
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 8)
                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: geo.size.width * managerVM.budgetUtilization, height: 8)
                                }
                            }
                            .frame(height: 8)

                            Text("\(Int(managerVM.budgetUtilization * 100))% of Monthly budget")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(AppDesign.cardPadding)
                        .background(
                            LinearGradient(colors: [managerAccent, managerAccent.opacity(0.8)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(AppDesign.cornerRadius)
                        .shadow(color: managerAccent.opacity(0.3), radius: 12, x: 0, y: 4)
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 24)


                    VStack(spacing: 14) {
                        SectionHeader(title: "Pending Requests", actionTitle: "View All") {}
                            .padding(.horizontal, AppDesign.screenPadding)

                        ForEach(Array(managerVM.pendingRequests.prefix(3))) { request in
                            ManagerRequestCard(request: request)
                                .padding(.horizontal, AppDesign.screenPadding)
                        }
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 28)

                    Spacer().frame(height: 20)
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .task {
            await managerVM.loadAllRequests()
            await managerVM.loadBudget()
        }
        .refreshable {
            await managerVM.loadAllRequests()
            await managerVM.loadBudget()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.1)) {
                animateIn = true
            }
        }
    }
}


struct ManagerRequestCard: View {
    let request: APIExpenseRequest
    @EnvironmentObject var managerVM: ManagerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
           
                ZStack {
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Text(request.staffInitials)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primaryBlue)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(request.staffName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text("\(request.staffDepartment) · \(request.isUrgent ? "2 HOURS AGO" : "Yesterday")")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(request.formattedAmount)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.textPrimary)
                    if request.isUrgent {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                            Text("URGENT")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.accentOrange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentOrange.opacity(0.12))
                        .cornerRadius(8)
                    }
                }
            }

  
            VStack(alignment: .leading, spacing: 4) {
                Text(request.category.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .tracking(0.6)
                Text("\"\(request.reason)\"")
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }

            
            HStack(spacing: 12) {
                Button {
                    managerVM.reject(request: request, comment: "")
                } label: {
                    Text("Reject")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.bgPrimary)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.borderColor, lineWidth: 1))
                }

                Button {
                    managerVM.approve(request: request)
                } label: {
                    Text("Approve")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.primaryBlue)
                        .cornerRadius(10)
                }
            }
        }
        .padding(AppDesign.cardPadding)
        .cardStyle()
    }
}
