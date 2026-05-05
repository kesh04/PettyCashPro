//
//  MyRequestsView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct MyRequestsView: View {
    @EnvironmentObject var staffVM: StaffViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

           
                Text("My Requests")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

         
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(label: "All", isSelected: staffVM.filterStatus == nil) {
                            staffVM.filterStatus = nil
                        }
                        FilterChip(label: "Pending", isSelected: staffVM.filterStatus == "Pending") {
                            staffVM.filterStatus = "Pending"
                        }
                        FilterChip(label: "Approved", isSelected: staffVM.filterStatus == "Approved") {
                            staffVM.filterStatus = "Approved"
                        }
                        FilterChip(label: "Rejected", isSelected: staffVM.filterStatus == "Rejected") {
                            staffVM.filterStatus = "Rejected"
                        }
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.bottom, 12)
                }

         
                if staffVM.isLoading {
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                } else if staffVM.filteredRequests.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.textSecondary.opacity(0.3))
                        Text("No requests found")
                            .font(.system(size: 16))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(staffVM.filteredRequests) { request in
                                NavigationLink(destination: APIRequestDetailView(request: request)) {
                                    APIRequestRowItem(request: request)
                                        .padding(.horizontal, AppDesign.screenPadding)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        await staffVM.loadMyRequests()
                    }
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
            .task {
                await staffVM.loadMyRequests()
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.primaryBlue : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.primaryBlue : Color.borderColor, lineWidth: 1)
                )
        }
    }
}

struct APIRequestDetailView: View {
    let request: APIExpenseRequest
    @Environment(\.dismiss) var dismiss

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

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryBlue)
                    }
                    Spacer()
                    Text("Request Detail")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Color.clear.frame(width: 28)
                }
                .padding(.horizontal, AppDesign.screenPadding)
                .padding(.top, 16)

                VStack(spacing: 8) {
                    Text("TOTAL AMOUNT")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .tracking(0.8)
                    Text(request.formattedAmount)
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .cardStyle()
                .padding(.horizontal, AppDesign.screenPadding)

                HStack(spacing: 12) {
                    Image(systemName: request.status == "Approved" ? "checkmark.circle.fill"
                          : request.status == "Rejected" ? "xmark.circle.fill" : "clock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(statusColor)
                    Text(request.status)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(statusColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(statusColor.opacity(0.1))
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(statusColor.opacity(0.3), lineWidth: 1))
                .padding(.horizontal, AppDesign.screenPadding)

                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(label: "Category", value: request.category, icon: categoryEnum.icon)
                    Divider()
                    DetailRow(label: "Submitted", value: request.formattedDate, icon: "calendar")
                    Divider()
                    DetailRow(label: "Reason", value: request.reason, icon: "text.alignleft")
                    if request.isUrgent {
                        Divider()
                        DetailRow(label: "Priority", value: "Urgent", icon: "exclamationmark.circle.fill")
                    }
                    if let comment = request.managerComment, !comment.isEmpty {
                        Divider()
                        DetailRow(label: "Manager Comment", value: comment, icon: "bubble.left.fill")
                    }
                }
                .padding(AppDesign.cardPadding)
                .cardStyle()
                .padding(.horizontal, AppDesign.screenPadding)

                Spacer().frame(height: 30)
            }
        }
        .background(Color.bgPrimary.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.primaryBlue)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .tracking(0.6)
                Text(value)
                    .font(.system(size: 15))
                    .foregroundColor(.textPrimary)
            }
            Spacer()
        }
    }
}
