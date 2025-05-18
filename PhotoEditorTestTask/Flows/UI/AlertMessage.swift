//
//  AlertMessage.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 18.05.2025.
//

import SwiftUI

struct AlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

extension AlertMessage {
    func makeAlert() -> Alert {
        Alert(
            title: Text(self.title),
            message: Text(self.message),
            dismissButton: .default(Text(L10n.ok))
        )
    }
}
