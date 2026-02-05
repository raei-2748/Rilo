//
//  VerdictLibrary.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

// MARK: - Verdict Template Rendering

struct VerdictTemplateContext {
    let totalCents: Int
    let mindlessCents: Int
    let biggestSpendName: String?
    let biggestSpendAmountCents: Int?
    let topCategoryName: String?
    let topCategoryAmountCents: Int?
    let topCategoryCount: Int?
    let streakDays: Int?
    let yesterdayArchetype: SpenderArchetype?

    static func from(
        receipt: DailyReceipt,
        streakDays: Int? = nil,
        yesterdayArchetype: SpenderArchetype? = nil
    ) -> VerdictTemplateContext {
        let topCategory = topCategoryStats(entries: receipt.entries)
        let biggest = receipt.entries.isEmpty
            ? receipt.biggestSpend
            : RulesEngine.computeBiggestSpend(entries: receipt.entries)

        let trimmedMerchant = biggest?.merchant?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedBiggestName = (trimmedMerchant?.isEmpty == false ? trimmedMerchant : nil)
            ?? biggest?.category.displayName

        return VerdictTemplateContext(
            totalCents: receipt.totalCents,
            mindlessCents: receipt.mindlessCents,
            biggestSpendName: resolvedBiggestName,
            biggestSpendAmountCents: biggest?.amountCents,
            topCategoryName: topCategory?.category.displayName,
            topCategoryAmountCents: topCategory?.amountCents,
            topCategoryCount: topCategory?.count,
            streakDays: streakDays,
            yesterdayArchetype: yesterdayArchetype
        )
    }

    private struct CategoryStats {
        let category: SpendCategory
        let count: Int
        let amountCents: Int
    }

    /// Uses deterministic tie breaking: highest count, then highest amount, then category order.
    private static func topCategoryStats(entries: [SpendEntry]) -> CategoryStats? {
        guard !entries.isEmpty else { return nil }

        var counts: [SpendCategory: Int] = [:]
        var totals: [SpendCategory: Int] = [:]

        for entry in entries {
            counts[entry.category, default: 0] += 1
            totals[entry.category, default: 0] += entry.amountCents
        }

        var best: CategoryStats?
        for category in SpendCategory.allCases {
            guard let count = counts[category] else { continue }
            let amount = totals[category, default: 0]
            let candidate = CategoryStats(category: category, count: count, amountCents: amount)

            if let current = best {
                if candidate.count > current.count {
                    best = candidate
                } else if candidate.count == current.count && candidate.amountCents > current.amountCents {
                    best = candidate
                }
            } else {
                best = candidate
            }
        }

        return best
    }
}

struct VerdictTemplateRenderer {
    static func render(template: String, context: VerdictTemplateContext) -> String {
        var result = template

        // Supported placeholders:
        // {total}, {mindless_amount}, {biggest_spend_name}, {biggest_spend_amount},
        // {top_category_name}, {top_category_amount}, {top_category_count},
        // {streak_days}, {yesterday_archetype}
        let replacements: [String: String] = [
            "{total}": formatCurrency(context.totalCents),
            "{mindless_amount}": formatCurrency(context.mindlessCents),
            "{biggest_spend_name}": context.biggestSpendName ?? "something small",
            "{biggest_spend_amount}": context.biggestSpendAmountCents.map(formatCurrency) ?? "a small amount",
            "{top_category_name}": context.topCategoryName ?? "something",
            "{top_category_amount}": context.topCategoryAmountCents.map(formatCurrency) ?? "a small amount",
            "{top_category_count}": context.topCategoryCount.map(String.init) ?? "0",
            "{streak_days}": context.streakDays.map(String.init) ?? "",
            "{yesterday_archetype}": context.yesterdayArchetype.map(readableArchetypeName) ?? ""
        ]

        for (placeholder, value) in replacements {
            result = result.replacingOccurrences(of: placeholder, with: value)
        }

        // Remove any unsupported placeholders to avoid leaking tokens.
        result = result.replacingOccurrences(
            of: "\\{[a-z_]+\\}",
            with: "",
            options: .regularExpression
        )

        return cleanSpacing(in: result)
    }

    private static func readableArchetypeName(_ archetype: SpenderArchetype) -> String {
        switch archetype {
        case .bigSpender:
            return "big spender"
        case .coffeeAddict:
            return "coffee addict"
        case .impulseBuyer:
            return "impulse buyer"
        case .convenienceKing:
            return "convenience king"
        case .foody:
            return "foody"
        case .lowDrama:
            return "low drama"
        case .repeatOffender:
            return "repeat offender"
        case .cleanDay:
            return "clean day"
        }
    }

