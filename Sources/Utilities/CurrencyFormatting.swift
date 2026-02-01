import Foundation

extension Int {
    /// Formats integer cents as a localized currency string
    func formattedAsCurrency(locale: Locale = .current) -> String {
        let dollars = Double(self) / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: NSNumber(value: dollars)) ?? String(format: "$%.2f", dollars)
    }
}
