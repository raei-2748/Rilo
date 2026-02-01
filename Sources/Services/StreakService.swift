//
//  StreakService.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation
import SwiftData

@MainActor
class StreakService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Computes the current streak of consecutive days logged
    func computeCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Fetch all entries sorted by date
        let descriptor = FetchDescriptor<SpendEntryModel>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        guard let allEntries = try? modelContext.fetch(descriptor), !allEntries.isEmpty else {
            return 0
        }
        
        // Group entries by day
        let daysLogged = Set(allEntries.map { calendar.startOfDay(for: $0.timestamp) })
        
        var streak = 0
        var currentCheckDate = daysLogged.contains(today) ? today : calendar.date(byAdding: .day, value: -1, to: today)!
        
        // If yesterday wasn't logged and today isn't logged, streak is 0
        if !daysLogged.contains(today) && !daysLogged.contains(calendar.date(byAdding: .day, value: -1, to: today)!) {
            return 0
        }
        
        // Step backwards through days
        while daysLogged.contains(currentCheckDate) {
            streak += 1
            guard let nextDate = calendar.date(byAdding: .day, value: -1, to: currentCheckDate) else { break }
            currentCheckDate = nextDate
        }
        
        return streak
    }
}
