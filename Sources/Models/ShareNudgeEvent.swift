//
//  ShareNudgeEvent.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

enum ShareNudgeEvent: String, Codable {
    case repeatOffender
    case streakMilestone
    case newArchetype
    case bigTicket
    
    var nudgeMessage: String {
        switch self {
        case .repeatOffender: return "Same mistake twice? Pure content."
        case .streakMilestone: return "You're actually being honest. Rare."
        case .newArchetype: return "Unlocked a new personality trait."
        case .bigTicket: return "That's a lot of money for one thing."
        }
    }
}
