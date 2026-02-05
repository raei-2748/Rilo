//
//  ArchetypeTests.swift
//  RiloTests
//
//  Created by Claude on 2/1/26.
//

import XCTest
@testable import Rilo

final class ArchetypeTests: XCTestCase {

    // MARK: - Archetype Determination Tests

    func testBigSpenderHasPriority() {
        // Big purchase (> $50) should trigger .bigSpender regardless of other signals
        let entries = [
            makeEntry(amount: 6000, category: .impulse, isImpulse: true),  // $60 big ticket
            makeEntry(amount: 500, category: .coffee),
            makeEntry(amount: 500, category: .coffee),
        ]
        let total = entries.reduce(0) { $0 + $1.amountCents }

        let archetype = RulesEngine.determineArchetype(entries: entries, total: total)

        XCTAssertEqual(archetype, .bigSpender, "Big ticket should have highest priority")
    }

    func testCoffeeAddictPriority() {
        // 3+ coffees should trigger .coffeeAddict
        let entries = [
            makeEntry(amount: 500, category: .coffee),
            makeEntry(amount: 500, category: .coffee),
            makeEntry(amount: 500, category: .coffee),
            makeEntry(amount: 1000, category: .food),
        ]
        let total = entries.reduce(0) { $0 + $1.amountCents }

        let archetype = RulesEngine.determineArchetype(entries: entries, total: total)

        XCTAssertEqual(archetype, .coffeeAddict, "3+ coffees should trigger coffeeAddict")
    }

    func testImpulseBuyerPriority() {
        // 2+ impulse entries should trigger .impulseBuyer
        let entries = [
            makeEntry(amount: 2000, category: .impulse, isImpulse: true),
            makeEntry(amount: 1000, category: .food, isImpulse: true),
        ]
        let total = entries.reduce(0) { $0 + $1.amountCents }

        let archetype = RulesEngine.determineArchetype(entries: entries, total: total)

        XCTAssertEqual(archetype, .impulseBuyer, "2+ impulse entries should trigger impulseBuyer")
    }

    func testConvenienceKingPriority() {
        // 2+ transport should trigger .convenienceKing
        let entries = [
            makeEntry(amount: 1500, category: .transport),
            makeEntry(amount: 2000, category: .transport),
            makeEntry(amount: 500, category: .food),
        ]
        let total = entries.reduce(0) { $0 + $1.amountCents }

        let archetype = RulesEngine.determineArchetype(entries: entries, total: total)

        XCTAssertEqual(archetype, .convenienceKing, "2+ transport should trigger convenienceKing")
    }

    func testFoodyPriority() {
        // 2+ food should trigger .foody
        let entries = [
            makeEntry(amount: 1500, category: .food),
            makeEntry(amount: 2000, category: .food),
        ]
        let total = entries.reduce(0) { $0 + $1.amountCents }

        let archetype = RulesEngine.determineArchetype(entries: entries, total: total)

        XCTAssertEqual(archetype, .foody, "2+ food should trigger foody")
    }

    func testRepeatOffenderPriority() {
        // Total > $100 should trigger .repeatOffender
        let entries = [
            makeEntry(amount: 5000, category: .other),
            makeEntry(amount: 6000, category: .other),
        ]
        let total = entries.reduce(0) { $0 + $1.amountCents }

        let archetype = RulesEngine.determineArchetype(entries: entries, total: total)

        XCTAssertEqual(archetype, .repeatOffender, "Total > $100 should trigger repeatOffender")
    }

    func testLowDramaDefault() {
        // Regular spending with no special signals should trigger .lowDrama
        let entries = [
            makeEntry(amount: 2000, category: .other),
        ]
        let total = entries.reduce(0) { $0 + $1.amountCents }

        let archetype = RulesEngine.determineArchetype(entries: entries, total: total)

        XCTAssertEqual(archetype, .lowDrama, "Normal day should default to lowDrama")
    }

    func testCleanDayForEmptyEntries() {
        let entries: [SpendEntry] = []
        let archetype = RulesEngine.determineArchetype(entries: entries, total: 0)

        XCTAssertEqual(archetype, .cleanDay, "Empty entries should return cleanDay")
    }

    // MARK: - Share Nudge Detection Tests

    func testStreakMilestoneNudge() {
        let receipt = makeReceipt(archetype: .lowDrama)
        let nudge = receipt.detectShareNudge(
            yesterdayArchetype: .lowDrama,
            currentStreak: 7
        )

        XCTAssertEqual(nudge, .streakMilestone, "Streak of 7 should trigger streakMilestone nudge")
    }

    func testBigTicketNudge() {
        let receipt = makeReceipt(archetype: .bigSpender)
        let nudge = receipt.detectShareNudge(
            yesterdayArchetype: nil,
            currentStreak: 1
        )

        XCTAssertEqual(nudge, .bigTicket, "bigSpender archetype should trigger bigTicket nudge")
    }

