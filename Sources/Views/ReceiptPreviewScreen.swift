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
    let streakDays: Int
    let yesterdayArchetype: SpenderArchetype?

    @AppStorage("anonymizeDefault") private var anonymizeDefault: Bool = false

    @State private var showingShareSheet: Bool = false
    @State private var exportedImage: UIImage?
    @State private var shareNudge: ShareNudgeEvent?
    @State private var hasAppeared: Bool = false

    private let exportService = ImageExportService()

    /// The default share style based on user preference
    private var defaultShareStyle: ReceiptRenderStyle {
        anonymizeDefault ? .shareSafe : .normal
    }

    /// The secondary share style (opposite of default)
    private var secondaryShareStyle: ReceiptRenderStyle {
        anonymizeDefault ? .normal : .shareSafe
    }

    var body: some View {
        // Note: No NavigationStack here - this view is pushed via navigationDestination from TodayView
        ZStack {
            // Brand gradient background
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appSurface
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Radial spotlight behind receipt
            RadialGradient(
                colors: [
                    Color.appAccent.opacity(0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 8)

                    // Receipt Card with entrance animation
                    ReceiptCardView(
                        receipt: receipt,
                        isAnonymized: false,
                        streakDays: streakDays,
                        isExportMode: false,
                        maxWidth: 420
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .offset(y: hasAppeared ? 0 : 30)
                    .opacity(hasAppeared ? 1 : 0)

                    // Share Nudge (if applicable)
                    if let nudge = shareNudge {
                        shareNudgeView(nudge)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // Share Buttons
                    shareButtons
                        .padding(.horizontal, 20)
                        .offset(y: hasAppeared ? 0 : 20)
                        .opacity(hasAppeared ? 1 : 0)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Your Receipt")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            detectShareNudge()
            withAnimation(.appSoft.delay(0.1)) {
                hasAppeared = true
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
                .foregroundStyle(Color.appSuccess)

            Text(nudge.nudgeMessage)
                .font(ReceiptFont.body(size: 13, weight: .medium))
                .foregroundStyle(Color.appSecondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.appSuccess.opacity(0.1))
                .overlay(
                    Capsule()
                        .strokeBorder(Color.appSuccess.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Share Buttons

    private var shareButtons: some View {
        VStack(spacing: 12) {
            // Primary: Uses user's default preference
            PrimaryButton(
                title: defaultShareStyle == .shareSafe ? "Share (Safe)" : "Share (Full)",
                icon: defaultShareStyle == .shareSafe ? "eye.slash.fill" : "eye.fill",
                style: .filled
            ) {
                exportReceipt(style: defaultShareStyle)
            }

            // Secondary: Opposite of user's preference
            PrimaryButton(
                title: secondaryShareStyle == .shareSafe ? "Share (Safe)" : "Share (Full)",
                icon: secondaryShareStyle == .shareSafe ? "eye.slash.fill" : "eye.fill",
                style: .outlined
            ) {
                exportReceipt(style: secondaryShareStyle)
            }

            // Hint text
            HStack(spacing: 6) {
                IconBadge(icon: "info.circle", tint: .appTertiary, size: 16)
                Text("Safe mode hides merchant names and rounds amounts")
                    .font(ReceiptFont.body(size: 11))
                    .foregroundStyle(Color.appTertiary)
            }
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
    NavigationStack {
        ReceiptPreviewScreen(
            receipt: SeedData.coffeeAddict,
            streakDays: 5,
            yesterdayArchetype: .lowDrama
        )
    }
}
