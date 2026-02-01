//
//  ImageExportService.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI
import UIKit

@MainActor
class ImageExportService {
    
    /// Renders the ReceiptExportView to a UIImage using ImageRenderer
    func renderExportView(receipt: DailyReceipt, style: ReceiptRenderStyle, streakDays: Int) -> UIImage? {
        let exportView = ReceiptExportView(receipt: receipt, style: style, streakDays: streakDays)
        
        let renderer = ImageRenderer(content: exportView)
        
        // Ensure we render at 2x or 3x scale for crispness
        renderer.scale = UITraitCollection.current.displayScale
        
        return renderer.uiImage
    }
}
