//
//  ReceiptLineItemView.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI

struct ReceiptLineItemView: View {
    let entry: SpendEntry
    let isAnonymized: Bool

    private var displayName: String {
        if isAnonymized {
            return entry.category.displayName
        } else {
            return entry.merchant ?? entry.category.displayName
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Category emoji
            Text(entry.category.emoji)
                .font(.system(size: 16))
            
            // Name and time
            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(ReceiptFont.body(size: 14, weight: entry.isImpulse ? .semibold : .regular))
                    .foregroundStyle(entry.isImpulse ? Color.receiptImpulse : Color.receiptText)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(ReceiptFont.mono(size: 10))
                    .foregroundStyle(Color.receiptTertiary)
            }

            Spacer()

            // Amount
            Text(entry.amountCents.formattedAsCurrency())
                .font(ReceiptFont.mono(size: 14, weight: .semibold))
                .foregroundStyle(entry.isImpulse ? Color.receiptImpulse : Color.receiptText)
        }
        .padding(.vertical, 2)
    }
}
