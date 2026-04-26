//
//  Models.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-23.
//

import SwiftUI
import MapKit
import CoreLocation


enum UserRole: String, CaseIterable {
    case staff = "Staff"
    case manager = "Manager"
}


enum RequestStatus: String, CaseIterable {
    case pending  = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"

    var displayText: String { rawValue }

    var color: Color {
        switch self {
        case .pending:  return .pendingColor
        case .approved: return .approvedColor
        case .rejected: return .rejectedColor
        }
    }

    var icon: String {
        switch self {
        case .pending:  return "clock.fill"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        }
    }
}

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food        = "Food"
    case transport   = "Transport"
    case stationery  = "Stationery"
    case equipment   = "Equipment"
    case medical     = "Medical"
    case utilities   = "Utilities"
    case other       = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food:       return "fork.knife"
        case .transport:  return "car.fill"
        case .stationery: return "doc.text.fill"
        case .equipment:  return "desktopcomputer"
        case .medical:    return "cross.fill"
        case .utilities:  return "bolt.fill"
        case .other:      return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .food:       return Color(hex: "#FF6B6B")
        case .transport:  return Color(hex: "#4ECDC4")
        case .stationery: return Color(hex: "#45B7D1")
        case .equipment:  return Color(hex: "#96CEB4")
        case .medical:    return Color(hex: "#FF8B94")
        case .utilities:  return Color(hex: "#FFEAA7")
        case .other:      return Color(hex: "#DDA0DD")
        }
    }
}

struct ExpenseRequest: Identifiable {
    var id: UUID = UUID()
    var staffName: String
    var staffDepartment: String
    var staffInitials: String
    var amount: Double
    var category: ExpenseCategory
    var reason: String
    var status: RequestStatus
    var submittedDate: Date
    var managerComment: String? = nil
    var isUrgent: Bool = false

    var formattedAmount: String {
        "LKR \(Int(amount).formattedWithSeparator)"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: submittedDate)
    }
}

struct BudgetCategory: Identifiable {
    var id: UUID = UUID()
    var category: ExpenseCategory
    var allocated: Double
    var spent: Double

    var utilization: Double { min(spent / allocated, 1.0) }
    var isOverBudget: Bool { spent > allocated }
    var formattedSpent: String { "LKR \(Int(spent).formattedWithSeparator)" }
    var formattedAllocated: String { "LKR \(Int(allocated).formattedWithSeparator)" }
}

struct AppUser: Identifiable {
    var id: UUID = UUID()
    var name: String
    var email: String
    var department: String
    var role: UserRole
    var initials: String
}

struct SampleData {
    static let staffUser = AppUser(
        name: "Amal Perera",
        email: "amal@company.lk",
        department: "IT Department",
        role: .staff,
        initials: "AP"
    )

    static let managerUser = AppUser(
        name: "Kushi Fernando",
        email: "kushi@company.lk",
        department: "Management",
        role: .manager,
        initials: "KF"
    )

    static var requests: [ExpenseRequest] = [
        ExpenseRequest(staffName: "Amal Perera", staffDepartment: "IT", staffInitials: "AP",
                       amount: 12000, category: .equipment, reason: "New keyboard and mouse set",
                       status: .pending, submittedDate: Date().addingTimeInterval(-7200), isUrgent: true),
        ExpenseRequest(staffName: "Dilini Fernando", staffDepartment: "Sales", staffInitials: "DF",
                       amount: 2400, category: .food, reason: "Team lunch meeting",
                       status: .pending, submittedDate: Date().addingTimeInterval(-86400)),
        ExpenseRequest(staffName: "Nuwan Jayawardena", staffDepartment: "HR", staffInitials: "NJ",
                       amount: 1800, category: .medical, reason: "First aid kit refill",
                       status: .approved, submittedDate: Date().addingTimeInterval(-172800)),
        ExpenseRequest(staffName: "Sanduni Rathnayake", staffDepartment: "Finance", staffInitials: "SR",
                       amount: 650, category: .transport, reason: "Taxi to client meeting",
                       status: .pending, submittedDate: Date().addingTimeInterval(-259200)),
        ExpenseRequest(staffName: "Amal Perera", staffDepartment: "IT", staffInitials: "AP",
                       amount: 1150, category: .stationery, reason: "Office supplies",
                       status: .approved, submittedDate: Date().addingTimeInterval(-345600)),
        ExpenseRequest(staffName: "Chamara Silva", staffDepartment: "IT", staffInitials: "CS",
                       amount: 12000, category: .equipment, reason: "Coffee machine for office",
                       status: .rejected, submittedDate: Date().addingTimeInterval(-432000),
                       managerComment: "Exceeds petty cash limit. Please submit via procurement.")
    ]

    static var myRequests: [ExpenseRequest] {
        [requests[4], requests[2], requests[3], requests[5]].map { req in
            var r = req
            r.staffName = "Amal Perera"
            r.staffInitials = "AP"
            return r
        }
    }

    static let budgetCategories: [BudgetCategory] = [
        BudgetCategory(category: .transport,  allocated: 100000, spent: 95000),
        BudgetCategory(category: .food,       allocated: 200000, spent: 140000),
        BudgetCategory(category: .stationery, allocated: 80000,  spent: 32000),
        BudgetCategory(category: .equipment,  allocated: 150000, spent: 111000),
        BudgetCategory(category: .medical,    allocated: 50000,  spent: 22000),
    ]
}

extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}




struct ATMLocation: Identifiable {
    let id = UUID()
    let name: String
    let bank: String
    let coordinate: CLLocationCoordinate2D
    let distance: Double

    var formattedDistance: String {
        distance < 1 ? "\(Int(distance * 1000))m" : String(format: "%.1f km", distance)
    }
}


