//
//  ReceiptRepository.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation
import SwiftData

@MainActor
class ReceiptRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Computes a DailyReceipt from stored entries for a specific date
    func getReceipt(for date: Date, mode: ReceiptMode) -> DailyReceipt {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = #Predicate<SpendEntryModel> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }

        let descriptor = FetchDescriptor<SpendEntryModel>(predicate: predicate)
        let entries = (try? modelContext.fetch(descriptor))?.map { $0.toStruct() } ?? []

        return SeedData.createReceipt(date: date, entries: entries, mode: mode)
    }

    /// Fetches the archetype for a specific date if entries exist
    func getArchetype(for date: Date) -> SpenderArchetype? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = #Predicate<SpendEntryModel> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }

        let descriptor = FetchDescriptor<SpendEntryModel>(predicate: predicate)
        let entries = (try? modelContext.fetch(descriptor))?.map { $0.toStruct() } ?? []

        guard !entries.isEmpty else { return nil }

        let total = entries.reduce(0) { $0 + $1.amountCents }
        return RulesEngine.determineArchetype(entries: entries, total: total)
    }
}
