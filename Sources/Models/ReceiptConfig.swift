//
//  ReceiptConfig.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

struct ReceiptConfig {
    static let coffeeThreshold: Int = 400 // cents
    static let bigTicketThreshold: Int = 5000 // cents
    static let mindlessRatioThreshold: Double = 0.5
    static let serialCategoryThreshold: Int = 3
}
