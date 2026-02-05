//
//  AppColors.swift
//  Rilo
//
//  Created by Claude on 2/3/26.
//

import SwiftUI

// MARK: - App-Wide Semantic Colors

extension Color {
    // MARK: - Backgrounds

    /// Primary app background (bone white)
    static let appBackground = BrandColors.boneWhite

    /// Card/surface background (slightly darker paper)
    static let appSurface = BrandColors.paperTint

    /// Alternative surface for nested cards
    static let appSurfaceAlt = BrandColors.boneWhite

    // MARK: - Text

    /// Primary text color
    static let appText = BrandColors.charcoalInk

    /// Secondary text (labels, subtitles)
    static let appSecondary = BrandColors.secondaryInk

    /// Tertiary/muted text
    static let appTertiary = BrandColors.tertiaryInk

    // MARK: - Accents

    /// Primary accent (ocean slate)
    static let appAccent = BrandColors.oceanSlate

    /// Success/streak color
    static let appSuccess = BrandColors.softSage

    /// Warning/impulse color
    static let appWarning = BrandColors.impulseTaupe

    // MARK: - Borders

    /// Subtle border color
    static let appBorder = BrandColors.sandTaupe.opacity(0.4)

    /// Stronger border for emphasis
    static let appBorderStrong = BrandColors.sandTaupe.opacity(0.6)
}
