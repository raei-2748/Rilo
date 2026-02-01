//
//  MicroFeedbackView.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI

struct MicroFeedbackView: View {
    let message: String
    let subMessage: String?
    
    var body: some View {
        VStack(spacing: 4) {
            Text(message)
                .font(ReceiptFont.body(size: 14, weight: .bold))
                .foregroundStyle(.white)
            
            if let sub = subMessage {
                Text(sub)
                    .font(ReceiptFont.body(size: 11))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.receiptText)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .receiptShadow()
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        MicroFeedbackView(
            message: "Logged. Today total: $15.40",
            subMessage: "That's 3 coffees today. Just saying."
        )
    }
}
