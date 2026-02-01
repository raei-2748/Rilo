//
//  SeedData.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

struct SeedData {
    
    // MARK: - Factory Helpers
    
    static func createReceipt(date: Date = Date(), entries: [SpendEntry], mode: ReceiptMode = .roast) -> DailyReceipt {
        let total = entries.reduce(0) { $0 + $1.amountCents }
        let mindless = RulesEngine.computeMindlessCents(entries: entries)
        let biggest = RulesEngine.computeBiggestSpend(entries: entries)
        let counts = RulesEngine.getCategoryCounts(entries: entries)
        let archetype = RulesEngine.determineArchetype(entries: entries, total: total)
        
        // Create transient receipt to generate verdicts
        let tempReceipt = DailyReceipt(
            date: date,
            entries: entries,
            mode: mode,
            archetype: archetype,
            totalCents: total,
            mindlessCents: mindless,
            biggestSpend: biggest,
            countByCategory: counts
        )
        
        return DailyReceipt(
            date: date,
            entries: entries,
            mode: mode,
            archetype: archetype,
            totalCents: total,
            mindlessCents: mindless,
            biggestSpend: biggest,
            countByCategory: counts,
            verdictLine: RulesEngine.selectVerdict(receipt: tempReceipt, isShareMode: false),
            shareVerdictLine: RulesEngine.selectVerdict(receipt: tempReceipt, isShareMode: true)
        )
    }
    
    // MARK: - Sample Scenarios
    
    static let coffeeAddict = createReceipt(
        entries: [
            SpendEntry(amountCents: 550, merchant: "Blue Bottle", category: .coffee),
            SpendEntry(amountCents: 600, merchant: "Stumptown", category: .coffee),
            SpendEntry(amountCents: 475, merchant: "Local Cafe", category: .coffee),
            SpendEntry(amountCents: 1200, merchant: "Lunch Spot", category: .food)
        ]
    )
    
    static let bigSpender = createReceipt(
        entries: [
            SpendEntry(amountCents: 125000, merchant: "Apple Store", category: .other),
            SpendEntry(amountCents: 4500, merchant: "Dinner", category: .food)
        ]
    )
    
    static let impulseDay = createReceipt(
        entries: [
            SpendEntry(amountCents: 2500, merchant: "Amazon", category: .impulse, isImpulse: true),
            SpendEntry(amountCents: 1500, merchant: "Gumroad", category: .impulse, isImpulse: true),
            SpendEntry(amountCents: 800, merchant: "Gas Station", category: .other)
        ]
    )
    
    static let lowSpendDay = createReceipt(
        entries: [
            SpendEntry(amountCents: 350, merchant: "Subway", category: .transport),
            SpendEntry(amountCents: 1200, merchant: "Salad Bar", category: .food)
        ]
    )
    
    static let cleanDay = createReceipt(entries: [])
    
    static let sampleReceipts: [DailyReceipt] = [
        coffeeAddict,
        bigSpender,
        impulseDay,
        lowSpendDay,
        cleanDay
    ]
}
