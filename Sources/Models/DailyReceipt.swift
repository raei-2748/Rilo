//
//  DailyReceipt.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

struct DailyReceipt: Identifiable, Codable {
    let id: UUID
    let date: Date
    let entries: [SpendEntry]
    let mode: ReceiptMode
    let archetype: SpenderArchetype
    
    // Derived signals for the rules engine
    let totalCents: Int
    let mindlessCents: Int
    let biggestSpend: SpendEntry?
    let countByCategory: [SpendCategory: Int]
    
    // Polished feedback from the rules engine
    let verdictLine: String
    let shareVerdictLine: String
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        entries: [SpendEntry],
        mode: ReceiptMode = .roast,
        archetype: SpenderArchetype = .lowDrama,
        totalCents: Int = 0,
        mindlessCents: Int = 0,
        biggestSpend: SpendEntry? = nil,
        countByCategory: [SpendCategory: Int] = [:],
        verdictLine: String = "No data logged yet.",
        shareVerdictLine: String = "Keeping it real."
    ) {
        self.id = id
        self.date = date
        self.entries = entries
        self.mode = mode
        self.archetype = archetype
        self.totalCents = totalCents
        self.mindlessCents = mindlessCents
        self.biggestSpend = biggestSpend
        self.countByCategory = countByCategory
        self.verdictLine = verdictLine
        self.shareVerdictLine = shareVerdictLine
    }
    
    /// Logic to detect if this receipt is worth a share nudge
    func detectShareNudge(yesterdayArchetype: SpenderArchetype?, currentStreak: Int) -> ShareNudgeEvent? {
        // Priority based nudge detection
        if archetype == .repeatOffender { return .repeatOffender }
        if archetype == .bigSpender { return .bigTicket }
        if let yesterday = yesterdayArchetype, yesterday != archetype { return .newArchetype }
        if currentStreak > 0 && currentStreak % 7 == 0 { return .streakMilestone }
        
        return nil
    }
}
