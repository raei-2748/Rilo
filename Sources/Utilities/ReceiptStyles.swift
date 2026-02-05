//
//  ReceiptStyles.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI

// MARK: - Receipt Color Palette (derived from BrandColors)

extension Color {
    /// Bone White - Primary receipt/paper background
    static let receiptBackground = BrandColors.boneWhite

    /// Slightly darker paper tone for depth
    static let receiptPaper = BrandColors.paperTint

    /// Charcoal Ink - Primary text color
    static let receiptText = BrandColors.charcoalInk

    /// Sand Taupe derived - Secondary text (darker for legibility)
    static let receiptSecondary = BrandColors.secondaryInk

    /// Tertiary/muted text
    static let receiptTertiary = BrandColors.tertiaryInk

    /// Ocean Slate - Accent color for highlights
    static let receiptAccent = BrandColors.oceanSlate

    /// Muted taupe for impulse/warning (softer than harsh orange)
    static let receiptImpulse = BrandColors.impulseTaupe

    /// Soft Sage - Success/streak color
    static let receiptStreak = BrandColors.softSage
}

// MARK: - Receipt Divider

struct ReceiptDivider: View {
    var isDashed: Bool = false
    
    var body: some View {
        if isDashed {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 1)
                .overlay(
                    GeometryReader { geo in
                        Path { path in
                            let dashWidth: CGFloat = 4
                            let gapWidth: CGFloat = 3
                            var x: CGFloat = 0
                            while x < geo.size.width {
                                path.move(to: CGPoint(x: x, y: 0.5))
                                path.addLine(to: CGPoint(x: min(x + dashWidth, geo.size.width), y: 0.5))
                                x += dashWidth + gapWidth
                            }
                        }
                        .stroke(Color.receiptSecondary.opacity(0.4), lineWidth: 1)
                    }
                )
                .padding(.vertical, 10)
        } else {
            Rectangle()
                .fill(Color.receiptSecondary.opacity(0.25))
                .frame(height: 1)
                .padding(.vertical, 10)
        }
    }
}

// MARK: - Typography Styles

struct ReceiptFont {
    /// Monospace for amounts
    static func mono(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
    
    /// Display font for headlines
    static func display(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    /// Body text
    static func body(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
    
    /// Small caps tracking
    static func smallCaps(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold).smallCaps()
    }
}

// MARK: - Receipt Shadow

extension View {
    func receiptShadow() -> some View {
        self
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            .shadow(color: .black.opacity(0.04), radius: 24, x: 0, y: 8)
    }
    
    func receiptCardStyle() -> some View {
        self
            .background(Color.receiptBackground)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .receiptShadow()
    }
}

// MARK: - Perforated Edge

struct PerforatedEdge: View {
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<30) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                Spacer()
            }
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
        }
        .frame(height: 6)
    }
}
