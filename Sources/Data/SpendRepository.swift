//
//  SpendRepository.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation
import SwiftData

@MainActor
class SpendRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addSpend(amountCents: Int, merchant: String?, category: SpendCategory, isImpulse: Bool) {
        let entry = SpendEntryModel(
            amountCents: amountCents,
            merchant: merchant,
            category: category,
            isImpulse: isImpulse
        )
        modelContext.insert(entry)
    }
    
    func deleteSpend(_ entry: SpendEntryModel) {
        modelContext.delete(entry)
    }
    
    func getEntries(for date: Date) -> [SpendEntryModel] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<SpendEntryModel> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }
        
        var descriptor = FetchDescriptor<SpendEntryModel>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.timestamp, order: .reverse)]
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
