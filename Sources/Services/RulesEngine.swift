//
//  RulesEngine.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

struct RulesEngine {
    
    /// Categories eligible for serial-based mindless counting
    private static let mindlessEligibleCategories: Set<SpendCategory> = [
        .coffee, .food, .transport, .impulse
    ]

    /// Max amount (in cents) for serial category entries to count as mindless
    private static let serialMindlessCap: Int = 2000  // $20

    /// Computes mindless spending based on impulse flags AND serial category patterns
    static func computeMindlessCents(entries: [SpendEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }

        let serialCategories = serialCategories(for: entries)

        return entries.reduce(0) { total, entry in
            guard isMindlessEntry(entry, serialCategories: serialCategories) else { return total }
            return total + entry.amountCents
        }
    }

    /// Identifies the biggest spend of the day
    static func computeBiggestSpend(entries: [SpendEntry]) -> SpendEntry? {
        entries.sorted(by: isPreferredBiggestSpend).first
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
    
    /// Selects a deterministic verdict based on the day's events and archetype
    static func selectVerdict(
        receipt: DailyReceipt,
        isShareMode: Bool = false,
        streakDays: Int? = nil,
        yesterdayArchetype: SpenderArchetype? = nil
    ) -> String {
        let seed = stableSeed(for: receipt)
        let context = VerdictTemplateContext.from(
            receipt: receipt,
            streakDays: streakDays,
            yesterdayArchetype: yesterdayArchetype
        )

        // Get archetype-specific templates
        let templates: [VerdictTemplate]?
        if isShareMode {
            templates = ShareVerdictLibrary.templates[receipt.archetype]
        } else if receipt.mode == .roast {
            templates = VerdictLibrary.roastTemplates[receipt.archetype]
        } else {
            templates = VerdictLibrary.therapistTemplates[receipt.archetype]
        }

        // Use archetype templates if available, fill placeholders with real data
        if let templates = templates, !templates.isEmpty {
            let index = seed % templates.count
            return templates[index].render(with: context)
        }

        // Fallback to original flat arrays (for backwards compatibility)
        let fallbackLibrary = isShareMode
            ? ShareVerdictLibrary.roastVerdicts
            : (receipt.mode == .roast ? VerdictLibrary.roastVerdicts : VerdictLibrary.therapistVerdicts)

        let index = seed % fallbackLibrary.count
        return fallbackLibrary[index]
    }
    
    static func getCategoryCounts(entries: [SpendEntry]) -> [SpendCategory: Int] {
        var counts: [SpendCategory: Int] = [:]
        for entry in entries {
            counts[entry.category, default: 0] += 1
        }
        return counts
    }

    // MARK: - Mindless Helpers

    /// Finds categories that meet the serial threshold.
    private static func serialCategories(for entries: [SpendEntry]) -> Set<SpendCategory> {
        let counts = getCategoryCounts(entries: entries)
        let serialKeys = counts.filter { $0.value >= ReceiptConfig.serialCategoryThreshold }.keys
        return Set(serialKeys)
    }

    /// Impulse flags always count, even if the category is not eligible or exceeds the cap.
    private static func isMindlessEntry(
        _ entry: SpendEntry,
        serialCategories: Set<SpendCategory>
    ) -> Bool {
        if entry.isImpulse {
            return true
        }

        guard serialCategories.contains(entry.category) else { return false }
        guard mindlessEligibleCategories.contains(entry.category) else { return false }
        return entry.amountCents <= serialMindlessCap
    }

    // MARK: - Deterministic Helpers

    private static func isPreferredBiggestSpend(_ lhs: SpendEntry, _ rhs: SpendEntry) -> Bool {
        if lhs.amountCents != rhs.amountCents {
            return lhs.amountCents > rhs.amountCents
        }
        if lhs.timestamp != rhs.timestamp {
            return lhs.timestamp < rhs.timestamp
        }
        if lhs.category != rhs.category {
            return lhs.category.rawValue < rhs.category.rawValue
        }
        return lhs.id.uuidString < rhs.id.uuidString
    }

    private static func stableSeed(for receipt: DailyReceipt) -> Int {
        let dateSeconds = Int(receipt.date.timeIntervalSince1970)
        let uuidHash = stableHash(receipt.id.uuidString)
        let combined = (dateSeconds &* 31) &+ uuidHash
        if combined == Int.min {
            return 0
        }
        return abs(combined)
    }

    private static func stableHash(_ string: String) -> Int {
        var hash = 5381
        for scalar in string.unicodeScalars {
            hash = ((hash << 5) &+ hash) &+ Int(scalar.value)
        }
        return hash
    }
}
