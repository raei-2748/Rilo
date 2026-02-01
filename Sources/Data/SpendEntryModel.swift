//
//  SpendEntryModel.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation
import SwiftData

@Model
final class SpendEntryModel {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var amountCents: Int = 0
    var merchant: String?
    var categoryString: String = "other"
    var isImpulse: Bool = false
    
    var category: SpendCategory {
        get { SpendCategory(rawValue: categoryString) ?? .other }
        set { categoryString = newValue.rawValue }
    }
    
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
        self.categoryString = category.rawValue
        self.isImpulse = isImpulse
    }
    
    /// Helper to convert to the view-friendly struct
    func toStruct() -> SpendEntry {
        SpendEntry(
            id: id,
            timestamp: timestamp,
            amountCents: amountCents,
            merchant: merchant,
            category: category,
            isImpulse: isImpulse
        )
    }
}
