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

    func login() {
        isLoading = true
        errorMessage = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            if self.email.isEmpty || self.password.isEmpty {
                self.errorMessage = "Please enter your email and password."
                return
            }
            switch self.selectedRole {
            case .staff:
                self.currentUser = SampleData.staffUser
            case .manager:
                self.currentUser = SampleData.managerUser
            }
            withAnimation { self.isAuthenticated = true }
        }
    }

    func loginWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Authenticate to access PettyCash Pro") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.currentUser = self.selectedRole == .staff ? SampleData.staffUser : SampleData.managerUser
                        withAnimation { self.isAuthenticated = true }
                    }
                }
            }
        } else {
            currentUser = selectedRole == .staff ? SampleData.staffUser : SampleData.managerUser
            withAnimation { isAuthenticated = true }
        }
    }

    func logout() {
        withAnimation {
            isAuthenticated = false
            currentUser = nil
            email = ""
            password = ""
        }
    }
}
#Preview {
    
}