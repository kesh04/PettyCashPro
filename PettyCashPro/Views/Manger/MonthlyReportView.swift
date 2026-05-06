//
//  MonthlyReportView.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-25.
//

import SwiftUI
import PDFKit

struct MonthlyReportView: View {
    @EnvironmentObject var managerVM: ManagerViewModel
    @State private var animateCharts = false
    @State private var isDownloadingPDF = false
    @State private var showShareSheet = false
    @State private var pdfURL: URL? = nil
    @State private var downloadError: String? = nil
    @State private var showErrorAlert = false

    let managerAccent = Color(hex: "#5856D6")

    var totalBudget: Double { managerVM.monthlyLimit }
    var totalSpent: Double { managerVM.totalSpent }
    var approvedRequests: [APIExpenseRequest] { managerVM.requests.filter { $0.status == "Approved" } }
    var rejectedRequests: [APIExpenseRequest] { managerVM.requests.filter { $0.status == "Rejected" } }
    var remainingBudget: Double { max(totalBudget - totalSpent, 0) }
    var savingsRate: Double { totalBudget > 0 ? (remainingBudget / totalBudget) * 100 : 0 }

    var categoryBreakdown: [(ExpenseCategory, Double)] {
        var totals: [ExpenseCategory: Double] = [:]
        for req in approvedRequests {
            if let cat = ExpenseCategory(rawValue: req.category) {
                totals[cat, default: 0] += req.amount
            }
        }
        return totals.sorted { $0.value > $1.value }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {

        
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Monthly Report")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.textPrimary)
                            Text(currentMonthYear())
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()

                        Button {
                            downloadPDF()
                        } label: {
                            HStack(spacing: 6) {
                                if isDownloadingPDF {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.down.doc.fill")
                                        .font(.system(size: 14))
                                    Text("Export PDF")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(isDownloadingPDF ? managerAccent.opacity(0.6) : managerAccent)
                            .cornerRadius(10)
                        }
                        .disabled(isDownloadingPDF)
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .padding(.top, 20)

        
                    HStack(spacing: 12) {
                        ReportSummaryCard(title: "TOTAL BUDGET",  value: "LKR \(Int(totalBudget / 1000))K",    icon: "banknote.fill",   color: managerAccent)
                        ReportSummaryCard(title: "TOTAL SPENT",   value: "LKR \(Int(totalSpent / 1000))K",     icon: "chart.bar.fill",  color: .accentOrange)
                        ReportSummaryCard(title: "REMAINING",     value: "LKR \(Int(remainingBudget / 1000))K", icon: "wallet.pass.fill", color: .approvedColor)
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .opacity(animateCharts ? 1 : 0)
                    .offset(y: animateCharts ? 0 : 20)

                    HStack(spacing: 12) {
                        RequestCountCard(count: approvedRequests.count,       label: "Approved", color: .approvedColor, icon: "checkmark.circle.fill")
                        RequestCountCard(count: rejectedRequests.count,       label: "Rejected", color: .rejectedColor, icon: "xmark.circle.fill")
                        RequestCountCard(count: managerVM.pendingRequests.count, label: "Pending", color: .pendingColor,   icon: "clock.fill")
                    }
                    .padding(.horizontal, AppDesign.screenPadding)
                    .opacity(animateCharts ? 1 : 0)
                    .offset(y: animateCharts ? 0 : 24)

            
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Budget Overview")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.textPrimary)

                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Utilisation")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.textSecondary)
                                    Spacer()
                                    Text("\(Int(managerVM.budgetUtilization * 100))%")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(managerVM.isApproachingLimit ? .accentOrange : managerAccent)
                                }
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color.bgPrimary).frame(height: 16)
                                        Capsule()
                                            .fill(LinearGradient(
                                                colors: managerVM.isApproachingLimit
                                                    ? [.accentOrange, .rejectedColor]
                                                    : [managerAccent, Color.primaryBlue],
                                                startPoint: .leading, endPoint: .trailing))
                                            .frame(width: animateCharts ? geo.size.width * CGFloat(managerVM.budgetUtilization) : 0, height: 16)
                                            .animation(.spring(response: 1.0, dampingFraction: 0.85).delay(0.3), value: animateCharts)
                                    }
                                }
                                .frame(height: 16)
                            }

