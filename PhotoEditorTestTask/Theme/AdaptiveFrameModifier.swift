//
//  AdaptiveFrameModifier.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 27.04.2025.
//

import SwiftUI

struct AdaptiveFrameModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            content
                .frame(maxWidth: 400, maxHeight: 800)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            content
        }
    }
}

extension View {
    func adaptiveFrame() -> some View {
        self.modifier(AdaptiveFrameModifier())
    }
}
