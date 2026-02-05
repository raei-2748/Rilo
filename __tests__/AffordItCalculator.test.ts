import {
  calculateSafeToSpend,
  recommendAction,
} from '../src/core/AffordItCalculator';

describe('AffordItCalculator', () => {
  describe('calculateSafeToSpend', () => {
    it('should subtract buffer from balance', () => {
      // $500 balance, $200 buffer = $300 safe-to-spend
      expect(calculateSafeToSpend(50000, 20000)).toBe(30000);
    });

    it('should handle edge cases', () => {
      // Balance equals buffer
      expect(calculateSafeToSpend(20000, 20000)).toBe(0);
      // Balance less than buffer (negative result)
      expect(calculateSafeToSpend(10000, 20000)).toBe(-10000);
    });
  });

  describe('recommendAction', () => {
    it('should recommend Proceed when remaining exceeds buffer', () => {
      const result = recommendAction({
        amount: 5000, // $50
        balance: 50000, // $500
        buffer: 20000, // $200
      });
      // safeToSpend = 30000, remaining = 25000 (> buffer of 20000)
      expect(result.safeToSpend).toBe(30000);
      expect(result.remainingAfterPurchase).toBe(25000);
      expect(result.recommendedAction).toBe('proceed');
      expect(result.alternateActions).toContain('delay24h');
      expect(result.alternateActions).toContain('bufferFirst');
    });

    it('should recommend Delay24h when purchase exceeds safe-to-spend', () => {
      const result = recommendAction({
        amount: 35000, // $350
        balance: 50000, // $500
        buffer: 20000, // $200
      });
      // safeToSpend = 30000, remaining = -5000 (< 0)
      expect(result.safeToSpend).toBe(30000);
      expect(result.remainingAfterPurchase).toBe(-5000);
      expect(result.recommendedAction).toBe('delay24h');
      expect(result.alternateActions).toContain('swap');
      expect(result.alternateActions).toContain('bufferFirst');
    });

    it('should recommend BufferFirst when remaining is positive but below buffer', () => {
      const result = recommendAction({
        amount: 20000, // $200
        balance: 50000, // $500
        buffer: 20000, // $200
      });
      // safeToSpend = 30000, remaining = 10000 (0 < remaining < buffer)
      expect(result.safeToSpend).toBe(30000);
      expect(result.remainingAfterPurchase).toBe(10000);
      expect(result.recommendedAction).toBe('bufferFirst');
      expect(result.alternateActions).toContain('swap');
      expect(result.alternateActions).toContain('delay24h');
    });

    it('should calculate correct swap suggestion', () => {
      const result = recommendAction({
        amount: 35000,
        balance: 50000,
        buffer: 20000,
      });
      // swapSuggestion = max(0, safeToSpend - buffer) = max(0, 30000 - 20000) = 10000
      expect(result.swapSuggestion).toBe(10000);
    });
  });
});
