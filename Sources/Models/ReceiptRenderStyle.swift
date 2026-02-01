//
//  ReceiptRenderStyle.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import Foundation

enum ReceiptRenderStyle: Codable {
    case normal
    case shareSafe
    
    var hidesMerchantNames: Bool {
        self == .shareSafe
    }
    
    var roundsAmounts: Bool {
        self == .shareSafe
    }
    
    var maxLineItems: Int {
        switch self {
        case .normal: return 50
        case .shareSafe: return 6
        }
    }
}
