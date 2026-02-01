//
//  ReceiptFooterView.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI

struct ReceiptFooterView: View {
    let streakDays: Int

    var body: some View {
        VStack(spacing: 12) {
            // Streak badge (if > 1)
            if streakDays > 1 {
                HStack(spacing: 6) {
                    Text("🔥")
                        .font(.system(size: 14))
                    Text("\(streakDays) DAY STREAK")
                        .font(ReceiptFont.smallCaps(size: 10))
                        .tracking(1)
                        .foregroundStyle(Color.receiptStreak)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.receiptStreak.opacity(0.12))
                .clipShape(Capsule())
            }

            // Branding
            HStack(spacing: 4) {
                Text("🧾")
                    .font(.system(size: 11))
                Text("Rilo")
                    .font(ReceiptFont.body(size: 11, weight: .medium))
                    .tracking(0.3)
                    .foregroundStyle(Color.receiptTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
