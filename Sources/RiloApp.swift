//
//  RiloApp.swift
//  Rilo
//
//  Created by Ray Wang on 2/1/26.
//

import SwiftUI
import SwiftData

@main
struct RiloApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SpendEntryModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TodayView()
        }
        .modelContainer(sharedModelContainer)
    }
}
