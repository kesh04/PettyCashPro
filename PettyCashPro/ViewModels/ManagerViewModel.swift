//
//  ManagerViewModel.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-24.
//


import SwiftUI
import Combine

class ManagerViewModel: ObservableObject {

    @Published var requests: [APIExpenseRequest] = []
    @Published var managerSummary: ManagerSummary? = nil
    @Published var budget: APIBudget? = nil
    @Published var monthlyLimit: Double = 450000
    @Published var selectedFilter: ApprovalFilter = .allPending
    @Published var isLoading: Bool = false
    @Published var isActionLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let network = NetworkService.shared
    private var budgetWarningFired = false

    enum ApprovalFilter: String, CaseIterable {
        case allPending = "All Pending"
        case urgent = "Urgent"
        case highAmount = "High Amount"
    }


    var totalSpent: Double {
        budget?.categories.reduce(0) { $0 + $1.spent } ?? 0
    }

    var budgetCategories: [APIBudgetCategory] {
        budget?.categories ?? []
    }

    var totalApproved: Double { managerSummary?.totalApproved ?? 0 }

    var pendingRequests: [APIExpenseRequest] {
        requests.filter { $0.status == "Pending" }
    }

    var budgetUtilization: Double {
        min(totalSpent / monthlyLimit, 1.0)
    }

    var isApproachingLimit: Bool { budgetUtilization >= 0.80 }

    var filteredPendingRequests: [APIExpenseRequest] {
        switch selectedFilter {
        case .allPending:
            return pendingRequests
        case .urgent:
            return pendingRequests.filter { $0.isUrgent }
        case .highAmount:
            return pendingRequests.filter { $0.amount >= 5000 }.sorted { $0.amount > $1.amount }
        }
    }

    @MainActor
    func loadAllRequests() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await network.getAllRequests()
            requests = response.requests
            managerSummary = response.summary
        } catch {
            errorMessage = "Failed to load requests."
        }
        isLoading = false
    }


    @MainActor
    func loadBudget() async {
        do {
            let b = try await network.getBudget()
            budget = b
            monthlyLimit = b.monthlyLimit
            checkBudgetAlert()
        } catch {
            print("Budget load error: \(error)")
        }
    }

    func approve(request: APIExpenseRequest) {
        isActionLoading = true
        Task {
            do {
                let updated = try await network.approveRequest(id: request.id, comment: "")
                await MainActor.run {
                    if let idx = self.requests.firstIndex(where: { $0.id == request.id }) {
                        self.requests[idx] = updated
                    }
                    self.isActionLoading = false

                    NotificationService.shared.notifyStaffApproved(
                        amount: request.amount,
                        category: request.category
                    )

                    Task { await self.loadBudget() }
                }
            } catch {
                await MainActor.run {
                    self.isActionLoading = false
                    self.errorMessage = "Failed to approve request."
                }
            }
        }
    }

    func reject(request: APIExpenseRequest, comment: String) {
        isActionLoading = true
        Task {
            do {
                let updated = try await network.rejectRequest(id: request.id, comment: comment)
                await MainActor.run {
                    if let idx = self.requests.firstIndex(where: { $0.id == request.id }) {
                        self.requests[idx] = updated
                    }
                    self.isActionLoading = false

                    NotificationService.shared.notifyStaffRejected(
                        amount: request.amount,
                        category: request.category,
                        comment: comment
                    )
                }
            } catch {
                await MainActor.run {
                    self.isActionLoading = false
                    self.errorMessage = "Failed to reject request."
                }
            }
        }
    }

    func updateMonthlyLimit(_ newLimit: Double) {
        Task {
            do {
                let updated = try await network.updateMonthlyLimit(newLimit)
                await MainActor.run {
                    self.budget = updated
                    self.monthlyLimit = newLimit
                    self.budgetWarningFired = false
                    self.checkBudgetAlert()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to update budget limit."
                }
            }
        }
    }

    private func checkBudgetAlert() {
        guard !budgetWarningFired else { return }
        if budgetUtilization >= 1.0 {
            NotificationService.shared.notifyManagerBudgetExceeded(spent: totalSpent, limit: monthlyLimit)
            budgetWarningFired = true
        } else if budgetUtilization >= 0.80 {
            NotificationService.shared.notifyManagerBudgetWarning(spent: totalSpent, limit: monthlyLimit)
            budgetWarningFired = true
        }
    }
}
