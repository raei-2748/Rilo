//
//  PrimaryButton.swift
//  Rilo
//
//  Created by Claude on 2/3/26.
//

import SwiftUI

/// A consistent primary button style with filled and outlined variants.
struct PrimaryButton: View {
    let title: String
    var icon: String?
    var isEnabled: Bool
    var style: ButtonVariant
    let action: () -> Void

    enum ButtonVariant {
        case filled
        case outlined
    }

    init(
        title: String,
        icon: String? = nil,
        isEnabled: Bool = true,
        style: ButtonVariant = .filled,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: {
            if isEnabled {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundView)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(borderOverlay)
        }
        .buttonStyle(PrimaryButtonStyle())
        .opacity(isEnabled ? 1.0 : 0.5)
        .allowsHitTesting(isEnabled)
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            Color.appText
        case .outlined:
            Color.appSurface
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .filled:
            return .white
        case .outlined:
            return .appText
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if style == .outlined {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.appBorder, lineWidth: 1)
        }
    }
}

/// Button style with scale effect on press
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.appFast, value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Continue", icon: "arrow.right") {
            print("Tapped!")
        }

        PrimaryButton(title: "Log Spend", icon: "plus", style: .outlined) {
            print("Tapped!")
        }

        PrimaryButton(title: "Disabled", isEnabled: false) {
            print("Tapped!")
        }

        PrimaryButton(title: "Disabled Outlined", isEnabled: false, style: .outlined) {
            print("Tapped!")
        }
    }
    .padding()
    .background(Color.appBackground)
}
