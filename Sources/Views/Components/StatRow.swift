//
//  StatRow.swift
//  Rilo
//
//  Created by Claude on 2/3/26.
//

import SwiftUI

/// A row displaying a label and monospaced value, ideal for statistics and key numbers.
struct StatRow: View {
    let label: String
    let value: String
    var valueColor: Color
    var labelFont: Font
    var valueFont: Font

    init(
        label: String,
        value: String,
        valueColor: Color = .appText,
        labelFont: Font = ReceiptFont.smallCaps(size: 11),
        valueFont: Font = ReceiptFont.mono(size: 14, weight: .semibold)
    ) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
        self.labelFont = labelFont
        self.valueFont = valueFont
    }

    var body: some View {
        HStack {
            Text(label)
                .font(labelFont)
                .foregroundStyle(Color.appTertiary)
            Spacer()
            Text(value)
                .font(valueFont)
                .foregroundStyle(valueColor)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        StatRow(label: "TOTAL", value: "$42.50")
        StatRow(label: "IMPULSE SPENDING", value: "$12.00", valueColor: .appWarning)
        StatRow(label: "STREAK", value: "7 days", valueColor: .appSuccess)
    }
    .padding()
    .background(Color.appBackground)
}