    private static func formatCurrency(_ cents: Int) -> String {
        let dollars = Double(cents) / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: NSNumber(value: dollars)) ?? String(format: "$%.2f", dollars)
    }

    private static func cleanSpacing(in text: String) -> String {
        var result = text
        result = result.replacingOccurrences(of: " ,", with: ",")
        result = result.replacingOccurrences(of: " .", with: ".")
        result = result.replacingOccurrences(of: " !", with: "!")
        result = result.replacingOccurrences(of: " ?", with: "?")
        result = result.replacingOccurrences(
            of: "\\s{2,}",
            with: " ",
            options: .regularExpression
        )
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Verdict Template

struct VerdictTemplate {
    let template: String

    func render(with context: VerdictTemplateContext) -> String {
        VerdictTemplateRenderer.render(template: template, context: context)
    }
}

// MARK: - Verdict Library (Roast & Therapist)

struct VerdictLibrary {

    // MARK: - Roast Templates (by archetype)

    static let roastTemplates: [SpenderArchetype: [VerdictTemplate]] = [
        .bigSpender: [
            VerdictTemplate(template: "{biggest_spend_amount} on {biggest_spend_name}? Your bank account just flinched."),
            VerdictTemplate(template: "Spending {total} like it's Monopoly money."),
            VerdictTemplate(template: "Big Ticket energy: {biggest_spend_amount}. Your wallet is screaming."),
        ],
        .coffeeAddict: [
            VerdictTemplate(template: "{top_category_count} coffees today. That's not a habit, it's a lifestyle."),
            VerdictTemplate(template: "At this rate, you're single-handedly funding someone's rent."),
            VerdictTemplate(template: "Your blood type is now espresso. {top_category_count} cups says so."),
        ],
        .impulseBuyer: [
            VerdictTemplate(template: "{mindless_amount} in mindless spending. Your impulse control took the day off."),
            VerdictTemplate(template: "Impulse bought your way to {mindless_amount}. Classic."),
            VerdictTemplate(template: "Your brain said yes too many times today."),
        ],
        .convenienceKing: [
            VerdictTemplate(template: "Convenience is your love language. {total} proves it."),
            VerdictTemplate(template: "Why walk when you can pay? {top_category_count} transport charges today."),
            VerdictTemplate(template: "Your legs are decorative at this point."),
        ],
        .foody: [
            VerdictTemplate(template: "{top_category_count} food purchases. Your stomach is the real boss here."),
            VerdictTemplate(template: "Ate your way through {total} today. Impressive, honestly."),
            VerdictTemplate(template: "Food spiral activated. {top_category_count} stops and counting."),
        ],
        .lowDrama: [
            VerdictTemplate(template: "Only {total} today. Almost responsible. Almost."),
            VerdictTemplate(template: "Low drama day, but we're watching you."),
            VerdictTemplate(template: "{total} spent. For once, your wallet can breathe."),
        ],
        .repeatOffender: [
            VerdictTemplate(template: "{total} spent. At this point, it's a pattern."),
            VerdictTemplate(template: "You did it again. {total} gone. Shocking absolutely no one."),
            VerdictTemplate(template: "Repeat offender status unlocked at {total}."),
        ],
        .cleanDay: [
            VerdictTemplate(template: "Zero spent. Did your wallet take the day off or did you?"),
            VerdictTemplate(template: "A clean slate. Suspicious, but we'll allow it."),
            VerdictTemplate(template: "Nothing logged. Either you're lying or you're broke."),
        ]
    ]

    // MARK: - Therapist Templates (by archetype)

    static let therapistTemplates: [SpenderArchetype: [VerdictTemplate]] = [
        .bigSpender: [
            VerdictTemplate(template: "A {biggest_spend_amount} purchase is significant. Was it planned or spontaneous?"),
            VerdictTemplate(template: "Big purchases can feel overwhelming. Take a breath."),
            VerdictTemplate(template: "Spending {total} today - let's reflect on what drove that decision."),
        ],
        .coffeeAddict: [
            VerdictTemplate(template: "{top_category_count} coffees today. What comfort are you seeking?"),
            VerdictTemplate(template: "Coffee rituals can be grounding. Are these intentional moments for you?"),
            VerdictTemplate(template: "Notice the pattern: {top_category_count} coffee stops. What need are they filling?"),
        ],
        .impulseBuyer: [
            VerdictTemplate(template: "{mindless_amount} in unplanned spending. What emotions came up before each purchase?"),
            VerdictTemplate(template: "Impulse spending often fills an emotional gap. What were you feeling?"),
            VerdictTemplate(template: "That {mindless_amount} represents moments of decision. Each one is a learning opportunity."),
        ],
        .convenienceKing: [
            VerdictTemplate(template: "Convenience spending at {total} today. Your time has value too."),
            VerdictTemplate(template: "Sometimes we pay for ease. That's okay. Just notice the pattern."),
            VerdictTemplate(template: "{top_category_count} convenience choices. What would reclaiming that time look like?"),
        ],
        .foody: [
            VerdictTemplate(template: "{top_category_count} food purchases today. Food is nourishment - emotionally too."),
            VerdictTemplate(template: "Spending {total} on food. Were these mindful meals or auto-pilot?"),
            VerdictTemplate(template: "Notice your relationship with food spending. {top_category_count} moments to explore."),
        ],
        .lowDrama: [
            VerdictTemplate(template: "A calm {total} day. Celebrate these balanced moments."),
            VerdictTemplate(template: "Low spending can feel peaceful. How does today feel for you?"),
            VerdictTemplate(template: "{total} is manageable. You're building good habits."),
        ],
        .repeatOffender: [
            VerdictTemplate(template: "Patterns repeat for a reason. What's driving today's {total}?"),
            VerdictTemplate(template: "You're here again at {total}. That awareness itself is progress."),
            VerdictTemplate(template: "Repeated patterns aren't failures - they're information."),
        ],
        .cleanDay: [
            VerdictTemplate(template: "A zero-spend day. How does that restraint feel?"),
            VerdictTemplate(template: "Nothing spent today. That takes intention. Well done."),
            VerdictTemplate(template: "Clean days create space. What will you do with it?"),
        ]
    ]

    // MARK: - Fallback Arrays (for backwards compatibility)

    static let roastVerdicts: [String] = [
        "Your bank account is filing for a restraining order.",
        "Is 'mindless spending' a competitive sport for you?",
        "You spend money like you've unlocked an infinite glitch.",
        "Your coffee habit is basically a down payment on a house you'll never own.",
        "I've seen more financial discipline from a toddler in a candy store.",
        "Your impulse control is officially set to 'not found'.",
        "If spending was an Olympic event, you'd be the GOAT. Unfortunately, it's not.",
        "Your wallet called. It wants a divorce.",
        "That 'small treat' is starting to look like a large problem.",
        "You're one more impulse buy away from needing a side hustle."
    ]

    static let therapistVerdicts: [String] = [
        "Every small step towards awareness is a victory.",
        "Be kind to yourself; today was just one day.",
        "You're learning to differentiate between needs and wants.",
        "A bad day for your wallet doesn't make you a bad person.",
        "Tomorrow is another chance to align your spending with your values.",
        "Deep breath. We're in this for the long haul.",
        "You noticed the patterns today. That's progress.",
        "Honesty is the first step toward financial peace.",
        "It's okay to indulge sometimes, as long as it's intentional.",
        "Your worth is not measured by your bank balance."
    ]
}

// MARK: - Share Verdict Library

struct ShareVerdictLibrary {

    // MARK: - Share Templates (by archetype)

    static let templates: [SpenderArchetype: [VerdictTemplate]] = [
        .bigSpender: [
            VerdictTemplate(template: "Just dropped {biggest_spend_amount}. Send help."),
            VerdictTemplate(template: "Big Ticket Day: {total} gone."),
            VerdictTemplate(template: "My wallet after today: 💀"),
        ],
        .coffeeAddict: [
            VerdictTemplate(template: "{top_category_count} coffees deep. No regrets. Maybe some regrets."),
            VerdictTemplate(template: "Coffee > Savings ({top_category_count}x today)"),
            VerdictTemplate(template: "Caffeine addiction: documented."),
        ],
        .impulseBuyer: [
            VerdictTemplate(template: "Impulse control? Never heard of her."),
            VerdictTemplate(template: "My brain said yes too many times today."),
            VerdictTemplate(template: "Mindless spending achievement unlocked."),
        ],
        .convenienceKing: [
            VerdictTemplate(template: "Paid for convenience {top_category_count} times today."),
            VerdictTemplate(template: "Walking is free. I chose violence."),
            VerdictTemplate(template: "Convenience King status: confirmed."),
        ],
        .foody: [
            VerdictTemplate(template: "{top_category_count} food stops. My stomach won."),
            VerdictTemplate(template: "Ate my way through {total} today."),
            VerdictTemplate(template: "Food spiral: engaged."),
        ],
        .lowDrama: [
            VerdictTemplate(template: "Low drama day. Surprisingly responsible."),
            VerdictTemplate(template: "Only {total} today. Who even am I?"),
            VerdictTemplate(template: "Adulting: achieved (barely)."),
        ],
        .repeatOffender: [
            VerdictTemplate(template: "{total} again. It's giving pattern."),
            VerdictTemplate(template: "Repeat offender status: unlocked."),
            VerdictTemplate(template: "Consistency is key. Even bad consistency."),
        ],
        .cleanDay: [
            VerdictTemplate(template: "Spent $0 today. Who even am I?"),
            VerdictTemplate(template: "Clean day. Screenshot for proof."),
            VerdictTemplate(template: "My wallet is confused but grateful."),
        ]
    ]

    // MARK: - Fallback Array

    static let roastVerdicts: [String] = [
        "Financial disaster in progress.",
        "I'm the problem, it's me.",
        "My impulse control is on vacation.",
        "Coffee > Savings.",
        "This is why I can't have nice things.",
        "Roasting my own finances so you don't have to.",
        "Peak mindless spending. Send help.",
        "My wallet is crying.",
        "Living life (on credit).",
        "Archetype: Financial Nightmare."
    ]
}
