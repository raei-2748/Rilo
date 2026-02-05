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
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Amount Display Card
                            amountCard

                            // Category Selection Card
                            categoryCard

                            // Details Card (merchant + impulse)
                            detailsCard

                            Spacer(minLength: 120)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }

                    // Pinned button at bottom
                    pinnedButton
                }
            }
            .navigationTitle("Log Spend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appSecondary)
                }
            }
        }
    }

    // MARK: - Amount Card

    private var amountCard: some View {
        AppCard(padding: 24) {
            VStack(spacing: 8) {
                Text("AMOUNT")
                    .font(ReceiptFont.smallCaps(size: 11))
                    .foregroundStyle(Color.appTertiary)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$")
                        .font(ReceiptFont.mono(size: 40, weight: .bold))
                        .foregroundStyle(Color.appSecondary)
                    TextField("0.00", text: $amountString)
                        .keyboardType(.decimalPad)
                        .font(ReceiptFont.mono(size: 48, weight: .bold))
                        .foregroundStyle(Color.appText)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.6)
                        .onChange(of: amountString) { _, newValue in
                            formatAmount(newValue)
                        }
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Text("Enter amount. We auto-format.")
                    .font(ReceiptFont.body(size: 12))
                    .foregroundStyle(Color.appTertiary)
            }
        }
    }

    // MARK: - Category Card

    private var categoryCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("CATEGORY")
                    .font(ReceiptFont.smallCaps(size: 11))
                    .foregroundStyle(Color.appTertiary)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(SpendCategory.allCases, id: \.self) { category in
                        categoryPill(category)
                    }
                }
            }
        }
    }

    private func categoryPill(_ category: SpendCategory) -> some View {
        Button {
            withAnimation(.appFast) {
                selectedCategory = category
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        } label: {
            VStack(spacing: 4) {
                Text(category.emoji)
                    .font(.system(size: 20))
                Text(category.displayName)
                    .font(ReceiptFont.body(size: 11, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selectedCategory == category ? Color.appAccent.opacity(0.15) : Color.appSurfaceAlt)
            .foregroundStyle(selectedCategory == category ? Color.appAccent : Color.appSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedCategory == category ? Color.appAccent.opacity(0.3) : Color.appBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PillButtonStyle())
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        AppCard {
            VStack(spacing: 16) {
                // Merchant field
                HStack(spacing: 12) {
                    IconBadge(icon: "storefront", tint: .appAccent, size: 36)
                    TextField("Merchant (Optional)", text: $merchant)
                        .font(ReceiptFont.body(size: 15))
                        .foregroundStyle(Color.appText)
                        .autocorrectionDisabled()
                }

                Divider()
                    .background(Color.appBorder)

                // Impulse toggle as pill
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Impulse Purchase?")
                            .font(ReceiptFont.body(size: 14, weight: .medium))
                            .foregroundStyle(Color.appText)
                        Text("Mark unplanned spending")
                            .font(ReceiptFont.body(size: 11))
                            .foregroundStyle(Color.appTertiary)
                    }
                    Spacer()
                    impulseToggle
                }
            }
        }
    }

    private var impulseToggle: some View {
        Button {
            withAnimation(.appFast) {
                isImpulse.toggle()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isImpulse ? "exclamationmark.triangle.fill" : "hand.thumbsup")
                    .font(.system(size: 12, weight: .medium))
                Text(isImpulse ? "Yes" : "No")
                    .font(ReceiptFont.body(size: 13, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isImpulse ? Color.appWarning.opacity(0.15) : Color.appSurfaceAlt)
            .foregroundStyle(isImpulse ? Color.appWarning : Color.appSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isImpulse ? Color.appWarning.opacity(0.3) : Color.appBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PillButtonStyle())
    }

    // MARK: - Pinned Button

    private var pinnedButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.appBorder)
            PrimaryButton(
                title: "Log Spend",
                icon: "checkmark",
                isEnabled: isValid
            ) {
                saveEntry()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.appSurface)
    }

    // MARK: - Actions

    private func formatAmount(_ value: String) {
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
        guard isValid else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        let entry = SpendEntryModel(
            amountCents: amountCents,
            merchant: merchant.isEmpty ? nil : merchant,
            category: selectedCategory,
            isImpulse: isImpulse
        )
        modelContext.insert(entry)

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss()
    }
}

#Preview {
    SpendLoggingView()
}
