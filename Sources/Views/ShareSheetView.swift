//
//  ShareSheetView.swift
//  Rilo
//
//  Created by Claude on 2/1/26.
//

import SwiftUI
import UIKit

struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let completion: UIActivityViewController.CompletionWithItemsHandler?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.completionWithItemsHandler = completion
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension View {
    func shareSheet(
        isPresented: Binding<Bool>,
        items: [Any],
        completion: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            ShareSheetView(activityItems: items, completion: completion)
        }
    }
}
