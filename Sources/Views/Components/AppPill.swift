//
//  AppPill.swift
//  Rilo
//
//  Created by Claude on 2/3/26.
//

import SwiftUI

/// A capsule-style pill for toggles, tags, and selectable options.
struct AppPill: View {
    let text: String
    var icon: String?
    var isSelected: Bool
    var tint: Color
    var action: (() -> Void)?

    init(
        text: String,
        icon: String? = nil,
        isSelected: Bool = false,
        tint: Color = .appAccent,
        action: (() -> Void)? = nil
    ) {
        self.text = text
        self.icon = icon
        self.isSelected = isSelected
        self.tint = tint
        self.action = action
    }

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(text)
                    .font(ReceiptFont.body(size: 13, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? tint.opacity(0.15) : Color.appSurface)
            .foregroundStyle(isSelected ? tint : Color.appSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? tint.opacity(0.3) : Color.appBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PillButtonStyle())
    }
}

/// Button style with scale effect for pill interactions
struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.appFast, value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack {
            AppPill(text: "Unselected")
            AppPill(text: "Selected", isSelected: true)
        }

        HStack {
            AppPill(text: "With Icon", icon: "star.fill", isSelected: false)
            AppPill(text: "With Icon", icon: "star.fill", isSelected: true)
        }

        HStack {
            AppPill(text: "Warning", icon: "exclamationmark.triangle.fill", isSelected: true, tint: .appWarning)
            AppPill(text: "Success", icon: "checkmark", isSelected: true, tint: .appSuccess)
        }
    }
    .padding()
    .background(Color.appBackground)
}
