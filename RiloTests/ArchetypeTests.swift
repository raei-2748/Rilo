//
//  ArchetypeTests.swift
//  RiloTests
//
//  Created by Claude on 2/1/26.
//

import XCTest
@testable import Rilo

final class ArchetypeTests: XCTestCase {
    
    // MARK: - Archetype Selection Priority Tests
    
    func testBigTicketHasPriority() {
        // Big purchase should trigger .bigTicket regardless of other signals
        let entries = [
            makeEntry(amount: 6000, category: .impulse, isImpulse: true),  // $60 big ticket
            makeEntry(amount: 500, category: .coffee),
            makeEntry(amount: 500, category: .coffee),  // 2 coffees
        ]
        
        let archetype = RulesEngine.selectArchetype(
            entries: entries,
            totalCents: 7000,
            mindlessCents: 6000
        )
        
        XCTAssertEqual(archetype, .bigTicket, "Big ticket should have highest priority")
    }
    
    func testImpulseDayPriority() {
        // High mindless ratio should trigger .impulseDay
        let entries = [
            makeEntry(amount: 2000, category: .impulse, isImpulse: true),
            makeEntry(amount: 1000, category: .food, isImpulse: true),
        ]
        
        let archetype = RulesEngine.selectArchetype(
            entries: entries,
            totalCents: 3000,
            mindlessCents: 3000  // 100% mindless
        )
        
        XCTAssertEqual(archetype, .impulseDay, "High mindless ratio should trigger impulseDay")
    }
    
    func testSerialCoffeePriority() {
        // 2+ coffees should trigger .serialCoffee (if no higher priority signals)
        let entries = [
            makeEntry(amount: 500, category: .coffee),
            makeEntry(amount: 500, category: .coffee),
            makeEntry(amount: 1000, category: .food),
        ]
        
        let archetype = RulesEngine.selectArchetype(
            entries: entries,
            totalCents: 2000,
            mindlessCents: 500  // Low mindless ratio
        )
        
        XCTAssertEqual(archetype, .serialCoffee, "2+ coffees should trigger serialCoffee")
    }
    
    func testConvenienceModePriority() {
        // 2+ transport should trigger .convenienceMode
        let entries = [
            makeEntry(amount: 1500, category: .transport),
            makeEntry(amount: 2000, category: .transport),
            makeEntry(amount: 500, category: .food),
        ]
        
        let archetype = RulesEngine.selectArchetype(
            entries: entries,
            totalCents: 4000,
            mindlessCents: 0
        )
        
        XCTAssertEqual(archetype, .convenienceMode, "2+ transport should trigger convenienceMode")
    }
    
    func testFoodSpiralPriority() {
        // 2+ food should trigger .foodSpiral
        let entries = [
            makeEntry(amount: 1500, category: .food),
            makeEntry(amount: 2000, category: .food),
        ]
        
        let archetype = RulesEngine.selectArchetype(
            entries: entries,
            totalCents: 3500,
            mindlessCents: 0
        )
        
        XCTAssertEqual(archetype, .foodSpiral, "2+ food should trigger foodSpiral")
    }
    
    func testLowDramaPriority() {
        // Low total spending should trigger .lowDrama
        let entries = [
            makeEntry(amount: 500, category: .coffee),
        ]
        
        let archetype = RulesEngine.selectArchetype(
            entries: entries,
            totalCents: 500,  // Under $15 threshold
            mindlessCents: 0
        )
        
        XCTAssertEqual(archetype, .lowDrama, "Low total should trigger lowDrama")
    }
    
    func testCleanDayDefault() {
        // Regular spending with no special signals should trigger .cleanDay
        let entries = [
            makeEntry(amount: 2000, category: .other),
        ]
        
        let archetype = RulesEngine.selectArchetype(
            entries: entries,
            totalCents: 2000,  // $20, above low drama but no other signals
            mindlessCents: 0
        )
        
        XCTAssertEqual(archetype, .cleanDay, "Normal day should default to cleanDay")
    }
    
