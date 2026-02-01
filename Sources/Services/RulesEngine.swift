//
//  RulesEngine.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

struct RulesEngine {
    
    /// Computes mindless spending based on categories and repeats
    static func computeMindlessCents(entries: [SpendEntry]) -> Int {
        var total = 0
        for entry in entries {
            if entry.isImpulse {
                total += entry.amountCents
            }
        }
        return total
    }
    
    /// Identifies the biggest spend of the day
    static func computeBiggestSpend(entries: [SpendEntry]) -> SpendEntry? {
        entries.max(by: { $0.amountCents < $1.amountCents })
    }
    
    /// Selects the spender archetype based on day's data
    static func determineArchetype(entries: [SpendEntry], total: Int) -> SpenderArchetype {
        if entries.isEmpty { return .cleanDay }
        
        let counts = getCategoryCounts(entries: entries)
        let biggest = computeBiggestSpend(entries: entries)
        
        // Priority logic
        if let biggest = biggest, biggest.amountCents > ReceiptConfig.bigTicketThreshold {
            return .bigSpender
        }
        
        if (counts[.coffee] ?? 0) >= ReceiptConfig.serialCategoryThreshold {
            return .coffeeAddict
        }
        
        if entries.filter({ $0.isImpulse || $0.category == .impulse }).count >= 2 {
            return .impulseBuyer
        }
        
        if (counts[.transport] ?? 0) >= 2 {
            return .convenienceKing
        }
        
        if (counts[.food] ?? 0) >= 2 {
            return .foody
        }
        
        if total > 10000 {
            return .repeatOffender
        }
        
        return .lowDrama
    }
    
    /// Selects a deterministic verdict based on the day's events
    static func selectVerdict(receipt: DailyReceipt, isShareMode: Bool = false) -> String {
        let seed = abs(receipt.date.timeIntervalSince1970.hashValue ^ receipt.id.hashValue)
        let library = isShareMode ? ShareVerdictLibrary.roastVerdicts : (receipt.mode == .roast ? VerdictLibrary.roastVerdicts : VerdictLibrary.therapistVerdicts)
        
        let index = seed % library.count
        return library[index]
    }
    
    static func getCategoryCounts(entries: [SpendEntry]) -> [SpendCategory: Int] {
        var counts: [SpendCategory: Int] = [:]
        for entry in entries {
            counts[entry.category, default: 0] += 1
        }
        return counts
    }
}
