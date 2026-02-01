//
//  SpenderArchetype.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

enum SpenderArchetype: String, Codable, CaseIterable {
    case bigSpender
    case coffeeAddict
    case impulseBuyer
    case convenienceKing
    case foody
    case lowDrama
    case repeatOffender
    case cleanDay
    
    var headline: String {
        switch self {
        case .bigSpender: return "💰 Big Ticket"
        case .coffeeAddict: return "☕ Serial Coffee"
        case .impulseBuyer: return "🫠 Impulse Day"
        case .convenienceKing: return "🚙 Convenience Mode"
        case .foody: return "🍜 Food Spiral"
        case .lowDrama: return "😌 Low Drama"
        case .repeatOffender: return "🔄 Repeat Offender"
        case .cleanDay: return "✨ Clean Day"
        }
    }
}
