import { calculatePlaybookMetrics } from '../src/core/PlaybookMetrics';
import type { PlaybookCard } from '../src/types/AffordIt';

describe('PlaybookMetrics', () => {
    // Helper to create a card with defaults
    function createCard(overrides: Partial<PlaybookCard>): PlaybookCard {
        return {
            id: 'test-id',
            createdAt: Date.now(),
            label: 'Test Item',
            category: 'nonEssential',
            amount: 5000, // $50.00
            chosenAction: 'proceed',
            stressReduction: 2,
            helpTags: [],
            isPinned: false,
            ...overrides,
        };
    }

    describe('calculatePlaybookMetrics', () => {
        // Fixed "now" timestamp for deterministic tests
        const NOW = 1700000000000; // Nov 14, 2023
        const ONE_DAY = 24 * 60 * 60 * 1000;
        const SEVEN_DAYS = 7 * ONE_DAY;

        it('should return zeros for empty cards array', () => {
            const result = calculatePlaybookMetrics([], NOW);

            expect(result.decisionsLast7Days).toBe(0);
            expect(result.delay24hPercent).toBe(0);
            expect(result.averageRemainingCents).toBe(0);
        });

        it('should calculate metrics correctly with mixed data', () => {
            // 5 cards total: 4 within 7 days, 1 older
            // Actions: 2 delay24h (recent), 1 proceed, 1 bufferFirst, 1 delay24h (old)
            const cards: PlaybookCard[] = [
                createCard({
                    id: '1',
                    createdAt: NOW - ONE_DAY,        // 1 day ago - recent
                    chosenAction: 'delay24h',
                    amount: 2500,                     // $25.00
                }),
                createCard({
                    id: '2',
                    createdAt: NOW - (2 * ONE_DAY),  // 2 days ago - recent
                    chosenAction: 'proceed',
                    amount: 7500,                     // $75.00
                }),
                createCard({
                    id: '3',
                    createdAt: NOW - (3 * ONE_DAY),  // 3 days ago - recent
                    chosenAction: 'delay24h',
                    amount: 5000,                     // $50.00
                }),
                createCard({
                    id: '4',
                    createdAt: NOW - (6 * ONE_DAY),  // 6 days ago - still within 7
                    chosenAction: 'bufferFirst',
                    amount: 10000,                    // $100.00
                }),
                // Old card - outside 7 days, should be excluded from recent count
                createCard({
                    id: '5',
                    createdAt: NOW - (10 * ONE_DAY), // 10 days ago - OLD
                    chosenAction: 'delay24h',
                    amount: 15000,                    // $150.00
                }),
            ];

            const result = calculatePlaybookMetrics(cards, NOW);

            // 4 decisions in last 7 days (cards 1-4, not card 5)
            expect(result.decisionsLast7Days).toBe(4);

            // 2 delay24h out of 4 recent = 50%
            expect(result.delay24hPercent).toBe(50);

            // Average of ALL 5 cards: (2500+7500+5000+10000+15000)/5 = 40000/5 = 8000
            expect(result.averageRemainingCents).toBe(8000);
        });

        it('should round delay percentage correctly', () => {
            const cards: PlaybookCard[] = [
                createCard({ id: '1', createdAt: NOW - ONE_DAY, chosenAction: 'delay24h' }),
                createCard({ id: '2', createdAt: NOW - ONE_DAY, chosenAction: 'proceed' }),
                createCard({ id: '3', createdAt: NOW - ONE_DAY, chosenAction: 'proceed' }),
            ];

            const result = calculatePlaybookMetrics(cards, NOW);

            // 1 out of 3 = 33.33...% -> rounds to 33
            expect(result.delay24hPercent).toBe(33);
        });

        it('should handle cards exactly at 7-day boundary', () => {
            const cards: PlaybookCard[] = [
                createCard({
                    id: '1',
                    createdAt: NOW - SEVEN_DAYS,     // Exactly 7 days ago (included: >= cutoff)
                    chosenAction: 'swap',
                    amount: 3000,
                }),
                createCard({
                    id: '2',
                    createdAt: NOW - SEVEN_DAYS - 1, // Just over 7 days (excluded: < cutoff)
                    chosenAction: 'delay24h',
                    amount: 4000,
                }),
            ];

            const result = calculatePlaybookMetrics(cards, NOW);

            // Only card 1 is within 7 days (>= cutoff)
            expect(result.decisionsLast7Days).toBe(1);
            expect(result.delay24hPercent).toBe(0); // No delay24h in recent
            // Average of both cards: (3000+4000)/2 = 3500
            expect(result.averageRemainingCents).toBe(3500);
        });

        it('should handle 100% delay rate', () => {
            const cards: PlaybookCard[] = [
                createCard({ id: '1', createdAt: NOW, chosenAction: 'delay24h' }),
                createCard({ id: '2', createdAt: NOW, chosenAction: 'delay24h' }),
            ];

            const result = calculatePlaybookMetrics(cards, NOW);

            expect(result.delay24hPercent).toBe(100);
        });

        it('should round average cents to integer', () => {
            const cards: PlaybookCard[] = [
                createCard({ id: '1', createdAt: NOW, amount: 100 }),
                createCard({ id: '2', createdAt: NOW, amount: 200 }),
                createCard({ id: '3', createdAt: NOW, amount: 301 }), // Creates non-integer average
            ];

            const result = calculatePlaybookMetrics(cards, NOW);

            // (100+200+301)/3 = 200.33... -> rounds to 200
            expect(result.averageRemainingCents).toBe(200);
        });
    });
});