    func testRepeatOffenderNudge() {
        let receipt = makeReceipt(archetype: .repeatOffender)
        let nudge = receipt.detectShareNudge(
            yesterdayArchetype: nil,
            currentStreak: 1
        )

        XCTAssertEqual(nudge, .repeatOffender, "repeatOffender archetype should trigger repeatOffender nudge")
    }

    func testNewArchetypeNudge() {
        let receipt = makeReceipt(archetype: .impulseBuyer)
        let nudge = receipt.detectShareNudge(
            yesterdayArchetype: .lowDrama,
            currentStreak: 2
        )

        XCTAssertEqual(nudge, .newArchetype, "Different archetype should trigger newArchetype nudge")
    }

    func testNoNudgeForRegularDay() {
        let receipt = makeReceipt(archetype: .lowDrama)
        let nudge = receipt.detectShareNudge(
            yesterdayArchetype: .lowDrama,
            currentStreak: 2
        )

        XCTAssertNil(nudge, "Regular day should not trigger any nudge")
    }

    // MARK: - Deterministic Verdict Tests

    func testVerdictIsDeterministic() {
        let fixedDate = Date(timeIntervalSince1970: 1704067200)
        let fixedId = UUID(uuidString: "12345678-1234-1234-1234-123456789012")!

        let receipt1 = DailyReceipt(
            id: fixedId,
            date: fixedDate,
            entries: [makeEntry(amount: 1500, category: .coffee)],
            mode: .roast,
            archetype: .lowDrama,
            totalCents: 1500,
            mindlessCents: 0,
            biggestSpend: nil,
            countByCategory: [.coffee: 1]
        )

        let receipt2 = DailyReceipt(
            id: fixedId,
            date: fixedDate,
            entries: [makeEntry(amount: 1500, category: .coffee)],
            mode: .roast,
            archetype: .lowDrama,
            totalCents: 1500,
            mindlessCents: 0,
            biggestSpend: nil,
            countByCategory: [.coffee: 1]
        )

        let verdict1 = RulesEngine.selectVerdict(receipt: receipt1, isShareMode: false)
        let verdict2 = RulesEngine.selectVerdict(receipt: receipt2, isShareMode: false)

        XCTAssertEqual(verdict1, verdict2, "Same inputs should produce same verdict")
    }

    func testShareModeVerdictWorks() {
        let receipt = makeReceipt(archetype: .coffeeAddict)

        let normalVerdict = RulesEngine.selectVerdict(receipt: receipt, isShareMode: false)
        let shareVerdict = RulesEngine.selectVerdict(receipt: receipt, isShareMode: true)

        XCTAssertFalse(normalVerdict.isEmpty, "Normal verdict should not be empty")
        XCTAssertFalse(shareVerdict.isEmpty, "Share verdict should not be empty")
    }

    // MARK: - Template Rendering Tests

    func testTemplateRenderingAllValuesPresent() {
        let context = VerdictTemplateContext(
            totalCents: 12345,
            mindlessCents: 678,
            biggestSpendName: "Coffee Hut",
            biggestSpendAmountCents: 4500,
            topCategoryName: "Coffee",
            topCategoryAmountCents: 1500,
            topCategoryCount: 3,
            streakDays: 5,
            yesterdayArchetype: .lowDrama
        )

        let template = "Total {total}, biggest {biggest_spend_amount} at {biggest_spend_name}, top {top_category_name} {top_category_amount}, streak {streak_days}, yesterday {yesterday_archetype}."
        let result = VerdictTemplateRenderer.render(template: template, context: context)

        XCTAssertTrue(result.contains("$123.45"))
        XCTAssertTrue(result.contains("$45.00"))
        XCTAssertTrue(result.contains("Coffee Hut"))
        XCTAssertTrue(result.contains("Coffee"))
        XCTAssertTrue(result.contains("$15.00"))
        XCTAssertTrue(result.contains("5"))
        XCTAssertTrue(result.contains("low drama"))
        XCTAssertFalse(result.contains("{"))
        XCTAssertFalse(result.contains("Optional("))
    }

    func testTemplateRenderingMissingBiggestSpend() {
        let context = VerdictTemplateContext(
            totalCents: 5000,
            mindlessCents: 0,
            biggestSpendName: nil,
            biggestSpendAmountCents: nil,
            topCategoryName: "Food",
            topCategoryAmountCents: 5000,
            topCategoryCount: 2,
            streakDays: nil,
            yesterdayArchetype: .foody
        )

        let template = "Biggest was {biggest_spend_amount} at {biggest_spend_name}."
        let result = VerdictTemplateRenderer.render(template: template, context: context)

        XCTAssertTrue(result.contains("something small"))
        XCTAssertTrue(result.contains("a small amount"))
        XCTAssertFalse(result.contains("{"))
        XCTAssertFalse(result.contains("Optional("))
    }

