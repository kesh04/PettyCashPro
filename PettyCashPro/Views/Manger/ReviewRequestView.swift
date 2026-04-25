//
//  ReviewRequestView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct ReviewRequestView: View {
    let request: ExpenseRequest
    @EnvironmentObject var managerVM: ManagerViewModel
    @Environment(\.dismiss) var dismiss
    @State private var rejectComment: String = ""
    @State private var showRejectSheet = false
    @State private var actionTaken = false
    @State private var actionWasApproval = false

    var currentRequest: ExpenseRequest {
        managerVM.requests.first(where: { $0.id == request.id }) ?? request
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
                    Text("Review Request")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 28, height: 28)
                }
                .padding(.horizontal, AppDesign.screenPadding)
                .padding(.top, 16)

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.primaryBlue, Color.darkBlue],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 60, height: 60)
                        Text(request.staffInitials)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(request.staffName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text("\(request.staffDepartment) Request")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                }
                .padding(AppDesign.cardPadding)
                .cardStyle()
                .padding(.horizontal, AppDesign.screenPadding)

                VStack(spacing: 8) {
                    Text("TOTAL AMOUNT")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .tracking(0.8)
                    Text(request.formattedAmount)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .cardStyle()
                .padding(.horizontal, AppDesign.screenPadding)

                HStack(spacing: 14) {
                    DetailInfoCard(title: "CATEGORY", value: request.category.rawValue,
                                   icon: request.category.icon, color: request.category.color)
                    DetailInfoCard(title: "SUBMITTED", value: "Today",
                                   icon: "calendar", color: .primaryBlue)
                }
                .padding(.horizontal, AppDesign.screenPadding)

                VStack(alignment: .leading, spacing: 10) {
                    Text("DESCRIPTION")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .tracking(0.8)
                    Text(request.reason)
                        .font(.system(size: 15))
                        .foregroundColor(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppDesign.cardPadding)
                .cardStyle()
                .padding(.horizontal, AppDesign.screenPadding)

               
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("RECEIPT PHOTO")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .tracking(0.8)
                        Spacer()
                        Button("View Fullscreen") {}
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primaryBlue)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.bgPrimary)
                            .frame(height: 200)
                        VStack(spacing: 12) {
                            Image(systemName: "receipt")
                                .font(.system(size: 48))
                                .foregroundColor(.textSecondary.opacity(0.3))
                            Text("Receipt image attached")
                                .font(.system(size: 13))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(AppDesign.cardPadding)
                .cardStyle()
                .padding(.horizontal, AppDesign.screenPadding)


                if currentRequest.status == .pending && !actionTaken {
                
                    VStack(spacing: 12) {
                        Button {
                            withAnimation { showRejectSheet = true }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "xmark.circle.fill")
                                Text("Reject Request")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.rejectedColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.rejectedColor.opacity(0.1))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rejectedColor.opacity(0.3), lineWidth: 1))
                        }

                        Button {
                            managerVM.approve(request: request)
                            withAnimation { actionTaken = true; actionWasApproval = true }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Approve Request")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(colors: [Color.approvedColor, Color.approvedColor.opacity(0.8)],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.approvedColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                } else {
   
                    let status = actionTaken ? (actionWasApproval ? RequestStatus.approved : .rejected) : currentRequest.status
                    HStack(spacing: 12) {
                        Image(systemName: status == .approved ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(status.color)
                        Text("Request \(status == .approved ? "Approved" : "Rejected")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(status.color)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(status.color.opacity(0.1))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(status.color.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, AppDesign.screenPadding)
                }

                Spacer().frame(height: 30)
            }
        }
        .background(Color.bgPrimary.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showRejectSheet) {
            RejectSheet(request: request, onReject: { comment in
                managerVM.reject(request: request, comment: comment)
                withAnimation { actionTaken = true; actionWasApproval = false }
                showRejectSheet = false
            })
        }
    }
}


struct RejectSheet: View {
    let request: ExpenseRequest
    let onReject: (String) -> Void
    @State private var comment: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.borderColor)
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            VStack(spacing: 8) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.rejectedColor)
                Text("Reject Request")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textPrimary)
                Text("\(request.staffName) — \(request.formattedAmount)")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Rejection Reason (optional)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textPrimary)

                ZStack(alignment: .topLeading) {
                    if comment.isEmpty {
                        Text("Explain why this request is being rejected...")
                            .font(.system(size: 15))
                            .foregroundColor(.textSecondary.opacity(0.6))
                            .padding(14)
                    }
                    TextEditor(text: $comment)
                        .font(.system(size: 15))
                        .frame(height: 120)
                        .padding(10)
                }
                .background(Color.bgPrimary)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderColor, lineWidth: 1))
            }
            .padding(.horizontal, AppDesign.screenPadding)

            HStack(spacing: 14) {
                Button { dismiss() } label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.bgPrimary)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borderColor, lineWidth: 1))
                }

                Button {
                    onReject(comment)
                } label: {
                    Text("Reject")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.rejectedColor)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, AppDesign.screenPadding)
            .padding(.bottom, 30)
        }
        .background(Color.white)
    }
}
