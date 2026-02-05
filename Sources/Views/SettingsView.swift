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
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Personality Section
                        settingsSection(
                            icon: "theatermasks",
                            title: "PERSONALITY",
                            footer: receiptMode == .roast
                                ? "Be prepared for some financial truth bombs."
                                : "Gentle encouragement for your spending journey."
                        ) {
                            Picker("Feedback Mode", selection: $receiptMode) {
                                Text("Roast (Blunt)").tag(ReceiptMode.roast)
                                Text("Therapist (Gentle)").tag(ReceiptMode.therapist)
                            }
                            .pickerStyle(.segmented)
                            .tint(Color.appAccent)
                        }

                        // Notification Section
                        settingsSection(
                            icon: "bell.badge",
                            title: "NOTIFICATION"
                        ) {
                            HStack {
                                Text("Reminder Time")
                                    .font(ReceiptFont.body(size: 15))
                                    .foregroundStyle(Color.appText)
                                Spacer()
                                DatePicker(
                                    "",
                                    selection: $reminderTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .tint(Color.appAccent)
                                .onChange(of: reminderTime) { _, newValue in
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                    reminderHour = components.hour ?? 19
                                    reminderMinute = components.minute ?? 30
                                    NotificationService.shared.scheduleDailyReminder(at: reminderHour, minute: reminderMinute)
                                }
                            }
                        }

                        // Sharing Section
                        settingsSection(
                            icon: "square.and.arrow.up",
                            title: "SHARING",
                            footer: "Hides merchant names and rounds amounts in share view."
                        ) {
                            HStack {
                                Text("Anonymize by Default")
                                    .font(ReceiptFont.body(size: 15))
                                    .foregroundStyle(Color.appText)
                                Spacer()
                                Toggle("", isOn: $anonymizeDefault)
                                    .labelsHidden()
                                    .tint(Color.appAccent)
                            }
                        }

                        // About Section
                        settingsSection(
                            icon: "info.circle",
                            title: "ABOUT"
                        ) {
                            Link(destination: URL(string: "https://github.com/raei-2748/Rilo")!) {
                                HStack {
                                    Text("GitHub Repository")
                                        .font(ReceiptFont.body(size: 15))
                                        .foregroundStyle(Color.appText)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(Color.appTertiary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                reminderTime = Calendar.current.date(
                    bySettingHour: reminderHour,
                    minute: reminderMinute,
                    second: 0,
                    of: Date()
                ) ?? Date()
                NotificationService.shared.requestPermission()
            }
        }
    }

    // MARK: - Settings Section Builder

    @ViewBuilder
    private func settingsSection<Content: View>(
        icon: String,
        title: String,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with IconBadge
            HStack(spacing: 10) {
                IconBadge(icon: icon, tint: .appAccent, size: 28)
                Text(title)
                    .font(ReceiptFont.smallCaps(size: 12))
                    .foregroundStyle(Color.appTertiary)
            }

            // Content in AppCard
            AppCard {
                content()
            }

            // Footer text
            if let footer = footer {
                Text(footer)
                    .font(ReceiptFont.body(size: 12))
                    .foregroundStyle(Color.appTertiary)
                    .padding(.horizontal, 4)
            }
        }
    }
}

#Preview {
    SettingsView()
}
