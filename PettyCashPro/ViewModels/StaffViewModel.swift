//
//  StaffViewModel.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-24.
//

import SwiftUI
import Combine

class StaffViewModel: ObservableObject {
    @Published var myRequests: [ExpenseRequest] = SampleData.myRequests
    @Published var selectedCategory: ExpenseCategory = .food
    @Published var amount: String = ""
    @Published var reason: String = ""
    @Published var isSubmitting: Bool = false
    @Published var showSubmitSuccess: Bool = false
    @Published var filterStatus: RequestStatus? = nil

    var pendingCount: Int { myRequests.filter { $0.status == .pending }.count }
    var approvedThisMonth: Double { myRequests.filter { $0.status == .approved }.reduce(0) { $0 + $1.amount } }
    var pendingAmount: Double { myRequests.filter { $0.status == .pending }.reduce(0) { $0 + $1.amount } }
    var approvedCount: Int { myRequests.filter { $0.status == .approved }.count }
    var rejectedCount: Int { myRequests.filter { $0.status == .rejected }.count }

    var filteredRequests: [ExpenseRequest] {
        guard let filter = filterStatus else { return myRequests }
        return myRequests.filter { $0.status == filter }
    }

    func submitRequest() {
        guard let amountValue = Double(amount), !reason.isEmpty else { return }
        isSubmitting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let newRequest = ExpenseRequest(
                staffName: SampleData.staffUser.name,
                staffDepartment: SampleData.staffUser.department,
                staffInitials: SampleData.staffUser.initials,
                amount: amountValue,
                category: self.selectedCategory,
                reason: self.reason,
                status: .pending,
                submittedDate: Date()
            )
            self.myRequests.insert(newRequest, at: 0)
            self.isSubmitting = false
            self.showSubmitSuccess = true
            self.amount = ""
            self.reason = ""
            self.selectedCategory = .food
        }
    }
}
