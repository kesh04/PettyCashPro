//
//  PettyCashProTests.swift
//  PettyCashProTests
//
//  Created by Keshana Liyanaarachchi on 2026-05-08.
//

import XCTest
@testable import PettyCashPro

final class ModelsTests: XCTestCase {

    func test_budgetCategory_utilization_normal() {

        let category = BudgetCategory(
            category: .food,
            allocated: 100_000,
            spent: 50_000
        )

        XCTAssertEqual(category.utilization, 0.5, accuracy: 0.001)
    }

    func test_budgetCategory_utilization_capped_at_1_when_over_budget() {
 
        let category = BudgetCategory(
            category: .transport,
            allocated: 50_000,
            spent: 100_000
        )
        XCTAssertEqual(category.utilization, 1.0, accuracy: 0.001)
    }

    func test_budgetCategory_isOverBudget_true() {
        let category = BudgetCategory(category: .food, allocated: 10_000, spent: 15_000)
        XCTAssertTrue(category.isOverBudget)
    }

    func test_budgetCategory_isOverBudget_false() {
        let category = BudgetCategory(category: .food, allocated: 10_000, spent: 5_000)
        XCTAssertFalse(category.isOverBudget)
    }

    func test_budgetCategory_formattedSpent_contains_LKR() {
        let category = BudgetCategory(category: .food, allocated: 200_000, spent: 140_000)
        XCTAssertTrue(category.formattedSpent.contains("LKR"))
    }

    func test_budgetCategory_formattedAllocated_contains_LKR() {
        let category = BudgetCategory(category: .food, allocated: 200_000, spent: 140_000)
        XCTAssertTrue(category.formattedAllocated.contains("LKR"))
    }



    func test_expenseRequest_formattedAmount_contains_LKR() {
        let request = makeExpenseRequest(amount: 5_000)
        XCTAssertTrue(request.formattedAmount.contains("LKR"))
    }

    func test_expenseRequest_formattedDate_not_empty() {
        let request = makeExpenseRequest(amount: 1_000)
        XCTAssertFalse(request.formattedDate.isEmpty)
    }


    func test_requestStatus_displayText_matches_rawValue() {
        XCTAssertEqual(RequestStatus.pending.displayText,  "Pending")
        XCTAssertEqual(RequestStatus.approved.displayText, "Approved")
        XCTAssertEqual(RequestStatus.rejected.displayText, "Rejected")
    }

    func test_requestStatus_icon_is_not_empty() {
        for status in RequestStatus.allCases {
            XCTAssertFalse(status.icon.isEmpty, "Icon for \(status) should not be empty")
        }
    }



    func test_expenseCategory_id_equals_rawValue() {
        for cat in ExpenseCategory.allCases {
            XCTAssertEqual(cat.id, cat.rawValue)
        }
    }

    func test_expenseCategory_icon_is_not_empty() {
        for cat in ExpenseCategory.allCases {
            XCTAssertFalse(cat.icon.isEmpty, "Icon for \(cat) should not be empty")
        }
    }


    func test_formattedWithSeparator_1000() {
        XCTAssertEqual(1000.formattedWithSeparator, "1,000")
    }

    func test_formattedWithSeparator_100000() {
        XCTAssertEqual(100_000.formattedWithSeparator, "100,000")
    }

    func test_formattedWithSeparator_smallNumber() {
        XCTAssertEqual(5.formattedWithSeparator, "5")
    }

    func test_appUser_has_unique_id_by_default() {
        let user1 = AppUser(name: "A", email: "a@x.com", department: "IT", role: .staff, initials: "A")
        let user2 = AppUser(name: "B", email: "b@x.com", department: "IT", role: .staff, initials: "B")
        XCTAssertNotEqual(user1.id, user2.id)
    }

    func test_appUser_role_staff() {
        let user = AppUser(name: "A", email: "a@x.com", department: "IT", role: .staff, initials: "A")
        XCTAssertEqual(user.role, .staff)
    }

    func test_appUser_role_manager() {
        let user = AppUser(name: "A", email: "a@x.com", department: "Mgmt", role: .manager, initials: "A")
        XCTAssertEqual(user.role, .manager)
    }


    func test_appUser_encodes_and_decodes() throws {
        let original = AppUser(
            name: "Amal Perera",
            email: "amal@test.com",
            department: "IT",
            role: .staff,
            initials: "AP",
            backendId: "abc123"
        )
        let data    = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppUser.self, from: data)
        XCTAssertEqual(decoded.name,       original.name)
        XCTAssertEqual(decoded.email,      original.email)
        XCTAssertEqual(decoded.department, original.department)
        XCTAssertEqual(decoded.role,       original.role)
        XCTAssertEqual(decoded.initials,   original.initials)
        XCTAssertEqual(decoded.backendId,  original.backendId)
    }

    // MARK: SampleData

    func test_sampleData_staffUser_role_is_staff() {
        XCTAssertEqual(SampleData.staffUser.role, .staff)
    }

    func test_sampleData_managerUser_role_is_manager() {
        XCTAssertEqual(SampleData.managerUser.role, .manager)
    }

    func test_sampleData_budgetCategories_not_empty() {
        XCTAssertFalse(SampleData.budgetCategories.isEmpty)
    }

    func test_sampleData_budgetCategories_all_have_positive_allocated() {
        for cat in SampleData.budgetCategories {
            XCTAssertGreaterThan(cat.allocated, 0, "Allocated must be positive for \(cat.category)")
        }
    }

 
    private func makeExpenseRequest(amount: Double) -> ExpenseRequest {
        ExpenseRequest(
            staffName: "Test User",
            staffDepartment: "IT",
            staffInitials: "TU",
            amount: amount,
            category: .food,
            reason: "Lunch",
            status: .pending,
            submittedDate: Date()
        )
    }
}

