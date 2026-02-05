import {
  parseDollarsToCents,
  formatCentsToDollars,
} from '../src/core/Money';

describe('Money utilities', () => {
  describe('parseDollarsToCents', () => {
    it('should parse simple dollar amounts', () => {
      expect(parseDollarsToCents('25')).toBe(2500);
      expect(parseDollarsToCents('25.00')).toBe(2500);
      expect(parseDollarsToCents('25.50')).toBe(2550);
      expect(parseDollarsToCents('0.99')).toBe(99);
    });

    it('should handle currency symbols and commas', () => {
      expect(parseDollarsToCents('$25.50')).toBe(2550);
      expect(parseDollarsToCents('$1,234.56')).toBe(123456);
      expect(parseDollarsToCents('')).toBe(0);
      expect(parseDollarsToCents('invalid')).toBe(0);
      expect(parseDollarsToCents('  $50  ')).toBe(5000);
    });
  });

  describe('formatCentsToDollars', () => {
    it('should format positive amounts', () => {
      expect(formatCentsToDollars(2500)).toBe('$25.00');
      expect(formatCentsToDollars(2550)).toBe('$25.50');
      expect(formatCentsToDollars(0)).toBe('$0.00');
      expect(formatCentsToDollars(99)).toBe('$0.99');
    });

    it('should format negative amounts', () => {
      expect(formatCentsToDollars(-500)).toBe('-$5.00');
      expect(formatCentsToDollars(-2550)).toBe('-$25.50');
    });
  });
});
