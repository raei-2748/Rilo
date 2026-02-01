//
//  ReceiptPreviewScreen.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI

/// Full-screen receipt preview with polished export functionality
struct ReceiptPreviewScreen: View {
    let receipt: DailyReceipt
    
    @State private var showingShareSheet: Bool = false
    @State private var exportedImage: UIImage?
    @State private var selectedShareStyle: ReceiptRenderStyle = .shareSafe
    
    // Streak and nudge state
    @State private var streakDays: Int = 1
    @State private var shareNudge: ShareNudgeEvent?
    @State private var yesterdayArchetype: SpenderArchetype?
    
    private let exportService = ImageExportService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGray6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 8)
                        
                        // Receipt Card (using in-app view)
                        ReceiptCardView(
                            receipt: receipt,
                            isAnonymized: false,
                            streakDays: streakDays,
                            isExportMode: false
                        )
                        .padding(.horizontal, 16)
                        
                        // Share Nudge (if applicable)
                        if let nudge = shareNudge {
                            shareNudgeView(nudge)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                        
                        // Share Buttons
                        shareButtons
                            .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Your Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                detectShareNudge()
            }
        }
        .shareSheet(
            isPresented: $showingShareSheet,
            items: exportedImage.map { [$0] } ?? []
        ) { _, _, _, _ in
            showingShareSheet = false
        }
    }
    
    // MARK: - Share Nudge
    
    private func shareNudgeView(_ nudge: ShareNudgeEvent) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.receiptStreak)
            
            Text(nudge.nudgeMessage)
                .font(ReceiptFont.body(size: 13, weight: .medium))
                .foregroundStyle(Color.receiptSecondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.receiptStreak.opacity(0.1))
                .overlay(
                    Capsule()
                        .strokeBorder(Color.receiptStreak.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Share Buttons
    
    private var shareButtons: some View {
        VStack(spacing: 12) {
            // Primary: Share (Safe)
            Button {
                exportReceipt(style: .shareSafe)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "eye.slash.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Share (Safe)")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.receiptText)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Secondary: Share (Full)
            Button {
                exportReceipt(style: .normal)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 15))
                    Text("Share (Full)")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.receiptPaper)
                .foregroundStyle(Color.receiptSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.receiptSecondary.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Hint text
            Text("Safe mode hides merchant names and rounds amounts")
                .font(ReceiptFont.body(size: 11))
                .foregroundStyle(Color.receiptTertiary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
    }
    
    // MARK: - Actions
    
    private func detectShareNudge() {
        shareNudge = receipt.detectShareNudge(
            yesterdayArchetype: yesterdayArchetype,
            currentStreak: streakDays
        )
    }
    
    private func exportReceipt(style: ReceiptRenderStyle) {
        selectedShareStyle = style
        
        guard let image = exportService.renderExportView(
            receipt: receipt,
            style: style,
            streakDays: streakDays
        ) else {
            return
        }
        
        exportedImage = image
        showingShareSheet = true
    }
}

#Preview {
    ReceiptPreviewScreen(receipt: SeedData.coffeeAddict)
}
