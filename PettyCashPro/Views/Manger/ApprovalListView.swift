//
//  ApprovalListView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct ApprovalListView: View {
    @EnvironmentObject var managerVM: ManagerViewModel
    @State private var requestToReject: APIExpenseRequest? = nil
    @State private var showRejectSheet = false

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
                          
                            let urgentCount = managerVM.pendingRequests.filter { $0.isUrgent }.count
                            if urgentCount > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 11))
                                    Text("\(urgentCount) urgent")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(Color(hex: "#FF6B35"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(hex: "#FF6B35").opacity(0.12))
                                .cornerRadius(10)
                            }
                        }
                        .padding(14)
                        .background(Color.lightBlue)
                        .cornerRadius(12)
                    }

                   
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ManagerViewModel.ApprovalFilter.allCases, id: \.self) { filter in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        managerVM.selectedFilter = filter
                                    }
                                } label: {
                                    HStack(spacing: 5) {
                                        Text(filter.rawValue)
                                            .font(.system(size: 13, weight: .medium))
                                    
                                        let count = countForFilter(filter)
                                        if count > 0 {
                                            Text("\(count)")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(managerVM.selectedFilter == filter ? Color(hex: "#5856D6") : .textSecondary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(managerVM.selectedFilter == filter ? Color.white.opacity(0.3) : Color(UIColor.systemGray5))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .foregroundColor(managerVM.selectedFilter == filter ? .white : .textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(managerVM.selectedFilter == filter ? Color(hex: "#5856D6") : Color.white)
                                    .cornerRadius(20)
                                    .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(managerVM.selectedFilter == filter ? Color(hex: "#5856D6") : Color.borderColor, lineWidth: 1))
                                }
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
                                ApprovalListCard(request: request) {
                   
                                    managerVM.approve(request: request)
                                } onReject: {
                     
                                    requestToReject = request
                                    showRejectSheet = true
                                }
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

            .sheet(isPresented: $showRejectSheet) {
                if let req = requestToReject {
                    RejectCommentSheet(request: req) { comment in
                        managerVM.reject(request: req, comment: comment)
                        showRejectSheet = false
                        requestToReject = nil
                    } onCancel: {
                        showRejectSheet = false
                        requestToReject = nil
                    }
                }
            }
        }
    }

    private func countForFilter(_ filter: ManagerViewModel.ApprovalFilter) -> Int {
        let pending = managerVM.pendingRequests
        switch filter {
        case .allPending: return pending.count
        case .urgent:     return pending.filter { $0.isUrgent }.count
        case .highAmount: return pending.filter { $0.amount >= 5000 }.count
        }
    }
}



struct RejectCommentSheet: View {
    let request: APIExpenseRequest
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    @State private var comment: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
      
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(UIColor.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)

            VStack(spacing: 20) {
              
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.rejectedColor.opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.rejectedColor)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Reject Request")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text("\(request.staffName) · \(request.formattedAmount)")
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                }
                HStack(spacing: 10) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.primaryBlue)
                        .font(.system(size: 14))
                    Text(request.category)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    if request.isUrgent {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill").font(.system(size: 10))
                            Text("URGENT").font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(Color(hex: "#FF6B35"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#FF6B35").opacity(0.12))
                        .cornerRadius(8)
                    }
                }
                .padding(12)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)

 
                VStack(alignment: .leading, spacing: 8) {
                    Text("REASON FOR REJECTION")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .tracking(0.8)

                    ZStack(alignment: .topLeading) {
                        if comment.isEmpty {
                            Text("Provide a reason so the staff member can resubmit correctly...")
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary.opacity(0.6))
                                .padding(14)
                        }
                        TextEditor(text: $comment)
                            .font(.system(size: 14))
                            .frame(minHeight: 100)
                            .padding(10)
                            .focused($isFocused)
                    }
                    .background(Color.bgPrimary)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderColor, lineWidth: 1))
                }

    
                VStack(alignment: .leading, spacing: 8) {
                    Text("QUICK REASONS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .tracking(0.8)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quickReasons, id: \.self) { reason in
                                Button(action: { comment = reason }) {
                                    Text(reason)
                                        .font(.system(size: 12))
                                        .foregroundColor(.primaryBlue)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(Color.primaryBlue.opacity(0.08))
                                        .cornerRadius(16)
                                        .overlay(RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.primaryBlue.opacity(0.25), lineWidth: 1))
                                }
                            }
                        }
                    }
                }

         
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderColor, lineWidth: 1))
                    }

                    Button(action: {
                        let finalComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
                        onConfirm(finalComment.isEmpty ? "Request rejected." : finalComment)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                            Text("Reject")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.rejectedColor)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.bgPrimary)
        .onAppear { isFocused = true }
    }

    private var quickReasons: [String] {
        [
            "Insufficient documentation",
            "Exceeds budget limit",
            "Not a valid expense",
            "Duplicate submission",
            "Wrong category selected"
        ]
    }
}


struct ApprovalListCard: View {
    let request: APIExpenseRequest
    let onApprove: () -> Void
    let onReject: () -> Void
    @EnvironmentObject var managerVM: ManagerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(request.isUrgent ? Color(hex: "#FF6B35").opacity(0.12) : Color.primaryBlue.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Text(request.staffInitials)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(request.isUrgent ? Color(hex: "#FF6B35") : .primaryBlue)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(request.staffName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    Text("\(request.staffDepartment) · \(request.formattedDate)")
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
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10))
                            Text("URGENT")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(Color(hex: "#FF6B35"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#FF6B35").opacity(0.12))
                        .cornerRadius(8)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 3) {
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
                Button(action: onReject) {
                    Text("Reject")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.bgPrimary)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderColor, lineWidth: 1))
                }

                Button(action: onApprove) {
                    HStack(spacing: 6) {
                        if managerVM.isActionLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Approve")
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.primaryBlue)
                    .cornerRadius(12)
                }
                .disabled(managerVM.isActionLoading)
            }
        }
        .padding(AppDesign.cardPadding)
        .cardStyle()
       
        .overlay(
            Rectangle()
                .fill(request.isUrgent ? Color(hex: "#FF6B35") : Color.clear)
                .frame(width: 4)
                .cornerRadius(4),
            alignment: .leading
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
