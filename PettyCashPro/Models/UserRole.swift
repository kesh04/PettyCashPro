//
//  UserRole.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-20.
//

import Foundation

enum UserRole: String, CaseIterable, Identifiable {
    case staff = "Staff"
    case manager = "Manager"

    var id: String { rawValue }
}
