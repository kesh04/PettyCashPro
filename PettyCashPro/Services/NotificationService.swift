//
//  NotificationService.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-05-06.
//



import Foundation
import UserNotifications
import UIKit

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }


    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print(" Push notification permission granted")
            } else {
                print(" Push notification permission denied: \(error?.localizedDescription ?? "")")
            }
        }
    }


    func sendDeviceTokenToBackend(_ deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(" Device Token: \(tokenString)")

        Task {
            try? await NetworkService.shared.updateDeviceToken(tokenString)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

  
    func notifyManagerNewRequest(staffName: String, amount: Double, category: String) {
        let content = UNMutableNotificationContent()
        content.title = "💰 New Expense Request"
        content.body = "\(staffName) submitted LKR \(Int(amount).formattedWithSeparator) for \(category)"
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "new_request_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }


    func notifyStaffApproved(amount: Double, category: String) {
        let content = UNMutableNotificationContent()
        content.title = " Request Approved!"
        content.body = "Your LKR \(Int(amount).formattedWithSeparator) \(category) expense has been approved."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "approved_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }


    func notifyStaffRejected(amount: Double, category: String, comment: String) {
        let content = UNMutableNotificationContent()
        content.title = "❌ Request Rejected"
        content.body = "Your LKR \(Int(amount).formattedWithSeparator) \(category) request was rejected. \(comment.isEmpty ? "" : "Reason: \(comment)")"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "rejected_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }


    func notifyManagerBudgetWarning(spent: Double, limit: Double) {
        let percent = Int((spent / limit) * 100)
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Budget Alert"
        content.body = "Monthly petty cash budget is \(percent)% used. LKR \(Int(spent).formattedWithSeparator) of LKR \(Int(limit).formattedWithSeparator) spent."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "budget_warning",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }


    func notifyManagerBudgetExceeded(spent: Double, limit: Double) {
        let content = UNMutableNotificationContent()
        content.title = "🚨 Budget Exceeded!"
        content.body = "Monthly petty cash budget has been exceeded. LKR \(Int(spent).formattedWithSeparator) spent of LKR \(Int(limit).formattedWithSeparator) limit."
        content.sound = .defaultCritical

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "budget_exceeded",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }


    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0, withCompletionHandler: nil)
    }
}

