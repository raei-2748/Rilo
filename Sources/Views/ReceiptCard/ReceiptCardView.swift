//
//  ReceiptCardView.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI

struct ReceiptCardView: View {
    let receipt: DailyReceipt
    let isAnonymized: Bool
    let streakDays: Int
    let isExportMode: Bool
    
    init(
        receipt: DailyReceipt,
        isAnonymized: Bool = false,
        streakDays: Int = 1,
        isExportMode: Bool = false
    ) {
        self.receipt = receipt
        self.isAnonymized = isAnonymized
        self.streakDays = streakDays
        self.isExportMode = isExportMode
    }

    var body: some View {
        VStack(spacing: 0) {
            // Perforated top
            if isExportMode {
                PerforatedEdge()
                    .padding(.bottom, -3)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 20)
                
                ReceiptHeaderView(
                    date: receipt.date,
                    mode: receipt.mode,
                    archetype: receipt.archetype
                )

                ReceiptDivider(isDashed: true)
                    .padding(.horizontal, 4)

                // Items section
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(receipt.entries) { entry in
                        ReceiptLineItemView(
                            entry: entry,
                            isAnonymized: isAnonymized
                        )
                    }
                }
                .padding(.vertical, 12)

                ReceiptDivider(isDashed: true)
                    .padding(.horizontal, 4)

                ReceiptTotalsView(
                    totalCents: receipt.totalCents,
                    mindlessCents: receipt.mindlessCents,
                    biggestSpend: receipt.biggestSpend,
                    isAnonymized: isAnonymized
                )

                ReceiptDivider()
                    .padding(.horizontal, 4)

                ReceiptVerdictView(verdict: receipt.verdictLine)

                Spacer().frame(height: 16)

                ReceiptFooterView(streakDays: streakDays)
                
                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 24)
            
            // Perforated bottom
            if isExportMode {
                PerforatedEdge()
                    .padding(.top, -3)
            }
        }
        .frame(width: 375)
        .background(
            ZStack {
                Color.receiptBackground
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.2),
                        Color.clear,
                        Color.receiptPaper.opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: isExportMode ? 0 : 8))
        .receiptShadow()
    }
}

#Preview {
    ScrollView {
        ReceiptCardView(receipt: SeedData.coffeeAddict, streakDays: 5)
            .padding()
    }
    .background(Color.gray.opacity(0.15))
}
