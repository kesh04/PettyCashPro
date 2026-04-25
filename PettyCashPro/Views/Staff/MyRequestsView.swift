//
//  MyRequestsView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct MyRequestsView: View {
    @EnvironmentObject var staffVM: StaffViewModel
    @State private var selectedFilter: RequestStatus? = nil

    var filterOptions: [(String, RequestStatus?)] = [
        ("All", nil),
        ("Pending", .pending),
        ("Approved", .approved),
        ("Rejected", .rejected)
    ]

    var filteredRequests: [ExpenseRequest] {
        guard let filter = selectedFilter else { return staffVM.myRequests }
        return staffVM.myRequests.filter { $0.status == filter }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                Text("Requests")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.top, 20)
                    .padding(.bottom, 16)


                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filterOptions, id: \.0) { label, status in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedFilter = status
                                }
                            } label: {
                                Text(label)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedFilter == status ? .white : .textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == status ? Color.primaryBlue : Color.white)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(selectedFilter == status ? Color.primaryBlue : Color.borderColor, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                }
                .padding(.bottom, 16)

       
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(filteredRequests) { request in
                            NavigationLink(destination: RequestDetailView(request: request)) {
                                RequestDetailRow(request: request)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, AppDesign.screenPadding)
                        }

                        if filteredRequests.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "tray")
                                    .font(.system(size: 48))
                                    .foregroundColor(.textSecondary.opacity(0.4))
                                Text("No requests found")
                                    .font(.system(size: 16))
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


struct RequestDetailRow: View {
    let request: ExpenseRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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


            if request.status == .rejected, let comment = request.managerComment {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.rejectedColor)
                        .font(.system(size: 13))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Rejection reason — \(request.reason)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.rejectedColor)
                        Text(comment)
                            .font(.system(size: 12))
                            .foregroundColor(.rejectedColor.opacity(0.8))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}
