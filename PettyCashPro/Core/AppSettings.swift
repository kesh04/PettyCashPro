//
//  AppSettings.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-05-06.
//


import SwiftUI
import Combine

class AppSettings: ObservableObject {


    @Published var isDarkMode: Bool {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode") }
    }

    @Published var isBiometricEnabled: Bool {
        didSet { UserDefaults.standard.set(isBiometricEnabled, forKey: "isBiometricEnabled") }
    }


    @Published var isNotificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(isNotificationsEnabled, forKey: "isNotificationsEnabled") }
    }

    init() {
        self.isDarkMode            = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.isBiometricEnabled    = UserDefaults.standard.object(forKey: "isBiometricEnabled") as? Bool ?? true
        self.isNotificationsEnabled = UserDefaults.standard.object(forKey: "isNotificationsEnabled") as? Bool ?? true
    }

    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
}
