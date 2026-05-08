//
//  PettyCashProIntents.swift
//  PettyCashProIntents
//
//  Created by Keshana Liyanaarachchi on 2026-05-07.
//

import AppIntents

struct PettyCashProIntents: AppIntent {
    static var title: LocalizedStringResource { "PettyCashProIntents" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
