import type { AffordItInput, AffordItResult, AffordItAction } from '../types/AffordIt';

/**
 * Calculate safe-to-spend amount.
 * Simple MVP formula: balance - buffer
 */
export function calculateSafeToSpend(balance: number, buffer: number): number {
  return balance - buffer;
}

/**
 * Recommend action based on remaining balance after purchase.
 */
export function recommendAction(input: AffordItInput): AffordItResult {
  const { amount, balance, buffer } = input;

  const safeToSpend = calculateSafeToSpend(balance, buffer);
  const remainingAfterPurchase = safeToSpend - amount;

  // Swap suggestion: max affordable while keeping buffer
  const swapSuggestion = Math.max(0, safeToSpend - buffer);

  let recommendedAction: AffordItAction;
  let alternateActions: AffordItAction[];

  if (remainingAfterPurchase < 0) {
    // Can't afford it - over safe-to-spend
    recommendedAction = 'delay24h';
    alternateActions = ['swap', 'bufferFirst'];
  } else if (remainingAfterPurchase < buffer) {
    // Can afford but will dip into buffer zone
    recommendedAction = 'bufferFirst';
    alternateActions = ['swap', 'delay24h'];
  } else {
    // Can afford safely
    recommendedAction = 'proceed';
    alternateActions = ['delay24h', 'bufferFirst'];
  }

  return {
    safeToSpend,
    remainingAfterPurchase,
    recommendedAction,
    alternateActions,
    swapSuggestion,
  };
}
