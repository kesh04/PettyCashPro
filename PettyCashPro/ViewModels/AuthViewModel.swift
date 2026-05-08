//
//  Untitled.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-23.
//


import SwiftUI
import LocalAuthentication
import Combine

class AuthViewModel: ObservableObject {

    @Published var currentUser: AppUser? = nil
    @Published var isAuthenticated: Bool = false
    @Published var selectedRole: UserRole = .staff
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let network = NetworkService.shared
    private let notificationService = NotificationService.shared

    init() {
        restoreSession()
    }

    private func restoreSession() {
        guard let data = UserDefaults.standard.data(forKey: "savedUser"),
              let saved = try? JSONDecoder().decode(AppUser.self, from: data),
              network.token != nil else { return }
        self.currentUser = saved
        self.isAuthenticated = true
        notificationService.requestPermission()
    }

    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let response = try await network.login(email: email, password: password)
                let user = AppUser(
                    id: UUID(),
                    name: response.name,
                    email: response.email,
                    department: response.department,
                    role: response.role == "manager" ? .manager : .staff,
                    initials: response.initials,
                    backendId: response.id
                )
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: "savedUser")
                }
                UserDefaults.standard.synchronize()
                await MainActor.run {
                    self.currentUser = user
                    self.isLoading = false
                    self.email = ""
                    self.password = ""
                    notificationService.requestPermission()
                    withAnimation { self.isAuthenticated = true }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Wrong email or password. Please try again."
                }
            }
        }
    }

    func loginWithBiometrics(settings: AppSettings? = nil) {
        if let settings = settings, !settings.isBiometricEnabled {
            errorMessage = "Biometric login is disabled. Enable it in Profile → Biometric Login."
            return
        }
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            let code = error?.code ?? 0
            if code == LAError.biometryNotEnrolled.rawValue {
                errorMessage = "No Face ID enrolled. Set it up in iOS Settings → Face ID & Passcode."
            } else if code == LAError.biometryNotAvailable.rawValue {
                errorMessage = "Face ID not available on this device."
            } else {
                errorMessage = error?.localizedDescription ?? "Biometric authentication not available."
            }
            return
        }
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to access PettyCash Pro"
        ) { success, authError in
            DispatchQueue.main.async {
                if success {
                    guard let data = UserDefaults.standard.data(forKey: "savedUser"),
                            let savedUser = try? JSONDecoder().decode(AppUser.self, from: data) else {
                          self.errorMessage = "Please log in with email once first to enable Face ID."
                          return
                      }

                      let expectedRole = self.selectedRole
                      guard savedUser.role == expectedRole else {
                          self.errorMessage = "Face ID is linked to your \(savedUser.role.rawValue) account. Please log in with email as \(expectedRole.rawValue)."
                          return
                      }

               
                    if NetworkService.shared.token != nil {
                        self.currentUser = savedUser
                        NotificationService.shared.requestPermission()
                        withAnimation { self.isAuthenticated = true }
                    } else {
                      
                        self.errorMessage = "Session expired. Please log in with email once to refresh."
                    }
                } else {
                    if let error = authError {
                        let code = (error as NSError).code
                        if code != LAError.userCancel.rawValue {
                            self.errorMessage = "Authentication failed. Please use email login."
                        }
                    }
                }
            }
        }
    }

    func logout() {
  
        NotificationService.shared.clearBadge()
        withAnimation {
            isAuthenticated = false
            currentUser = nil
            email = ""
            password = ""
            errorMessage = nil
        }
    }
}
