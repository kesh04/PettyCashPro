//
//  BudgetControlView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI

struct BudgetControlView: View {
    @EnvironmentObject var managerVM: ManagerViewModel
    @State private var showEditLimit = false
    @State private var newLimitText = ""
    @State private var animateBars = false

    let managerAccent = Color(hex: "#5856D6")

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {

              
                    Text("Budget Control")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppDesign.screenPadding)
                        .padding(.top, 20)

           
                    Text("March Budget Control")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppDesign.screenPadding)

     
                    VStack(spacing: 18) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("MONTHLY LIMIT")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                    .tracking(0.6)
                                Text("LKR \(Int(managerVM.monthlyLimit).formattedWithSeparator)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.textPrimary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("SPENT SO FAR")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.textSecondary)
                                    .tracking(0.6)
                                Text("LKR \(Int(managerVM.totalSpent).formattedWithSeparator)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(managerVM.isApproachingLimit ? .accentOrange : .primaryBlue)
                            }
                        }

            
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Budget Utilization")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.textSecondary)
                                Spacer()
                                Text("\(Int(managerVM.budgetUtilization * 100))%")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(managerVM.isApproachingLimit ? .accentOrange : .primaryBlue)
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.bgPrimary)
                                        .frame(height: 12)
                                    Capsule()
                                        .fill(managerVM.isApproachingLimit ?
                                              Color.rejectedColor : Color.primaryBlue)
                                        .frame(width: animateBars ? geo.size.width * CGFloat(managerVM.budgetUtilization) : 0, height: 12)
                                        .animation(.spring(response: 0.8, dampingFraction: 0.85).delay(0.2), value: animateBars)
                                }
                            }
                            .frame(height: 12)

                            if managerVM.isApproachingLimit {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.accentOrange)
                                    Text("Approaching limit")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.accentOrange)
                                }
                            }
                        }
                    }
                    .padding(AppDesign.cardPadding)
                    .cardStyle()
                    .padding(.horizontal, AppDesign.screenPadding)

   
                    VStack(spacing: 14) {
                        Text("By Category")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppDesign.screenPadding)

                        ForEach(managerVM.budgetCategories) { budgetCat in
                            CategoryBudgetRow(budgetCategory: budgetCat, animate: animateBars)
                                .padding(.horizontal, AppDesign.screenPadding)
                        }
                    }

           
                    Button {
                        newLimitText = "\(Int(managerVM.monthlyLimit))"
                        showEditLimit = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16))
                            Text("Edit Monthly Limit")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(colors: [managerAccent, managerAccent.opacity(0.8)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(14)
                        .shadow(color: managerAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.bottom, 30)
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditLimit) {
                EditLimitSheet(limitText: $newLimitText) { newLimit in
                    managerVM.updateMonthlyLimit(newLimit)
                    showEditLimit = false
                }
            }
        }
        .onAppear {
            withAnimation { animateBars = true }
        }
    }
}


struct CategoryBudgetRow: View {
    let budgetCategory: BudgetCategory
    let animate: Bool

    var barColor: Color {
        if budgetCategory.utilization >= 0.9 { return .rejectedColor }
        if budgetCategory.utilization >= 0.7 { return .accentOrange }
        return .primaryBlue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(budgetCategory.category.color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: budgetCategory.category.icon)
                        .font(.system(size: 14))
                        .foregroundColor(budgetCategory.category.color)
                }

                Text(budgetCategory.category.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textPrimary)

                Spacer()

                Text(budgetCategory.formattedSpent)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.textPrimary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.bgPrimary)
                        .frame(height: 8)
                    Capsule()
                        .fill(barColor)
                        .frame(width: animate ? geo.size.width * CGFloat(budgetCategory.utilization) : 0, height: 8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.85).delay(0.3), value: animate)
                }
            }
            .frame(height: 8)

            Text("\(Int(budgetCategory.utilization * 100))% USED")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(barColor)
                .tracking(0.5)
        }
        .padding(16)
        .cardStyle()
    }
}


struct EditLimitSheet: View {
    @Binding var limitText: String
    let onSave: (Double) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.borderColor)
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            VStack(spacing: 8) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "#5856D6"))
                Text("Edit Monthly Limit")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textPrimary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("NEW MONTHLY LIMIT (LKR)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .tracking(0.8)
                InputField(placeholder: "Enter amount",
                           text: $limitText,
                           keyboardType: .numberPad)
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
                    if let value = Double(limitText) {
                        onSave(value)
                    }
                } label: {
                    Text("Save")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "#5856D6"))
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, AppDesign.screenPadding)
            .padding(.bottom, 30)
        }
        .background(Color.white)
    }
}