    func testTemplateRenderingMissingTopCategory() {
        let context = VerdictTemplateContext(
            totalCents: 5000,
            mindlessCents: 0,
            biggestSpendName: "Market",
            biggestSpendAmountCents: 5000,
            topCategoryName: nil,
            topCategoryAmountCents: nil,
            topCategoryCount: nil,
            streakDays: 2,
            yesterdayArchetype: .lowDrama
        )

        let template = "Top category was {top_category_name} for {top_category_amount}."
        let result = VerdictTemplateRenderer.render(template: template, context: context)

        XCTAssertTrue(result.contains("something"))
        XCTAssertTrue(result.contains("a small amount"))
        XCTAssertFalse(result.contains("{"))
        XCTAssertFalse(result.contains("Optional("))
    }

    func testTemplateRenderingMissingYesterdayArchetype() {
        let context = VerdictTemplateContext(
            totalCents: 5000,
            mindlessCents: 0,
            biggestSpendName: "Market",
            biggestSpendAmountCents: 5000,
            topCategoryName: "Food",
            topCategoryAmountCents: 5000,
            topCategoryCount: 2,
            streakDays: 2,
            yesterdayArchetype: nil
        )

        let template = "Yesterday was {yesterday_archetype}."
        let result = VerdictTemplateRenderer.render(template: template, context: context)

        XCTAssertFalse(result.contains("{"))
        XCTAssertFalse(result.contains("Optional("))
        XCTAssertFalse(result.contains("  "))
    }

    func testTemplateTopCategoryTieBreakUsesCategoryOrder() {
        let entries = [
            makeEntry(amount: 500, category: .coffee),
            makeEntry(amount: 500, category: .food)
        ]
        let total = entries.reduce(0) { $0 + $1.amountCents }
        let receipt = DailyReceipt(
            date: Date(),
            entries: entries,
            mode: .roast,
            archetype: .lowDrama,
            totalCents: total,
            mindlessCents: 0,
            biggestSpend: nil,
            countByCategory: RulesEngine.getCategoryCounts(entries: entries)
        )

        let context = VerdictTemplateContext.from(receipt: receipt)

        XCTAssertEqual(context.topCategoryName, "Coffee")
    }

    // MARK: - Mindless Cents Tests

    func testMindlessCentsIncludesImpulse() {
        let entries = [
            makeEntry(amount: 1000, category: .food, isImpulse: true),
            makeEntry(amount: 2000, category: .other),
        ]

        let mindless = RulesEngine.computeMindlessCents(entries: entries)

        XCTAssertEqual(mindless, 1000, "Mindless should include impulse entries")
    }

    func testMindlessCentsSerialCategoryIneligibleDoesNotCount() {
        let entries = [
            makeEntry(amount: 1000, category: .other),
            makeEntry(amount: 1000, category: .other),
            makeEntry(amount: 1000, category: .other)
        ]

        let mindless = RulesEngine.computeMindlessCents(entries: entries)

        XCTAssertEqual(mindless, 0, "Serial categories outside eligibility should not count")
    }

    func testMindlessCentsSerialCategoryCapBoundary() {
        let entries = [
            makeEntry(amount: 2000, category: .coffee),
            makeEntry(amount: 2000, category: .coffee),
            makeEntry(amount: 2000, category: .coffee)
        ]

        let mindless = RulesEngine.computeMindlessCents(entries: entries)

        XCTAssertEqual(mindless, 6000, "Amounts at the cap should count for serial categories")
    }

    func testMindlessCentsImpulseOverridesSerialCap() {
        let entries = [
            makeEntry(amount: 2500, category: .coffee),
            makeEntry(amount: 2500, category: .coffee),
            makeEntry(amount: 2500, category: .coffee),
            makeEntry(amount: 5000, category: .other, isImpulse: true)
        ]

        let mindless = RulesEngine.computeMindlessCents(entries: entries)

        XCTAssertEqual(mindless, 5000, "Impulse entries should count even if above cap or ineligible")
    }

    func testMindlessCentsEmptyEntries() {
        let entries: [SpendEntry] = []
        let mindless = RulesEngine.computeMindlessCents(entries: entries)

        XCTAssertEqual(mindless, 0, "Empty entries should return 0 mindless")
    }

    // MARK: - Helpers

    private func makeEntry(
        amount: Int,
        category: SpendCategory,
        isImpulse: Bool = false
    ) -> SpendEntry {
        SpendEntry(
            timestamp: Date(),
            amountCents: amount,
            merchant: nil,
            category: category,
            isImpulse: isImpulse
        )
    }

    private func makeReceipt(archetype: SpenderArchetype) -> DailyReceipt {
        DailyReceipt(
            date: Date(),
            entries: [],
            mode: .roast,
            archetype: archetype,
            totalCents: 0,
            mindlessCents: 0,
            biggestSpend: nil,
            countByCategory: [:]
        )
    }
}
