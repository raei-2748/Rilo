//
//  ReceiptHeaderView.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI

struct ReceiptHeaderView: View {
    let date: Date
    let mode: ReceiptMode
    let archetype: SpenderArchetype?
    
    init(date: Date, mode: ReceiptMode, archetype: SpenderArchetype? = nil) {
        self.date = date
        self.mode = mode
        self.archetype = archetype
    }

    private var title: String {
        mode == .roast ? "ROAST RECEIPT" : "THERAPY RECEIPT"
    }

    var body: some View {
        VStack(spacing: 10) {
            // App title (subtle, small caps)
            Text(title)
                .font(ReceiptFont.smallCaps(size: 10))
                .tracking(2.5)
                .foregroundStyle(Color.receiptTertiary)
            
            // Archetype headline (HERO)
            if let archetype = archetype {
                Text(archetype.headline)
                    .font(ReceiptFont.display(size: 26))
                    .foregroundStyle(Color.receiptText)
                    .multilineTextAlignment(.center)
            }

            // Date (monospace)
            Text(date.receiptDateString().uppercased())
                .font(ReceiptFont.mono(size: 10, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(Color.receiptSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 12)
    }
}

#Preview {
    ReceiptHeaderView(
        date: Date(),
        mode: .roast,
        archetype: .coffeeAddict
    )
    .padding()
    .background(Color.receiptBackground)
}
