//  BudgetControlView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//


import SwiftUI


struct CustomBudgetCategory: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var color: Color
    var budgetLimit: Double
    var spent: Double = 0

    var utilization: Double {
        guard budgetLimit > 0 else { return 0 }
        return min(spent / budgetLimit, 1.0)
    }
    var formattedSpent: String {
        "LKR \(Int(spent).formattedWithSeparator)"
    }
}


private let availableIcons: [String] = [
    "cart.fill", "car.fill", "fork.knife", "cross.case.fill",
    "graduationcap.fill", "house.fill", "airplane", "gift.fill",
    "tshirt.fill", "bolt.fill", "phone.fill", "wrench.fill",
    "heart.fill", "star.fill", "bag.fill", "doc.fill"
]
private let availableColors: [Color] = [
    Color(hex: "#5856D6"), Color(hex: "#FF6B6B"), Color(hex: "#4ECDC4"),
    Color(hex: "#45B7D1"), Color(hex: "#96CEB4"), Color(hex: "#FFEAA7"),
    Color(hex: "#DDA0DD"), Color(hex: "#98D8C8"), Color(hex: "#F7DC6F"),
    Color(hex: "#BB8FCE"), Color(hex: "#85C1E9"), Color(hex: "#F8C471")
]


struct BudgetControlView: View {
    @EnvironmentObject var managerVM: ManagerViewModel
    @State private var showEditLimit = false
    @State private var showAddCategory = false
    @State private var newLimitText = ""
    @State private var animateBars = false
    @State private var customCategories: [CustomBudgetCategory] = []

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
                                        .frame(
                                            width: animateBars
                                                ? geo.size.width * CGFloat(managerVM.budgetUtilization)
                                                : 0,
                                            height: 12
                                        )
                                        .animation(
                                            .spring(response: 0.8, dampingFraction: 0.85).delay(0.2),
                                            value: animateBars
                                        )
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

                    // MARK: Categories Section
                    VStack(spacing: 14) {
                        HStack {
                            Text("By Category")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Text("\(managerVM.budgetCategories.count + customCategories.count) categories")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, AppDesign.screenPadding)

                        // Default categories
                        ForEach(managerVM.budgetCategories) { budgetCat in
                            CategoryBudgetRow(budgetCategory: budgetCat, animate: animateBars)
                                .padding(.horizontal, AppDesign.screenPadding)
                        }

                        // Custom categories
                        ForEach(customCategories) { customCat in
                            CustomCategoryBudgetRow(category: customCat, animate: animateBars)
                                .padding(.horizontal, AppDesign.screenPadding)
                        }

                        // Add Category Button (dashed)
                        Button { showAddCategory = true } label: {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(managerAccent.opacity(0.1))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(managerAccent)
                                }
                                Text("Add New Category")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(managerAccent)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                managerAccent.opacity(0.3),
                                                style: StrokeStyle(lineWidth: 1.5, dash: [6])
                                            )
                                    )
                            )
                        }
                        .padding(.horizontal, AppDesign.screenPadding)
                    }

                    // MARK: Edit Limit Button
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
                            LinearGradient(
                                colors: [managerAccent, managerAccent.opacity(0.8)],
                                startPoint: .leading, endPoint: .trailing
                            )
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
            .sheet(isPresented: $showAddCategory) {
                AddCategorySheet { newCategory in
                    withAnimation(.spring(response: 0.5)) {
                        customCategories.append(newCategory)
                    }
                }
            }
        }
        .onAppear {
            withAnimation { animateBars = true }
        }
    }
}

// MARK: - Category Budget Row (Default)
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
                        .frame(
                            width: animate ? geo.size.width * CGFloat(budgetCategory.utilization) : 0,
                            height: 8
                        )
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.85).delay(0.3),
                            value: animate
                        )
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

// MARK: - Custom Category Budget Row
struct CustomCategoryBudgetRow: View {
    let category: CustomBudgetCategory
    let animate: Bool

    var barColor: Color {
        if category.utilization >= 0.9 { return .rejectedColor }
        if category.utilization >= 0.7 { return .accentOrange }
        return category.color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(category.color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: category.icon)
                        .font(.system(size: 14))
                        .foregroundColor(category.color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.textPrimary)
                    Text("Limit: LKR \(Int(category.budgetLimit).formattedWithSeparator)")
                        .font(.system(size: 11))
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                Text(category.formattedSpent)
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
                        .frame(
                            width: animate ? geo.size.width * CGFloat(category.utilization) : 0,
                            height: 8
                        )
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.85).delay(0.3),
                            value: animate
                        )
                }
            }
            .frame(height: 8)

            Text("\(Int(category.utilization * 100))% USED")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(barColor)
                .tracking(0.5)
        }
        .padding(16)
        .cardStyle()
    }
}