@MainActor
final class AuthViewModelTests: XCTestCase {

    var sut: AuthViewModel!

    override func setUp() {
        super.setUp()
       
        UserDefaults.standard.removeObject(forKey: "savedUser")
        sut = AuthViewModel()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "savedUser")
        sut = nil
        super.tearDown()
    }


    func test_initial_isAuthenticated_isFalse() {
        XCTAssertFalse(sut.isAuthenticated)
    }

    func test_initial_currentUser_isNil() {
        XCTAssertNil(sut.currentUser)
    }

    func test_initial_email_isEmpty() {
        XCTAssertTrue(sut.email.isEmpty)
    }

    func test_initial_password_isEmpty() {
        XCTAssertTrue(sut.password.isEmpty)
    }

    func test_initial_errorMessage_isNil() {
        XCTAssertNil(sut.errorMessage)
    }

    func test_login_withEmptyEmail_setsErrorMessage() {
        sut.email    = ""
        sut.password = "secret"
        sut.login()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_login_withEmptyPassword_setsErrorMessage() {
        sut.email    = "user@test.com"
        sut.password = ""
        sut.login()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_login_withBothEmpty_setsErrorMessage() {
        sut.email    = ""
        sut.password = ""
        sut.login()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_logout_clearsAuthentication() {
  
        sut.isAuthenticated = true
        sut.currentUser = AppUser(
            name: "Test", email: "t@t.com", department: "IT",
            role: .staff, initials: "T"
        )
        sut.logout()
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
    }

    func test_logout_clearsEmailAndPassword() {
        sut.email    = "someone@x.com"
        sut.password = "pass"
        sut.logout()
        XCTAssertTrue(sut.email.isEmpty)
        XCTAssertTrue(sut.password.isEmpty)
    }

    func test_logout_clearsErrorMessage() {
        sut.errorMessage = "Some error"
        sut.logout()
        XCTAssertNil(sut.errorMessage)
    }
}


@MainActor
final class StaffViewModelTests: XCTestCase {

    var sut: StaffViewModel!

    override func setUp() {
        super.setUp()
        sut = StaffViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }


    func test_initial_myRequests_isEmpty() {
        XCTAssertTrue(sut.myRequests.isEmpty)
    }

    func test_initial_isSubmitting_isFalse() {
        XCTAssertFalse(sut.isSubmitting)
    }

    func test_initial_isLoading_isFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    func test_initial_showSubmitSuccess_isFalse() {
        XCTAssertFalse(sut.showSubmitSuccess)
    }

    func test_initial_pendingCount_isZero() {
        XCTAssertEqual(sut.pendingCount, 0)
    }

    func test_initial_approvedCount_isZero() {
        XCTAssertEqual(sut.approvedCount, 0)
    }


    func test_submitRequest_withEmptyAmount_setsErrorMessage() {
        sut.amount = ""
        sut.reason = "Lunch"
        sut.submitRequest()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_submitRequest_withEmptyReason_setsErrorMessage() {
        sut.amount = "500"
        sut.reason = ""
        sut.submitRequest()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_submitRequest_withNonNumericAmount_setsErrorMessage() {
        sut.amount = "abc"
        sut.reason = "Lunch"
        sut.submitRequest()
        XCTAssertNotNil(sut.errorMessage)
    }


    func test_filteredRequests_withNoFilter_returnsAll() {
        sut.filterStatus = nil
     
        XCTAssertEqual(sut.filteredRequests.count, sut.myRequests.count)
    }

    func test_filteredRequests_withPendingFilter_returnsOnlyPending() {
        sut.filterStatus = "Pending"
       
        let allMatchFilter = sut.filteredRequests.allSatisfy { $0.status == "Pending" }
        XCTAssertTrue(allMatchFilter)
    }
}


final class EnumTests: XCTestCase {

    func test_userRole_allCases_count() {
        XCTAssertEqual(UserRole.allCases.count, 2)
    }

    func test_userRole_rawValues() {
        XCTAssertEqual(UserRole.staff.rawValue,   "Staff")
        XCTAssertEqual(UserRole.manager.rawValue, "Manager")
    }

    func test_requestStatus_allCases_count() {
        XCTAssertEqual(RequestStatus.allCases.count, 3)
    }

    func test_expenseCategory_allCases_count() {
        XCTAssertEqual(ExpenseCategory.allCases.count, 7)
    }

    func test_expenseCategory_rawValues_not_empty() {
        for cat in ExpenseCategory.allCases {
            XCTAssertFalse(cat.rawValue.isEmpty)
        }
    }
}
