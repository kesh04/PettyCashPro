//
//  StaffViewModel.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-24.
//


import SwiftUI
import Combine
import AppIntents

class StaffViewModel: ObservableObject {
    @Published var myRequests: [APIExpenseRequest] = []
    @Published var summary: StaffSummary? = nil
    @Published var selectedCategory: ExpenseCategory = .food
    @Published var amount: String = ""
    @Published var reason: String = ""
    @Published var isUrgent: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var isLoading: Bool = false
    @Published var showSubmitSuccess: Bool = false
    @Published var filterStatus: String? = nil
    @Published var errorMessage: String? = nil

    private let network = NetworkService.shared

    var pendingCount: Int { summary?.pendingCount ?? myRequests.filter { $0.status == "Pending" }.count }
    var approvedCount: Int { summary?.approvedCount ?? myRequests.filter { $0.status == "Approved" }.count }
    var rejectedCount: Int { summary?.rejectedCount ?? myRequests.filter { $0.status == "Rejected" }.count }
    var pendingAmount: Double { summary?.pendingAmount ?? 0 }
    var approvedThisMonth: Double { summary?.approvedThisMonth ?? 0 }

    var filteredRequests: [APIExpenseRequest] {
        guard let filter = filterStatus else { return myRequests }
        return myRequests.filter { $0.status == filter }
    }


    @MainActor
    func loadMyRequests() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await network.getMyRequests()
            myRequests = response.requests
            summary = response.summary
        } catch {
            errorMessage = "Failed to load requests. Check your connection."
        }
        isLoading = false
    }

  
    func submitRequestWithImage(imageData: Data?) {
        guard let amountValue = Double(amount), !reason.isEmpty else {
            errorMessage = "Please enter amount and reason."
            return
        }

        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                let newRequest = try await network.submitRequest(
                    amount: amountValue,
                    category: selectedCategory.rawValue,
                    reason: reason,
                    isUrgent: isUrgent,
                    imageData: imageData
                )

      
                NotificationService.shared.notifyManagerNewRequest(
                    staffName: newRequest.staffName,
                    amount: newRequest.amount,
                    category: newRequest.category
                )

                await MainActor.run {
                    self.myRequests.insert(newRequest, at: 0)
                    self.isSubmitting = false
                    self.showSubmitSuccess = true
                    self.amount = ""
                    self.reason = ""
                    self.isUrgent = false
                    self.selectedCategory = .food
                    if let s = self.summary {
                        self.summary = StaffSummary(
                            totalRequests: s.totalRequests + 1,
                            pendingCount: s.pendingCount + 1,
                            approvedCount: s.approvedCount,
                            rejectedCount: s.rejectedCount,
                            pendingAmount: s.pendingAmount + amountValue,
                            approvedThisMonth: s.approvedThisMonth
                        )
                    }
             
                    Task { await self.donateSiriShortcut(amount: amountValue, category: self.selectedCategory.rawValue) }
                }
            } catch {
                await MainActor.run {
                    self.isSubmitting = false
                    self.errorMessage = "Failed to submit request: \(error.localizedDescription)"
                }
            }
        }
    }


    func submitRequest() {
        submitRequestWithImage(imageData: nil)
    }

   
    @MainActor
    private func donateSiriShortcut(amount: Double, category: String) async {
        var intent        = SubmitExpenseIntent()
        intent.amount     = amount
        intent.category   = category
        intent.reason     = "Expense via PettyCash Pro"
        _ = try? await intent.donate()
    }
}
