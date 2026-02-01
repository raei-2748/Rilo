//
//  SettingsView.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("receiptMode") private var receiptMode: ReceiptMode = .roast
    @AppStorage("reminderHour") private var reminderHour: Int = 19
    @AppStorage("reminderMinute") private var reminderMinute: Int = 30
    @AppStorage("anonymizeDefault") private var anonymizeDefault: Bool = false
    
    @State private var reminderTime: Date = Calendar.current.date(bySettingHour: 19, minute: 30, second: 0, of: Date()) ?? Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Feedback Mode", selection: $receiptMode) {
                        Text("Roast (Blunt)").tag(ReceiptMode.roast)
                        Text("Therapist (Gentle)").tag(ReceiptMode.therapist)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("PERSONALITY")
                } footer: {
                    Text(receiptMode == .roast ? "Be prepared for some financial truth bombs." : "Gentle encouragement for your spending journey.")
                }
                
                Section {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .onChange(of: reminderTime) { oldValue, newValue in
                            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                            reminderHour = components.hour ?? 19
                            reminderMinute = components.minute ?? 30
                            NotificationService.shared.scheduleDailyReminder(at: reminderHour, minute: reminderMinute)
                        }
                } header: {
                    Text("NOTIFICATION")
                }
                
                Section {
                    Toggle("Anonymize by Default", isOn: $anonymizeDefault)
                } header: {
                    Text("SHARING")
                } footer: {
                    Text("Hides merchant names and rounds amounts in share view.")
                }
                
                Section {
                    Link("GitHub Repository", destination: URL(string: "https://github.com/raei-2748/Rilo")!)
                        .foregroundStyle(Color.receiptText)
                } header: {
                    Text("ABOUT")
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                // Sync internal time state from AppStorage
                reminderTime = Calendar.current.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: Date()) ?? Date()
                NotificationService.shared.requestPermission()
            }
        }
    }
}

#Preview {
    SettingsView()
}
