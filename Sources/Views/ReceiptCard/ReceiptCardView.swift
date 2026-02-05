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
    var maxWidth: CGFloat?

    init(
        receipt: DailyReceipt,
        isAnonymized: Bool = false,
        streakDays: Int = 1,
        isExportMode: Bool = false,
        maxWidth: CGFloat? = nil
    ) {
        self.receipt = receipt
        self.isAnonymized = isAnonymized
        self.streakDays = streakDays
        self.isExportMode = isExportMode
        self.maxWidth = maxWidth
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
        .frame(maxWidth: maxWidth ?? .infinity)
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

                // Paper texture (only in non-export mode for performance)
                if !isExportMode {
                    PaperTextureOverlay()
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: isExportMode ? 0 : 12))
        .receiptShadow()
    }
}

// MARK: - Paper Texture Overlay

/// A subtle paper texture overlay using Canvas for a premium feel
struct PaperTextureOverlay: View {
    var body: some View {
        Canvas { context, size in
            // Create a subtle noise pattern with diagonal grain
            let seed = 42 // Fixed seed for deterministic rendering
            var rng = SeededRandomNumberGenerator(seed: UInt64(seed))

            // Subtle diagonal lines for paper grain
            for i in stride(from: 0, to: Int(size.width + size.height), by: 8) {
                let startX = CGFloat(i)
                let startY: CGFloat = 0
                let endX: CGFloat = 0
                let endY = CGFloat(i)

                var path = Path()
                path.move(to: CGPoint(x: startX, y: startY))
                path.addLine(to: CGPoint(x: endX, y: endY))

                let opacity = Double.random(in: 0.01...0.02, using: &rng)
                context.stroke(
                    path,
                    with: .color(Color.black.opacity(opacity)),
                    lineWidth: 0.5
                )
            }

            // Sparse dots for texture
            for _ in 0..<80 {
                let x = CGFloat.random(in: 0...size.width, using: &rng)
                let y = CGFloat.random(in: 0...size.height, using: &rng)
                let opacity = Double.random(in: 0.015...0.035, using: &rng)
                let dotSize = CGFloat.random(in: 0.5...1.5, using: &rng)

                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
                    with: .color(Color.black.opacity(opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Seeded Random Number Generator

/// A simple seeded random number generator for deterministic texture rendering
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // Simple xorshift algorithm
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ReceiptCardView(
                receipt: SeedData.coffeeAddict,
                streakDays: 5,
                maxWidth: 375
            )

            ReceiptCardView(
                receipt: SeedData.coffeeAddict,
                streakDays: 5,
                maxWidth: 320
            )
        }
        .padding()
    }
    .background(Color.appBackground)
}
