//
//  RequestDetailView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct RequestDetailView: View {
    let request: ExpenseRequest
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
    
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryBlue)
                    }
                    Text("Request Details")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity)
                    StatusBadge(status: request.status)
                }
                .padding(.horizontal, AppDesign.screenPadding)
                .padding(.top, 16)

                                VStack(spacing: 8) {
                    Text("TOTAL AMOUNT")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .tracking(0.8)
                    Text(request.formattedAmount)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .cardStyle()
                .padding(.horizontal, AppDesign.screenPadding)

            
                HStack(spacing: 14) {
                    DetailInfoCard(title: "CATEGORY", value: request.category.rawValue,
                                   icon: request.category.icon, color: request.category.color)
                    DetailInfoCard(title: "SUBMITTED", value: request.formattedDate,
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


                VStack(alignment: .leading, spacing: 10) {
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
                            .frame(height: 180)
                        VStack(spacing: 10) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.textSecondary.opacity(0.3))
                            Text("Receipt attached")
                                .font(.system(size: 13))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(AppDesign.cardPadding)
                .cardStyle()
                .padding(.horizontal, AppDesign.screenPadding)

                if request.status == .rejected, let comment = request.managerComment {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.rejectedColor)
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Manager Comment")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.rejectedColor)
                            Text(comment)
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding(AppDesign.cardPadding)
                    .background(Color.rejectedColor.opacity(0.08))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rejectedColor.opacity(0.2), lineWidth: 1))
                    .padding(.horizontal, AppDesign.screenPadding)
                }

                Spacer().frame(height: 20)
            }
        }
        .background(Color.bgPrimary.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct DetailInfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.textSecondary)
                .tracking(0.8)
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cardStyle()
    }
}

