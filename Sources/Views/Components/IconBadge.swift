//
//  IconBadge.swift
//  Rilo
//
//  Created by Claude on 2/3/26.
//

import SwiftUI

/// A small icon displayed in a tinted circle background.
/// Supports both SF Symbols and emoji/text.
struct IconBadge: View {
    let icon: String
    var tint: Color
    var size: CGFloat
    var iconScale: CGFloat
    var isSystemImage: Bool

    init(
        icon: String,
        tint: Color = .appAccent,
        size: CGFloat = 32,
        iconScale: CGFloat = 0.5,
        isSystemImage: Bool = true
    ) {
        self.icon = icon
        self.tint = tint
        self.size = size
        self.iconScale = iconScale
        self.isSystemImage = isSystemImage
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.12))

            if isSystemImage {
                Image(systemName: icon)
                    .font(.system(size: size * iconScale, weight: .semibold))
                    .foregroundStyle(tint)
            } else {
                Text(icon)
                    .font(.system(size: size * iconScale))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 16) {
        IconBadge(icon: "flame.fill", tint: .appSuccess)
        IconBadge(icon: "star.fill", tint: .appAccent, size: 40)
        IconBadge(icon: "exclamationmark.triangle.fill", tint: .appWarning, size: 48)
        IconBadge(icon: "coffee", tint: .appAccent, isSystemImage: false)
    }
    .padding()
    .background(Color.appBackground)
}
