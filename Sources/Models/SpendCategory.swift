//
//  SpendCategory.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

enum SpendCategory: String, Codable, CaseIterable {
    case coffee
    case food
    case transport
    case impulse
    case other
    
    var emoji: String {
        switch self {
        case .coffee: return "☕"
        case .food: return "🍜"
        case .transport: return "🚕"
        case .impulse: return "🫠"
        case .other: return "🧾"
        }
    }
    
    var displayName: String {
        rawValue.capitalized
    }
}
