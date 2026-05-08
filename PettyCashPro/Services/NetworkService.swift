//
//  NetworkService.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-05-06.
//


import Foundation
import UIKit
import Combine

// MARK: - API Response Models

struct LoginResponse: Codable {
    let id: String
    let name: String
    let email: String
    let department: String
    let role: String
    let initials: String
    let token: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, email, department, role, initials, token
    }
}

struct APIExpenseRequest: Codable, Identifiable {
    let id: String
    let staffId: String?
    let staffName: String
    let staffDepartment: String
    let staffInitials: String
    let amount: Double
    let category: String
    let reason: String
    let status: String
    let isUrgent: Bool
    let managerComment: String?
    let receiptImagePath: String?
    let createdAt: String
    let reviewedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case staffId, staffName, staffDepartment, staffInitials
        case amount, category, reason, status, isUrgent
        case managerComment, receiptImagePath, createdAt, reviewedAt
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: Int(amount))) ?? "\(Int(amount))"
        return "LKR \(formatted)"
    }

    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: createdAt) {
            let df = DateFormatter()
            df.dateFormat = "MMM dd"
            return df.string(from: date)
        }
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: createdAt) {
            let df = DateFormatter()
            df.dateFormat = "MMM dd"
            return df.string(from: date)
        }
        return "N/A"
    }
}

struct MyRequestsResponse: Codable {
    let requests: [APIExpenseRequest]
    let summary: StaffSummary
}

struct StaffSummary: Codable {
    let totalRequests: Int
    let pendingCount: Int
    let approvedCount: Int
    let rejectedCount: Int
    let pendingAmount: Double
    let approvedThisMonth: Double
}

struct AllRequestsResponse: Codable {
    let requests: [APIExpenseRequest]
    let summary: ManagerSummary
}

struct ManagerSummary: Codable {
    let totalRequests: Int
    let pendingCount: Int
    let approvedCount: Int
    let rejectedCount: Int
    let totalApproved: Double
    let totalPending: Double
}

struct APIBudget: Codable {
    let id: String
    let period: String
    let monthlyLimit: Double
    let categories: [APIBudgetCategory]
    let totalSpent: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case period, monthlyLimit, categories, totalSpent
    }
}

struct APIBudgetCategory: Codable {
    let category: String
    let allocated: Double
    let spent: Double
}

struct APIError: Codable {
    let message: String
}



class NetworkService {
    static let shared = NetworkService()
    private init() {}

   
    // Simulator  → http://localhost:3000/api
    // Real iPhone → http://192.168.1.84:3000/api
    let baseURL = "http://192.168.1.97:3000/api"


    private let appGroupID = "group.com.pettycashpro.app"

    var token: String? {
        get {
          
            if let t = UserDefaults(suiteName: appGroupID)?.string(forKey: "authToken") { return t }
            return UserDefaults.standard.string(forKey: "authToken")
        }
        set {
            UserDefaults(suiteName: appGroupID)?.set(newValue, forKey: "authToken")
            UserDefaults.standard.set(newValue, forKey: "authToken")
        }
    }

   
    private var authHeaders: [String: String] {
        var headers = ["Content-Type": "application/json"]
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }


    private func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.timeoutInterval = 30
        authHeaders.forEach { req.setValue($1, forHTTPHeaderField: $0) }

        if let body = body {
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: req)

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw NSError(
                    domain: "API",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: apiError.message]
                )
            }
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

   

    func login(email: String, password: String) async throws -> LoginResponse {
        let response: LoginResponse = try await request(
            path: "/auth/login",
            method: "POST",
            body: ["email": email, "password": password]
        )
        self.token = response.token
        return response
    }

    func getProfile() async throws -> LoginResponse {
        return try await request(path: "/auth/profile")
    }

    func updateDeviceToken(_ deviceToken: String) async throws {
        let _: [String: String] = try await request(
            path: "/auth/device-token",
            method: "PUT",
            body: ["deviceToken": deviceToken]
        )
    }

 

    func getMyRequests(status: String? = nil) async throws -> MyRequestsResponse {
        var path = "/expenses/my-requests"
        if let status = status { path += "?status=\(status)" }
        return try await request(path: path)
    }

    func submitRequest(
        amount: Double,
        category: String,
        reason: String,
        isUrgent: Bool,
        imageData: Data?
    ) async throws -> APIExpenseRequest {
        guard let url = URL(string: "\(baseURL)/expenses") else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.timeoutInterval = 60

        if let token = token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var bodyData = Data()

        func appendString(_ string: String) {
            if let data = string.data(using: .utf8) { bodyData.append(data) }
        }

        let fields: [(String, String)] = [
            ("amount", "\(amount)"),
            ("category", category),
            ("reason", reason),
            ("isUrgent", isUrgent ? "true" : "false")
        ]

        for (name, value) in fields {
            appendString("--\(boundary)\r\n")
            appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            appendString("\(value)\r\n")
        }

        if let imageData = imageData {
            appendString("--\(boundary)\r\n")
            appendString("Content-Disposition: form-data; name=\"receiptImage\"; filename=\"receipt.jpg\"\r\n")
            appendString("Content-Type: image/jpeg\r\n\r\n")
            bodyData.append(imageData)
            appendString("\r\n")
        }

        appendString("--\(boundary)--\r\n")
        req.httpBody = bodyData

        let (data, response) = try await URLSession.shared.data(for: req)

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw NSError(
                    domain: "API",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: apiError.message]
                )
            }
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(APIExpenseRequest.self, from: data)
    }

    // MARK: - Manager Endpoints

    func getAllRequests(status: String? = nil, filter: String? = nil) async throws -> AllRequestsResponse {
        var path = "/expenses?"
        if let status = status { path += "status=\(status)&" }
        if let filter = filter { path += "filter=\(filter)" }
        return try await request(path: path)
    }

    func approveRequest(id: String, comment: String) async throws -> APIExpenseRequest {
        return try await request(
            path: "/expenses/\(id)/approve",
            method: "PUT",
            body: ["comment": comment]
        )
    }

    func rejectRequest(id: String, comment: String) async throws -> APIExpenseRequest {
        return try await request(
            path: "/expenses/\(id)/reject",
            method: "PUT",
            body: ["comment": comment]
        )
    }

    func getBudget() async throws -> APIBudget {
        return try await request(path: "/budget")
    }

    func updateMonthlyLimit(_ limit: Double) async throws -> APIBudget {
        return try await request(
            path: "/budget/limit",
            method: "PUT",
            body: ["monthlyLimit": limit]
        )
    }


    func downloadReportPDF(period: String? = nil) async throws -> URL {
        var urlString = "\(baseURL)/budget/report/pdf"
        if let period = period {
            urlString += "?period=\(period)"
        }

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = 60
        if let token = token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: req)

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw NSError(
                    domain: "API",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: apiError.message]
                )
            }
            throw URLError(.badServerResponse)
        }


        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let periodStr = period ?? formatter.string(from: Date())
        let fileName = "PettyCash_Report_\(periodStr).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: tempURL)
        return tempURL
    }

    func logout() {
        token = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "savedUser")
    }
}
