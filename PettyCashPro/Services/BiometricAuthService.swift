//
//  BiometricAuthService.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-04-20.
//

import Foundation
import LocalAuthentication

final class BiometricAuthService {
    func authenticate(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to open PettyCash Pro."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    completion(success, authError?.localizedDescription)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false, error?.localizedDescription ?? "Biometric authentication not available.")
            }
        }
    }
}
