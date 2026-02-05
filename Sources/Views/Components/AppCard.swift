//
//  AppCard.swift
//  Rilo
//
//  Created by Claude on 2/3/26.
//

import SwiftUI

/// A rounded surface card with subtle shadow and optional border.
/// Use for grouping related content throughout the app.
struct AppCard<Content: View>: View {
    let content: Content
    var padding: CGFloat
    var cornerRadius: CGFloat
    var showBorder: Bool

    init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 16,
        showBorder: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.appBorder, lineWidth: showBorder ? 1 : 0)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            .shadow(color: .black.opacity(0.02), radius: 16, x: 0, y: 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Card Title")
                    .font(.headline)
                Text("This is some content inside the card.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        AppCard(padding: 24, cornerRadius: 20) {
            Text("Custom padding and corner radius")
        }

        AppCard(showBorder: false) {
            Text("No border variant")
        }
    }
    .padding()
    .background(Color.appBackground)
}
