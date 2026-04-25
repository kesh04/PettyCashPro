//
//  ApprovalListView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct ApprovalListView: View {
    @EnvironmentObject var managerVM: ManagerViewModel
    @State private var selectedRequest: ExpenseRequest? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                VStack(spacing: 14) {
                    Text("Pending Requests")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

      
                    if !managerVM.pendingRequests.isEmpty {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.primaryBlue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(managerVM.pendingRequests.count) requests need approval")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primaryBlue)
                                let total = managerVM.pendingRequests.reduce(0) { $0 + $1.amount }
                                Text("Total pending: LKR \(Int(total).formattedWithSeparator)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.lightBlue)
                        .cornerRadius(12)
                    }

        
                    HStack(spacing: 10) {
                        ForEach(ManagerViewModel.ApprovalFilter.allCases, id: \.self) { filter in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    managerVM.selectedFilter = filter
                                }
                            } label: {
                                Text(filter.rawValue)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(managerVM.selectedFilter == filter ? .white : .textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(managerVM.selectedFilter == filter ?
                                                Color(hex: "#5856D6") : Color.white)
                                    .cornerRadius(20)
                                    .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(managerVM.selectedFilter == filter ?
                                                Color(hex: "#5856D6") : Color.borderColor, lineWidth: 1))
                            }
                        }
                    }
                }
                .padding(.horizontal, AppDesign.screenPadding)
                .padding(.top, 20)
                .padding(.bottom, 16)

    
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(managerVM.filteredPendingRequests) { request in
                            NavigationLink(destination: ReviewRequestView(request: request)) {
                                ApprovalListCard(request: request)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, AppDesign.screenPadding)
                        }

                        if managerVM.filteredPendingRequests.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.approvedColor.opacity(0.5))
                                Text("All caught up!")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                Text("No pending requests")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(.top, 60)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.bottom, 30)
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}


struct ApprovalListCard: View {
    let request: ExpenseRequest
    @EnvironmentObject var managerVM: ManagerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
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
                    Text("\(request.staffDepartment) · \(request.isUrgent ? "2 hours ago" : "Yesterday")")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(request.formattedAmount)
                        .font(.system(size: 16, weight: .bold))
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

            VStack(alignment: .leading, spacing: 3) {
                Text(request.category.rawValue.uppercased())
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
                    managerVM.reject(request: request, comment: "Request rejected.")
                } label: {
                    Text("Reject")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.bgPrimary)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderColor, lineWidth: 1))
                }

                Button {
                    managerVM.approve(request: request)
                } label: {
                    Text("Approve")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.primaryBlue)
                        .cornerRadius(12)
                }
            }
        }
        .padding(AppDesign.cardPadding)
        .cardStyle()
    }
}
