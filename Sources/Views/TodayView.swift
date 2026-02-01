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

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Hero Section
                    VStack(spacing: 8) {
                        if currentStreak > 1 {
                            HStack(spacing: 4) {
                                Text("🔥")
                                Text("\(currentStreak) DAY STREAK")
                                    .font(ReceiptFont.smallCaps(size: 10))
                                    .foregroundStyle(Color.receiptStreak)
                            }
                            .padding(.bottom, 4)
                        }

                        Text("TODAY'S TOTAL")
                            .font(ReceiptFont.smallCaps(size: 12))
                            .foregroundStyle(.secondary)
                        
                        Text(todayTotalCents.formattedAsCurrency())
                            .font(ReceiptFont.mono(size: 40, weight: .bold))
                            .foregroundStyle(Color.receiptText)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    
                    // List of entries
                    List {
                        if todayEntries.isEmpty {
                            ContentUnavailableView(
                                "No spends yet",
                                systemImage: "tray",
                                description: Text("Tap + to log your first spend of the day.")
                            )
                            .listRowBackground(Color.clear)
                        } else {
                            Section("Today's Spends") {
                                ForEach(todayEntries) { entry in
                                    HStack {
                                        Text(entry.category.emoji)
                                        VStack(alignment: .leading) {
                                            Text(entry.merchant ?? entry.category.displayName)
                                                .font(.headline)
                                            Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(entry.amountCents.formattedAsCurrency())
                                            .font(ReceiptFont.mono(size: 14, weight: .semibold))
                                            .foregroundStyle(entry.isImpulse ? Color.receiptImpulse : Color.receiptText)
                                    }
                                }
                                .onDelete(perform: deleteEntries)
                            }
                        }
                    }
                    
                    // Footer Actions
                    VStack(spacing: 12) {
                        Button {
                            showingReceiptPreview = true
                        } label: {
                            Text("View Daily Receipt")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.receiptText)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .fontWeight(.bold)
                        }
                        .disabled(todayEntries.isEmpty)
                        .opacity(todayEntries.isEmpty ? 0.5 : 1.0)
                        .padding(.horizontal, 20)
                        
                        Button {
                            showingLogSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Log Spend")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground))
                            .foregroundStyle(Color.receiptText)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.receiptText.opacity(0.1), lineWidth: 1)
                            )
                            .fontWeight(.medium)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .background(Color(.systemGroupedBackground))
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
                            .foregroundStyle(Color.receiptSecondary)
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
                // Use stored settings for receipt mode
                let modeRaw = UserDefaults.standard.string(forKey: "receiptMode") ?? "roast"
                let receipt = receiptRepo.getReceipt(for: Date(), mode: ReceiptMode(rawValue: modeRaw) ?? .roast)
                ReceiptPreviewScreen(receipt: receipt)
            }
            .onAppear {
                updateStreak()
            }
        }
    }
    
    private func updateStreak() {
        let streakService = StreakService(modelContext: modelContext)
        currentStreak = streakService.computeCurrentStreak()
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
