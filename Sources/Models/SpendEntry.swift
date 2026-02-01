//
//  SpendEntry.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

struct SpendEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let amountCents: Int
    let merchant: String?
    let category: SpendCategory
    let isImpulse: Bool
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        amountCents: Int,
        merchant: String? = nil,
        category: SpendCategory,
        isImpulse: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.amountCents = amountCents
        self.merchant = merchant
        self.category = category
        self.isImpulse = isImpulse
    }
}
