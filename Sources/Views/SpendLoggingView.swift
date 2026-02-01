//
//  SpendLoggingView.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI
import SwiftData

struct SpendLoggingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var amountString: String = ""
    @State private var merchant: String = ""
    @State private var selectedCategory: SpendCategory = .other
    @State private var isImpulse: Bool = false
    
    private var amountCents: Int {
        let cleaned = amountString.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return Int(cleaned) ?? 0
    }
    
    private var isValid: Bool {
        amountCents > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("$")
                            .font(.title2.bold())
                        TextField("0.00", text: $amountString)
                            .keyboardType(.decimalPad)
                            .font(.title2.monospacedDigit())
                            .onChange(of: amountString) { oldValue, newValue in
                                formatAmount(newValue)
                            }
                    }
                } header: {
                    Text("AMOUNT")
                }

                Section {
                    TextField("Merchant (Optional)", text: $merchant)
                        .autocorrectionDisabled()
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(SpendCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.emoji)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                    
                    Toggle("Impulse Purchase?", isOn: $isImpulse)
                        .tint(Color.receiptImpulse)
                } header: {
                    Text("DETAILS")
                }
                
                Section {
                    Button {
                        saveEntry()
                    } label: {
                        Text("Log Spend")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                    }
                    .disabled(!isValid)
                    .listRowBackground(isValid ? Color.receiptText : Color.gray.opacity(0.3))
                    .foregroundStyle(.white)
                }
            }
            .navigationTitle("Log Spend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func formatAmount(_ value: String) {
        // Simple numeric formatting for $X.XX
        let filtered = value.filter { "0123456789".contains($0) }
        guard let decimal = Double(filtered) else {
            amountString = ""
            return
        }
        let dollars = decimal / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if let formatted = formatter.string(from: NSNumber(value: dollars)) {
            amountString = formatted
        }
    }
    
    private func saveEntry() {
        let entry = SpendEntryModel(
            amountCents: amountCents,
            merchant: merchant.isEmpty ? nil : merchant,
            category: selectedCategory,
            isImpulse: isImpulse
        )
        modelContext.insert(entry)
        dismiss()
    }
}

#Preview {
    SpendLoggingView()
}
