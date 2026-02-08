import type { PlaybookCard } from '../types/AffordIt';

export interface PlaybookMetricsResult {
    decisionsLast7Days: number;
    delay24hPercent: number;        // 0-100, rounded integer
    averageRemainingCents: number;  // integer cents
}

const SEVEN_DAYS_MS = 7 * 24 * 60 * 60 * 1000;

/**
 * Calculate playbook metrics from an array of decisions.
 * @param cards Array of PlaybookCard decisions
 * @param now Current timestamp in ms (defaults to Date.now(), injectable for testing)
 */
export function calculatePlaybookMetrics(
    cards: PlaybookCard[],
    now: number = Date.now()
): PlaybookMetricsResult {
    const cutoff = now - SEVEN_DAYS_MS;
    const recentCards = cards.filter(card => card.createdAt >= cutoff);

    const decisionsLast7Days = recentCards.length;

    let delay24hPercent = 0;
    if (decisionsLast7Days > 0) {
        const delayCount = recentCards.filter(c => c.chosenAction === 'delay24h').length;
        delay24hPercent = Math.round((delayCount / decisionsLast7Days) * 100);
    }

    let averageRemainingCents = 0;
    if (cards.length > 0) {
        const total = cards.reduce((sum, card) => sum + card.amount, 0);
        averageRemainingCents = Math.round(total / cards.length);
    }

    return { decisionsLast7Days, delay24hPercent, averageRemainingCents };
}
