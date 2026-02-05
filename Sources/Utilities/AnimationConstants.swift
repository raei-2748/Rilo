//
//  AnimationConstants.swift
//  Rilo
//
//  Created by Claude on 2/3/26.
//

import SwiftUI

// MARK: - Animation Timing Constants

enum AnimationTiming {
    /// Fast interactions (0.15s) - button presses, micro-feedback
    static let fast: Double = 0.15

    /// Standard transitions (0.25s) - most UI changes
    static let standard: Double = 0.25

    /// Soft/gentle animations (0.35s) - entrance/exit, emphasis
    static let soft: Double = 0.35

    /// Spring response for bouncy interactions
    static let springResponse: Double = 0.5

    /// Spring damping fraction
    static let springDamping: Double = 0.7
}

// MARK: - Animation Extensions

extension Animation {
    /// Fast animation for button presses and micro-feedback
    static let appFast = Animation.easeOut(duration: AnimationTiming.fast)

    /// Standard animation for most UI changes
    static let appStandard = Animation.easeInOut(duration: AnimationTiming.standard)

    /// Soft animation for entrance/exit and emphasis
    static let appSoft = Animation.easeOut(duration: AnimationTiming.soft)

    /// Spring animation for bouncy interactions
    static let appSpring = Animation.spring(
        response: AnimationTiming.springResponse,
        dampingFraction: AnimationTiming.springDamping
    )
}
