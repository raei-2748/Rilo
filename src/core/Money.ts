/**
 * Parse a dollar string to cents (integer).
 * Handles: "25", "25.00", "$25.50", "1,234.56"
 */
export function parseDollarsToCents(input: string): number {
    const cleaned = input.replace(/[$,]/g, '').trim();
    const parsed = parseFloat(cleaned);

    if (isNaN(parsed)) {
        return 0;
    }

    return Math.round(parsed * 100);
}

/**
 * Format cents to a dollar display string.
 * 2500 -> "$25.00"
 * -500 -> "-$5.00"
 */
export function formatCentsToDollars(cents: number): string {
    const isNegative = cents < 0;
    const absCents = Math.abs(cents);
    const dollars = (absCents / 100).toFixed(2);

    return isNegative ? `-$${dollars}` : `$${dollars}`;
}

/**
 * Format cents to a simple number string for input fields.
 * 2500 -> "25.00"
 */
export function formatCentsToInput(cents: number): string {
    return (cents / 100).toFixed(2);
}