                            Divider()

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Savings Rate").font(.system(size: 12)).foregroundColor(.textSecondary)
                                    Text("\(Int(savingsRate))%").font(.system(size: 20, weight: .bold)).foregroundColor(.approvedColor)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("Over Budget").font(.system(size: 12)).foregroundColor(.textSecondary)
                                    Text(managerVM.budgetUtilization > 1.0 ? "YES" : "NO")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(managerVM.budgetUtilization > 1.0 ? .rejectedColor : .approvedColor)
                                }
                            }
                        }
                    }
                    .padding(AppDesign.cardPadding)
                    .cardStyle()
                    .padding(.horizontal, AppDesign.screenPadding)
                    .opacity(animateCharts ? 1 : 0)
                    .offset(y: animateCharts ? 0 : 28)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Spending by Category")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, AppDesign.screenPadding)

                        if categoryBreakdown.isEmpty {
                            Text("No approved expenses this month.")
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal, AppDesign.screenPadding)
                        } else {
                            let maxAmount = categoryBreakdown.first?.1 ?? 1
                            VStack(spacing: 12) {
                                ForEach(categoryBreakdown, id: \.0) { category, amount in
                                    CategoryReportRow(category: category, amount: amount, maxAmount: maxAmount, animate: animateCharts)
                                        .padding(.horizontal, AppDesign.screenPadding)
                                }
                            }
                        }
                    }
                    .opacity(animateCharts ? 1 : 0)
                    .offset(y: animateCharts ? 0 : 32)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Top Expenses")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.textPrimary)

                        let topExpenses = approvedRequests.sorted { $0.amount > $1.amount }.prefix(3)
                        if topExpenses.isEmpty {
                            Text("No approved expenses yet.")
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                        } else {
                            ForEach(Array(topExpenses.enumerated()), id: \.element.id) { index, req in
                                APITopExpenseRow(rank: index + 1, request: req)
                            }
                        }
                    }
                    .padding(AppDesign.cardPadding)
                    .cardStyle()
                    .padding(.horizontal, AppDesign.screenPadding)
                    .opacity(animateCharts ? 1 : 0)

                    Spacer().frame(height: 30)
                }
            }
            .background(Color.bgPrimary.ignoresSafeArea())
            .navigationBarHidden(true)
            .task {
                await managerVM.loadAllRequests()
                await managerVM.loadBudget()
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .alert("Download Failed", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(downloadError ?? "Could not download the report. Check your connection.")
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.1)) {
                animateCharts = true
            }
        }
    }



    private func downloadPDF() {
        isDownloadingPDF = true
        downloadError    = nil


        var totals: [String: Double] = [:]
        for req in approvedRequests {
            totals[req.category, default: 0] += req.amount
        }
        let breakdown = totals
            .map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }


        let pdfData = PDFReportGenerator.generateReport(
            monthYear:         currentMonthYear(),
            monthlyLimit:      managerVM.monthlyLimit,
            totalSpent:        managerVM.totalSpent,
            approvedCount:     approvedRequests.count,
            rejectedCount:     rejectedRequests.count,
            pendingCount:      managerVM.pendingRequests.count,
            categoryBreakdown: breakdown
        )

        
        let fileName = "PettyCash_Report_\(currentMonthYear().replacingOccurrences(of: " ", with: "_")).pdf"
        let tempURL  = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try pdfData.write(to: tempURL)
            pdfURL            = tempURL
            isDownloadingPDF  = false
            showShareSheet    = true
        } catch {
            isDownloadingPDF  = false
            downloadError     = "Could not save PDF: \(error.localizedDescription)"
            showErrorAlert    = true
        }
    }

    private func currentMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
}



struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}



struct ReportSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
            Text(value).font(.system(size: 16, weight: .bold)).foregroundColor(.textPrimary)
            Text(title).font(.system(size: 9, weight: .semibold)).foregroundColor(.textSecondary).tracking(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.08))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.15), lineWidth: 1))
    }
}

struct RequestCountCard: View {
    let count: Int
    let label: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
            Text("\(count)").font(.system(size: 24, weight: .bold)).foregroundColor(color)
            Text(label).font(.system(size: 11)).foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

struct CategoryReportRow: View {
    let category: ExpenseCategory
    let amount: Double
    let maxAmount: Double
    let animate: Bool

    var ratio: Double { maxAmount > 0 ? amount / maxAmount : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(category.color.opacity(0.15)).frame(width: 32, height: 32)
                    Image(systemName: category.icon).font(.system(size: 13)).foregroundColor(category.color)
                }
                Text(category.rawValue).font(.system(size: 14, weight: .medium)).foregroundColor(.textPrimary)
                Spacer()
                Text("LKR \(Int(amount).formattedWithSeparator)").font(.system(size: 14, weight: .bold)).foregroundColor(.textPrimary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.bgPrimary).frame(height: 8)
                    Capsule()
                        .fill(category.color)
                        .frame(width: animate ? geo.size.width * CGFloat(ratio) : 0, height: 8)
                        .animation(.spring(response: 0.9, dampingFraction: 0.85).delay(0.4), value: animate)
                }
            }
            .frame(height: 8)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

struct APITopExpenseRow: View {
    let rank: Int
    let request: APIExpenseRequest

    var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "#FFD700")
        case 2: return Color(hex: "#C0C0C0")
        default: return Color(hex: "#CD7F32")
        }
    }

    var categoryEnum: ExpenseCategory { ExpenseCategory(rawValue: request.category) ?? .other }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(rankColor.opacity(0.2)).frame(width: 32, height: 32)
                Text("#\(rank)").font(.system(size: 12, weight: .bold)).foregroundColor(rankColor)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(categoryEnum.color.opacity(0.15)).frame(width: 36, height: 36)
                Image(systemName: categoryEnum.icon).font(.system(size: 14)).foregroundColor(categoryEnum.color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(request.reason).font(.system(size: 13, weight: .medium)).foregroundColor(.textPrimary).lineLimit(1)
                Text(request.staffName).font(.system(size: 11)).foregroundColor(.textSecondary)
            }
            Spacer()
            Text(request.formattedAmount).font(.system(size: 14, weight: .bold)).foregroundColor(.textPrimary)
        }
        .padding(.vertical, 8)

        if rank < 3 { Divider() }
    }
}
