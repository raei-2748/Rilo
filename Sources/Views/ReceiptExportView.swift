//
//  ReceiptExportView.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI

/// Dedicated view for receipt export with fixed sizing
/// Optimized for social sharing with premium visual treatment
struct ReceiptExportView: View {
    let receipt: DailyReceipt
    let style: ReceiptRenderStyle
    let streakDays: Int
    
    /// Fixed export width (540 × 2 = 1080 at 2x)
    private let exportWidth: CGFloat = 540
    
    var body: some View {
        VStack(spacing: 0) {
            // Perforated top edge effect
            PerforatedEdge()
                .opacity(0.8)
            
            VStack(spacing: 0) {
                Spacer().frame(height: 32)
                
                // Header with archetype
                exportHeader
                
                Spacer().frame(height: 20)
                
                ReceiptDivider(isDashed: true)
                    .padding(.horizontal, 32)
                
                // Line Items
                exportLineItems
                
                ReceiptDivider(isDashed: true)
                    .padding(.horizontal, 32)
                
                // Totals
                exportTotals
                
                ReceiptDivider()
                    .padding(.horizontal, 32)
                
                // Verdict (prominent)
                exportVerdict
                
                Spacer().frame(height: 24)
                
                // Footer
                exportFooter
                
                Spacer().frame(height: 32)
            }
            
            // Perforated bottom edge
            PerforatedEdge()
                .opacity(0.8)
        }
        .frame(width: exportWidth)
        .background(
            ZStack {
                Color.receiptBackground
                
                // Subtle paper texture gradient
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.3),
                        Color.clear,
                        Color.receiptPaper.opacity(0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
    }
    
    // MARK: - Header
    
    private var exportHeader: some View {
        VStack(spacing: 12) {
            // App title (subtle)
            Text(receipt.mode == .roast ? "ROAST RECEIPT" : "THERAPY RECEIPT")
                .font(ReceiptFont.smallCaps(size: 11))
                .tracking(3)
                .foregroundStyle(Color.receiptTertiary)
            
            // Archetype headline (HERO)
            Text(receipt.archetype.headline)
                .font(ReceiptFont.display(size: 34))
                .foregroundStyle(Color.receiptText)
                .multilineTextAlignment(.center)
            
            // Date
            Text(receipt.date.receiptDateString().uppercased())
                .font(ReceiptFont.mono(size: 11, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(Color.receiptSecondary)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Line Items
    
    private var exportLineItems: some View {
        let displayEntries = Array(receipt.entries.prefix(style.maxLineItems))
        let remainingCount = receipt.entries.count - displayEntries.count
        
        return VStack(spacing: 10) {
            ForEach(displayEntries) { entry in
                exportLineItem(entry: entry)
            }
            
            if remainingCount > 0 {
                HStack {
                    Text("+ \(remainingCount) more items")
                        .font(ReceiptFont.body(size: 13))
                        .foregroundStyle(Color.receiptTertiary)
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }
    
    private func exportLineItem(entry: SpendEntry) -> some View {
        HStack(alignment: .center, spacing: 8) {
            // Category emoji
            Text(entry.category.emoji)
                .font(.system(size: 16))
            
            // Name
            Text(displayName(for: entry))
                .font(ReceiptFont.body(size: 14, weight: entry.isImpulse ? .semibold : .regular))
                .foregroundStyle(entry.isImpulse ? Color.receiptImpulse : Color.receiptText)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
            
            // Amount
            Text(formattedAmount(entry.amountCents))
                .font(ReceiptFont.mono(size: 14, weight: .semibold))
                .foregroundStyle(entry.isImpulse ? Color.receiptImpulse : Color.receiptText)
        }
    }
    
    private func displayName(for entry: SpendEntry) -> String {
        if style.hidesMerchantNames {
            return entry.category.displayName
        }
        return entry.merchant ?? entry.category.displayName
    }
    
    private func formattedAmount(_ cents: Int) -> String {
        if style.roundsAmounts {
            let dollars = (cents + 50) / 100
            return "$\(dollars)"
        }
        return cents.formattedAsCurrency()
    }
    
    // MARK: - Totals
    
    private var exportTotals: some View {
        VStack(spacing: 12) {
            // Total (hero number)
            HStack {
                Text("TOTAL")
                    .font(ReceiptFont.smallCaps(size: 12))
                    .foregroundStyle(Color.receiptSecondary)
                Spacer()
                Text(formattedAmount(receipt.totalCents))
                    .font(ReceiptFont.mono(size: 28, weight: .bold))
                    .foregroundStyle(Color.receiptText)
            }
            
            // Mindless
            if receipt.mindlessCents > 0 {
                HStack {
                    Text("MINDLESS")
                        .font(ReceiptFont.smallCaps(size: 11))
                        .foregroundStyle(Color.receiptTertiary)
                    Spacer()
                    Text(formattedAmount(receipt.mindlessCents))
                        .font(ReceiptFont.mono(size: 14, weight: .medium))
                        .foregroundStyle(Color.receiptImpulse.opacity(0.8))
                }
            }
            
            // Biggest
            if let biggest = receipt.biggestSpend {
                HStack {
                    Text("BIGGEST")
                        .font(ReceiptFont.smallCaps(size: 11))
                        .foregroundStyle(Color.receiptTertiary)
                    Spacer()
                    Text(formattedAmount(biggest.amountCents))
                        .font(ReceiptFont.mono(size: 14, weight: .medium))
                        .foregroundStyle(Color.receiptSecondary)
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }
    
    // MARK: - Verdict
    
    private var exportVerdict: some View {
        let verdict = style == .shareSafe ? receipt.shareVerdictLine : receipt.verdictLine
        
        return VStack(spacing: 0) {
            Text("\"")
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundStyle(Color.receiptTertiary)
                .offset(y: 8)
            
            Text(verdict)
                .font(ReceiptFont.body(size: 16, weight: .medium))
                .foregroundStyle(Color.receiptText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Footer
    
    private var exportFooter: some View {
        VStack(spacing: 12) {
            // Streak badge
            if streakDays > 1 {
                HStack(spacing: 6) {
                    Text("🔥")
                        .font(.system(size: 14))
                    Text("\(streakDays) DAY STREAK")
                        .font(ReceiptFont.smallCaps(size: 10))
                        .tracking(1)
                        .foregroundStyle(Color.receiptStreak)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.receiptStreak.opacity(0.12))
                .clipShape(Capsule())
            }
            
            // Branding
            HStack(spacing: 4) {
                Text("🧾")
                    .font(.system(size: 12))
                Text("Rilo")
                    .font(ReceiptFont.body(size: 12, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(Color.receiptSecondary)
            }
        }
    }
}
