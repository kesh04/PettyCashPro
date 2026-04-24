//
//  ManagerViewModel.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-24.
//

import SwiftUI
import Combine

class ManagerViewModel: ObservableObject {

    @Published var requests: [ExpenseRequest] = SampleData.requests
    @Published var budgetCategories: [BudgetCategory] = SampleData.budgetCategories
    @Published var monthlyLimit: Double = 450000
    @Published var rejectComment: String = ""
    @Published var selectedFilter: ApprovalFilter = .allPending

    enum ApprovalFilter: String, CaseIterable {
        case allPending = "All Pending"
        case urgent = "Urgent"
        case highAmount = "High Amount"
    }

    var totalSpent: Double {
        budgetCategories.reduce(0) { $0 + $1.spent }
    }

    var totalApproved: Double {
        requests
            .filter { $0.status == .approved }
            .reduce(0) { $0 + $1.amount }
    }

    var pendingRequests: [ExpenseRequest] {
        requests.filter { $0.status == .pending }
    }

    var budgetUtilization: Double {
        min(totalSpent / monthlyLimit, 1.0)
    }

    var isApproachingLimit: Bool {
        budgetUtilization >= 0.80
    }

    var filteredPendingRequests: [ExpenseRequest] {
        switch selectedFilter {
        case .allPending:
            return pendingRequests
        case .urgent:
            return pendingRequests.filter { $0.isUrgent }
        case .highAmount:
            return pendingRequests
                .filter { $0.amount >= 5000 }
                .sorted { $0.amount > $1.amount }
        }
    }

    func approve(request: ExpenseRequest) {
        withAnimation {
            if let idx = requests.firstIndex(where: { $0.id == request.id }) {
                requests[idx].status = .approved
            }
        }
    }

    func reject(request: ExpenseRequest, comment: String) {
        withAnimation {
            if let idx = requests.firstIndex(where: { $0.id == request.id }) {
                requests[idx].status = .rejected
                requests[idx].managerComment =
                    comment.isEmpty ? "Request rejected." : comment
            }
        }
    }

    func updateMonthlyLimit(_ newLimit: Double) {
        withAnimation {
            monthlyLimit = newLimit
        }
    }
}
