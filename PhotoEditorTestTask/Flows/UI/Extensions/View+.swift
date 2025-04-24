//
//  View+.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 24.04.2025.
//

import SwiftUI

extension View {
    func errorBorder(isValid: Bool) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isValid ? Color.clear : Asset.Colors.destructive.swiftUIColor, lineWidth: 1)
        )
    }
}