// MARK: - Edit Limit Sheet
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
                InputField(
                    placeholder: "Enter amount",
                    text: $limitText,
                    keyboardType: .numberPad
                )
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.borderColor, lineWidth: 1)
                        )
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

// MARK: - Add Category Sheet
struct AddCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (CustomBudgetCategory) -> Void

    @State private var categoryName: String = ""
    @State private var budgetLimitText: String = ""
    @State private var selectedIcon: String = availableIcons[0]
    @State private var selectedColor: Color = availableColors[0]
    @State private var showValidationError = false

    let managerAccent = Color(hex: "#5856D6")

    var isFormValid: Bool {
        !categoryName.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Double(budgetLimitText) ?? 0) > 0
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {

                // Handle bar
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.borderColor)
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)

                // Header preview
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedColor.opacity(0.15))
                            .frame(width: 64, height: 64)
                        Image(systemName: selectedIcon)
                            .font(.system(size: 28))
                            .foregroundColor(selectedColor)
                    }
                    Text("New Category")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Text("Customize and set a budget limit")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                }

                // Category Name
                VStack(alignment: .leading, spacing: 10) {
                    Text("CATEGORY NAME")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .tracking(0.8)
                    InputField(placeholder: "e.g. Transport, Medical...", text: $categoryName)
                    if showValidationError && categoryName.trimmingCharacters(in: .whitespaces).isEmpty {
                        Label("Category name is required", systemImage: "exclamationmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.rejectedColor)
                    }
                }
                .padding(.horizontal, AppDesign.screenPadding)

                // Budget Limit
                VStack(alignment: .leading, spacing: 10) {
                    Text("BUDGET LIMIT (LKR)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .tracking(0.8)
                    InputField(
                        placeholder: "Enter budget amount",
                        text: $budgetLimitText,
                        keyboardType: .numberPad
                    )
                    if showValidationError && (Double(budgetLimitText) ?? 0) <= 0 {
                        Label("Enter a valid budget amount", systemImage: "exclamationmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.rejectedColor)
                    }
                }
                .padding(.horizontal, AppDesign.screenPadding)

                // Icon Picker
                VStack(alignment: .leading, spacing: 14) {
                    Text("CHOOSE ICON")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .tracking(0.8)
                        .padding(.horizontal, AppDesign.screenPadding)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                withAnimation(.spring(response: 0.3)) { selectedIcon = icon }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedIcon == icon ? selectedColor.opacity(0.15) : Color.bgPrimary)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(
                                                    selectedIcon == icon ? selectedColor : Color.borderColor,
                                                    lineWidth: selectedIcon == icon ? 2 : 1
                                                )
                                        )
                                    Image(systemName: icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(selectedIcon == icon ? selectedColor : .textSecondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                }

                // Color Picker
                VStack(alignment: .leading, spacing: 14) {
                    Text("CHOOSE COLOR")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .tracking(0.8)
                        .padding(.horizontal, AppDesign.screenPadding)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(availableColors, id: \.self) { color in
                            Button {
                                withAnimation(.spring(response: 0.3)) { selectedColor = color }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 40, height: 40)
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                        .padding(2)
                                        .overlay(
                                            Circle()
                                                .stroke(color.opacity(0.5), lineWidth: selectedColor == color ? 1.5 : 0)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                }

                // Buttons
                HStack(spacing: 14) {
                    Button { dismiss() } label: {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.bgPrimary)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.borderColor, lineWidth: 1)
                            )
                    }

                    Button {
                        if isFormValid {
                            onAdd(CustomBudgetCategory(
                                name: categoryName.trimmingCharacters(in: .whitespaces),
                                icon: selectedIcon,
                                color: selectedColor,
                                budgetLimit: Double(budgetLimitText) ?? 0
                            ))
                            dismiss()
                        } else {
                            withAnimation { showValidationError = true }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                            Text("Add Category")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [managerAccent, managerAccent.opacity(0.8)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: managerAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, AppDesign.screenPadding)
                .padding(.bottom, 34)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}
