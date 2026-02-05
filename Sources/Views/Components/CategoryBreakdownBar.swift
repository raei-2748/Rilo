//
//  CategoryBreakdownBar.swift
//  Rilo
//
//  Created by Claude on 2/3/26.
//

import SwiftUI

/// A horizontal segmented bar showing spending proportions by category.
struct CategoryBreakdownBar: View {
    let breakdown: [(SpendCategory, Int)]
    var height: CGFloat
    var cornerRadius: CGFloat

    init(
        breakdown: [(SpendCategory, Int)],
        height: CGFloat = 8,
        cornerRadius: CGFloat = 4
    ) {
        self.breakdown = breakdown
        self.height = height
        self.cornerRadius = cornerRadius
    }

    private var totalCents: Int {
        breakdown.reduce(0) { $0 + $1.1 }
    }

    private var activeSegments: [(SpendCategory, Int)] {
        breakdown.filter { $0.1 > 0 }
    }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 2) {
                ForEach(Array(activeSegments.enumerated()), id: \.offset) { _, item in
                    let (category, cents) = item
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(category.barColor)
                        .frame(width: segmentWidth(cents: cents, totalWidth: geo.size.width))
                }
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.appBorder.opacity(0.5))
        )
    }

    private func segmentWidth(cents: Int, totalWidth: CGFloat) -> CGFloat {
        guard totalCents > 0 else { return 0 }
        let proportion = CGFloat(cents) / CGFloat(totalCents)
        let segmentCount = activeSegments.count
        let totalSpacing = CGFloat(max(0, segmentCount - 1)) * 2
        let availableWidth = totalWidth - totalSpacing
        return max(4, availableWidth * proportion)
    }
}

// MARK: - Category Bar Color Extension

extension SpendCategory {
    /// Color used in the category breakdown bar
    var barColor: Color {
        switch self {
        case .coffee:
            return Color(red: 0.65, green: 0.50, blue: 0.35)
        case .food:
            return BrandColors.oceanSlate
        case .transport:
            return BrandColors.softSage
        case .impulse:
            return BrandColors.impulseTaupe
        case .other:
            return BrandColors.sandTaupe
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CategoryBreakdownBar(breakdown: [
            (.coffee, 500),
            (.food, 1200),
            (.transport, 300),
            (.impulse, 800),
            (.other, 200)
        ])

        CategoryBreakdownBar(breakdown: [
            (.coffee, 1000),
            (.food, 0),
            (.transport, 0),
            (.impulse, 500),
            (.other, 0)
        ])

        CategoryBreakdownBar(breakdown: [
            (.food, 2000),
            (.coffee, 0),
            (.transport, 0),
            (.impulse, 0),
            (.other, 0)
        ])
    }
    .padding()
    .background(Color.appBackground)
}
