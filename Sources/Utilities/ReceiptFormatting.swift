//
//  ReceiptFormatting.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

extension Int {
    /// Formats cents as currency string (e.g. 500 -> "$5.00")
    func formattedAsCurrency() -> String {
        let dollars = Double(self) / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: dollars)) ?? "$0.00"
    }
}

extension Date {
    /// Formats date for receipt header (e.g. "FEB 01, 2026 - 15:27")
    func receiptDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy - HH:mm"
        return formatter.string(from: self).uppercased()
    }
}
