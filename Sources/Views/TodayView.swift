//
//  TodayView.swift
//  Rilo
//
//  Created by Ray Wang on 2/1/26.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SpendEntryModel.timestamp, order: .reverse) private var entries: [SpendEntryModel]

    @State private var showingLogSheet = false
    @State private var showingReceiptPreview = false
    @State private var feedbackMessage: String?

    @State private var showingSettings = false

    // Streak state
    @State private var currentStreak: Int = 0
    @State private var previousStreak: Int = 0
    @State private var streakJustIncreased: Bool = false

    // Day's total
    private var todayTotalCents: Int {
        let calendar = Calendar.current
        return entries
            .filter { calendar.isDateInToday($0.timestamp) }
            .reduce(0) { $0 + $1.amountCents }
    }

    private var todayEntries: [SpendEntryModel] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInToday($0.timestamp) }
    }

    // Category breakdown for the bar
    private var categoryBreakdown: [(SpendCategory, Int)] {
        var breakdown: [SpendCategory: Int] = [:]
        for entry in todayEntries {
            breakdown[entry.category, default: 0] += entry.amountCents
        }
        return SpendCategory.allCases.map { ($0, breakdown[$0] ?? 0) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)

                    // List of entries
                    entryList

                    // Footer Actions
                    footerButtons
                }

                // Overlay Feedback
                if let message = feedbackMessage {
                    VStack {
                        Spacer()
                        MicroFeedbackView(message: message, subMessage: nil)
                            .padding(.bottom, 100)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Rilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Color.appSecondary)
                    }
                }
            }
            .sheet(isPresented: $showingLogSheet) {
                SpendLoggingView()
                    .onDisappear {
                        showFeedback()
                        updateStreak()
                    }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .navigationDestination(isPresented: $showingReceiptPreview) {
                let receiptRepo = ReceiptRepository(modelContext: modelContext)
                let modeRaw = UserDefaults.standard.string(forKey: "receiptMode") ?? "roast"
                let receipt = receiptRepo.getReceipt(for: Date(), mode: ReceiptMode(rawValue: modeRaw) ?? .roast)
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                let yesterdayArchetype = yesterday.flatMap { receiptRepo.getArchetype(for: $0) }

                ReceiptPreviewScreen(
                    receipt: receipt,
                    streakDays: currentStreak,
                    yesterdayArchetype: yesterdayArchetype
                )
            }
            .onAppear {
                updateStreak()
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        AppCard(padding: 24, cornerRadius: 20) {
            VStack(spacing: 12) {
                // Streak badge
                if currentStreak > 1 {
                    streakBadge
                }

                Text("TODAY'S TOTAL")
                    .font(ReceiptFont.smallCaps(size: 12))
                    .foregroundStyle(Color.appSecondary)

                Text(todayTotalCents.formattedAsCurrency())
                    .font(ReceiptFont.mono(size: 44, weight: .bold))
                    .foregroundStyle(Color.appText)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                // Category breakdown bar
                if !todayEntries.isEmpty {
                    CategoryBreakdownBar(breakdown: categoryBreakdown)
                        .padding(.top, 8)
                        .padding(.horizontal, 8)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(
            LinearGradient(
                colors: [Color.appAccent.opacity(0.05), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        )
    }

    private var streakBadge: some View {
        HStack(spacing: 6) {
            IconBadge(icon: "flame.fill", tint: .appSuccess, size: 24)
            Text("\(currentStreak) DAY STREAK")
                .font(ReceiptFont.smallCaps(size: 11))
                .foregroundStyle(Color.appSuccess)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.appSuccess.opacity(0.1))
        .clipShape(Capsule())
        .scaleEffect(streakJustIncreased ? 1.1 : 1.0)
        .animation(.appSpring, value: streakJustIncreased)
    }

    // MARK: - Entry List

    private var entryList: some View {
        Group {
            if todayEntries.isEmpty {
                VStack {
                    Spacer()
                    ContentUnavailableView(
                        "No spends yet",
                        systemImage: "tray",
                        description: Text("Tap + to log your first spend of the day.")
                    )
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section {
                        ForEach(todayEntries) { entry in
                            entryRow(entry)
                                .listRowBackground(Color.appSurface)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .onDelete(perform: deleteEntries)
                    } header: {
                        Text("Today's Spends")
                            .font(ReceiptFont.smallCaps(size: 11))
                            .foregroundStyle(Color.appTertiary)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.appBackground)
            }
        }
    }

    private func entryRow(_ entry: SpendEntryModel) -> some View {
        HStack(spacing: 12) {
            IconBadge(
                icon: entry.category.emoji,
                tint: entry.isImpulse ? .appWarning : .appAccent,
                size: 40,
                isSystemImage: false
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.merchant ?? entry.category.displayName)
                    .font(ReceiptFont.body(size: 15, weight: .medium))
                    .foregroundStyle(Color.appText)
                Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(ReceiptFont.mono(size: 11))
                    .foregroundStyle(Color.appTertiary)
            }

            Spacer()

            Text(entry.amountCents.formattedAsCurrency())
                .font(ReceiptFont.mono(size: 15, weight: .semibold))
                .foregroundStyle(entry.isImpulse ? Color.appWarning : Color.appText)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Footer Buttons

    private var footerButtons: some View {
        VStack(spacing: 12) {
            PrimaryButton(
                title: "View Daily Receipt",
                isEnabled: !todayEntries.isEmpty,
                style: .filled
            ) {
                showingReceiptPreview = true
            }

            PrimaryButton(
                title: "Log Spend",
                icon: "plus",
                style: .outlined
            ) {
                showingLogSheet = true
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.appBackground)
    }

    // MARK: - Actions

    private func updateStreak() {
        let streakService = StreakService(modelContext: modelContext)
        let newStreak = streakService.computeCurrentStreak()

        if newStreak > previousStreak && previousStreak > 0 {
            streakJustIncreased = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                streakJustIncreased = false
            }
        }

        previousStreak = currentStreak
        currentStreak = newStreak
    }

    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(todayEntries[index])
            }
            updateStreak()
        }
    }

    private func showFeedback() {
        feedbackMessage = "Logged. Today total: \(todayTotalCents.formattedAsCurrency())"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                feedbackMessage = nil
            }
        }
    }
}

#Preview {
    TodayView()
}
