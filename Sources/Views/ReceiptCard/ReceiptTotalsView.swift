//
//  ReceiptTotalsView.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI

struct ReceiptTotalsView: View {
    let totalCents: Int
    let mindlessCents: Int
    let biggestSpend: SpendEntry?
    let isAnonymized: Bool
    
    init(
        totalCents: Int,
        mindlessCents: Int,
        biggestSpend: SpendEntry?,
        isAnonymized: Bool = false
    ) {
        self.totalCents = totalCents
        self.mindlessCents = mindlessCents
        self.biggestSpend = biggestSpend
        self.isAnonymized = isAnonymized
    }

    var body: some View {
        VStack(spacing: 12) {
            // Hero total
            HStack {
                Text("TOTAL")
                    .font(ReceiptFont.smallCaps(size: 12))
                    .foregroundStyle(Color.receiptSecondary)
                Spacer()
                Text(totalCents.formattedAsCurrency())
                    .font(ReceiptFont.mono(size: 24, weight: .bold))
                    .foregroundStyle(Color.receiptText)
            }
            
            // Mindless
            if mindlessCents > 0 {
                HStack {
                    Text("MINDLESS")
                        .font(ReceiptFont.smallCaps(size: 10))
                        .foregroundStyle(Color.receiptTertiary)
                    Spacer()
                    Text(mindlessCents.formattedAsCurrency())
                        .font(ReceiptFont.mono(size: 14, weight: .medium))
                        .foregroundStyle(Color.receiptImpulse.opacity(0.85))
                }
            }

            // Biggest regret
            if let biggest = biggestSpend {
                HStack {
                    Text("BIGGEST")
                        .font(ReceiptFont.smallCaps(size: 10))
                        .foregroundStyle(Color.receiptTertiary)
                    Spacer()
                    Text(isAnonymized ? biggest.category.displayName : (biggest.merchant ?? biggest.category.displayName))
                        .font(ReceiptFont.body(size: 12))
                        .foregroundStyle(Color.receiptSecondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 12)
    }
}
