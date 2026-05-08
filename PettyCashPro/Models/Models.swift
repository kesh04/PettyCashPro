//
//  Models.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-23.
//

import SwiftUI
import MapKit
import CoreLocation



enum UserRole: String, CaseIterable, Codable {
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



struct AppUser: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var email: String
    var department: String
    var role: UserRole
    var initials: String
    var backendId: String = ""
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



struct SampleData {
    static let staffUser = AppUser(
        name: "Amal Perera",
        email: "staff@gmail.com",
        department: "IT Department",
        role: .staff,
        initials: "AP"
    )

    static let managerUser = AppUser(
        name: "Kushi Fernando",
        email: "man@gmail.com",
        department: "Management",
        role: .manager,
        initials: "KF"
    )

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

