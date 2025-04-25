//
//  LoadingModifier.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 25.04.2025.
//

import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
    let isPresented: Bool

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .transition(.opacity)
            }
        }
    }
}

extension View {
    func loadingOverlay(_ isPresented: Bool) -> some View {
        self.modifier(LoadingOverlayModifier(isPresented: isPresented))
    }
}
