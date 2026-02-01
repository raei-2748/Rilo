//
//  ReceiptVerdictView.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI

struct ReceiptVerdictView: View {
    let verdict: String

    var body: some View {
        VStack(spacing: 4) {
            // Opening quotation mark
            Text("\"")
                .font(.system(size: 28, weight: .ultraLight, design: .serif))
                .foregroundStyle(Color.receiptTertiary)
                .offset(y: 6)
            
            // Verdict text
            Text(verdict)
                .font(ReceiptFont.body(size: 15, weight: .medium))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .foregroundStyle(Color.receiptText)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}
