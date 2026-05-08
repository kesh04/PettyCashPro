//
//  SiriIntentHandler.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-05-07.
//


import AppIntents
import Foundation


private let kAppGroup  = "group.com.pettycashpro.app"
private let kTokenKey  = "authToken"
private let kBaseURL   = "http://192.168.1.97:3000/api"


struct SubmitExpenseIntent: AppIntent {

    static var title: LocalizedStringResource = "Submit Petty Cash Request"
    static var description = IntentDescription(
        "Submit a new petty cash expense request through PettyCash Pro."
    )

    static var suggestedInvocationPhrase: String = "Submit a petty cash request"

    @Parameter(
        title: "Amount (LKR)",
        description: "The expense amount in Sri Lankan Rupees",
        requestValueDialog: IntentDialog("How much is the expense? Please say the amount in Rupees.")
    )
    var amount: Double

    @Parameter(
        title: "Category",
        description: "Expense category",
        default: "Other",
        requestValueDialog: IntentDialog("What category is this expense? For example: Food, Transport, Stationery, Equipment, Medical, or Other."), optionsProvider: CategoryOptionsProvider()
    )
    var category: String

    @Parameter(
        title: "Reason",
        description: "Reason for the expense",
        requestValueDialog: IntentDialog("What is the reason for this expense?")
    )
    var reason: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {

        if amount <= 0 {
            throw $amount.needsValueError("How much is the expense?")
        }

        if reason.trimmingCharacters(in: .whitespaces).isEmpty {
            throw $reason.needsValueError("What is the reason for this expense?")
        }

        let defaults = UserDefaults(suiteName: kAppGroup)
        guard let token = defaults?.string(forKey: kTokenKey), !token.isEmpty else {
            return .result(dialog: IntentDialog("Please open PettyCash Pro and log in first before using Siri."))
        }

        guard let url = URL(string: "\(kBaseURL)/expenses") else {
            return .result(dialog: IntentDialog("Could not connect to PettyCash Pro. Please try again."))
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 20

        let body: [String: Any] = [
            "amount":   amount,
            "category": category,
            "reason":   reason,
            "isUrgent": false
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        do {
            let (_, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                let fmtAmount = formatLKR(amount)
                return .result(dialog: IntentDialog(
                    "Done! Your petty cash request for \(fmtAmount) under \(category) has been submitted. Your manager will be notified."
                ))
            } else {
                return .result(dialog: IntentDialog("The request could not be submitted. Please check the app and try again."))
            }
        } catch {
            return .result(dialog: IntentDialog("Could not reach the server. Please check your internet connection and try again."))
        }
    }

    private func formatLKR(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle       = .decimal
        f.groupingSeparator = ","
        let formatted = f.string(from: NSNumber(value: Int(value))) ?? "\(Int(value))"
        return "LKR \(formatted)"
    }
}

struct CategoryOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        ["Food", "Transport", "Stationery", "Equipment", "Medical", "Utilities", "Other"]
    }
}

struct CheckRequestStatusIntent: AppIntent {

    static var title: LocalizedStringResource = "Check Petty Cash Request Status"
    static var description = IntentDescription(
        "Check the status of your petty cash requests in PettyCash Pro."
    )

    static var suggestedInvocationPhrase: String = "Check my petty cash request status"

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {

        let defaults = UserDefaults(suiteName: kAppGroup)
        guard let token = defaults?.string(forKey: kTokenKey), !token.isEmpty else {
            return .result(dialog: IntentDialog("Please open PettyCash Pro and log in first."))
        }

        guard let url = URL(string: "\(kBaseURL)/expenses/my-requests") else {
            return .result(dialog: IntentDialog("Could not connect to PettyCash Pro."))
        }

        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.timeoutInterval = 20

        do {
            let (data, _) = try await URLSession.shared.data(for: req)

            struct QuickSummary: Codable {
                let pendingCount:  Int
                let approvedCount: Int
                let rejectedCount: Int
            }
            struct QuickResponse: Codable {
                let summary: QuickSummary
            }

            let result   = try JSONDecoder().decode(QuickResponse.self, from: data)
            let s        = result.summary
            let pending  = s.pendingCount
            let approved = s.approvedCount
            let rejected = s.rejectedCount

            var speech = "Here is your petty cash summary. "
            if pending == 0 && approved == 0 && rejected == 0 {
                speech += "You have no requests yet."
            } else {
                if pending  > 0 { speech += "You have \(pending) pending request\(pending > 1 ? "s" : "") waiting for approval. " }
                if approved > 0 { speech += "\(approved) request\(approved > 1 ? "s have" : " has") been approved. " }
                if rejected > 0 { speech += "\(rejected) request\(rejected > 1 ? "s were" : " was") rejected." }
            }

            return .result(dialog: IntentDialog(stringLiteral: speech))

        } catch {
            return .result(dialog: IntentDialog("Could not fetch your request status. Please check your connection."))
        }
    }
}

struct PettyCashAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SubmitExpenseIntent(),
            phrases: [
                "Submit a petty cash request in \(.applicationName)",
                "New expense request in \(.applicationName)",
                "Submit expense in \(.applicationName)"
            ],
            shortTitle: "Submit Expense",
            systemImageName: "paperplane.fill"
        )
        AppShortcut(
            intent: CheckRequestStatusIntent(),
            phrases: [
                "Check my petty cash status in \(.applicationName)",
                "Check my request status in \(.applicationName)",
                "What is my expense status in \(.applicationName)"
            ],
            shortTitle: "Check Status",
            systemImageName: "clock.fill"
        )
    }
}