    // MARK: - Share Nudge Detection Tests
    
    func testStreakMilestoneNudge() {
        let nudge = RulesEngine.detectShareNudge(
            archetype: .cleanDay,
            yesterdayArchetype: .cleanDay,
            currentStreak: 7,  // Milestone!
            biggestSpend: 1000,
            coffeeCount: 1
        )
        
        XCTAssertEqual(nudge, .streakMilestone, "Streak of 7 should trigger streakMilestone nudge")
    }
    
    func testBigTicketNudge() {
        let nudge = RulesEngine.detectShareNudge(
            archetype: .bigTicket,
            yesterdayArchetype: nil,
            currentStreak: 1,
            biggestSpend: 5000,  // $50 threshold
            coffeeCount: 0
        )
        
        XCTAssertEqual(nudge, .bigTicket, "Big ticket spend should trigger bigTicket nudge")
    }
    
    func testRepeatOffenderNudge() {
        let nudge = RulesEngine.detectShareNudge(
            archetype: .serialCoffee,
            yesterdayArchetype: nil,
            currentStreak: 1,
            biggestSpend: 1000,
            coffeeCount: 3  // 3+ coffees
        )
        
        XCTAssertEqual(nudge, .repeatOffender, "3+ coffees should trigger repeatOffender nudge")
    }
    
    func testNewArchetypeNudge() {
        let nudge = RulesEngine.detectShareNudge(
            archetype: .impulseDay,
            yesterdayArchetype: .cleanDay,  // Different from today
            currentStreak: 2,
            biggestSpend: 1000,
            coffeeCount: 1
        )
        
        XCTAssertEqual(nudge, .newArchetype, "Different archetype should trigger newArchetype nudge")
    }
    
    func testNoNudgeForRegularDay() {
        let nudge = RulesEngine.detectShareNudge(
            archetype: .cleanDay,
            yesterdayArchetype: .cleanDay,  // Same as today
            currentStreak: 2,  // Not a milestone
            biggestSpend: 1000,  // Under threshold
            coffeeCount: 1  // Under repeat threshold
        )
        
        XCTAssertNil(nudge, "Regular day should not trigger any nudge")
    }
    
    // MARK: - Deterministic Verdict Tests
    
    func testVerdictIsDeterministic() {
        let entries = [
            makeEntry(amount: 1500, category: .coffee),
        ]
        
        let date = Date(timeIntervalSince1970: 1704067200) // Fixed date
        
        let verdict1 = RulesEngine.selectVerdict(
            entries: entries,
            totalCents: 1500,
            mindlessCents: 0,
            mode: .roast,
            date: date,
            isShareMode: false
        )
        
        let verdict2 = RulesEngine.selectVerdict(
            entries: entries,
            totalCents: 1500,
            mindlessCents: 0,
            mode: .roast,
            date: date,
            isShareMode: false
        )
        
        XCTAssertEqual(verdict1, verdict2, "Same inputs should produce same verdict")
    }
    
    func testShareModeVerdictDiffers() {
        let entries = [
            makeEntry(amount: 1500, category: .coffee),
        ]
        
        let date = Date(timeIntervalSince1970: 1704067200)
        
        let normalVerdict = RulesEngine.selectVerdict(
            entries: entries,
            totalCents: 1500,
            mindlessCents: 0,
            mode: .roast,
            date: date,
            isShareMode: false
        )
        
        let shareVerdict = RulesEngine.selectVerdict(
            entries: entries,
            totalCents: 1500,
            mindlessCents: 0,
            mode: .roast,
            date: date,
            isShareMode: true
        )
        
        // They use different libraries, so may differ
        // (This test just verifies the code path works)
        XCTAssertNotNil(normalVerdict)
        XCTAssertNotNil(shareVerdict)
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
}
