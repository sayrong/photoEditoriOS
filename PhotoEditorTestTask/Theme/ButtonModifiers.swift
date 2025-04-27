//
//  ButtonModifiers.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 18.04.2025.
//

import SwiftUI

struct PrimaryButtonModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .buttonText()
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Asset.Colors.primaryButton.swiftUIColor)
            )
            .cornerRadius(12)
    }
}

struct PrimaryCancelButtonModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .cancelButtonText()
            .padding()
            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Asset.Colors.primaryButton.swiftUIColor, lineWidth: 1)
            )
    }
}

struct SignInButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Asset.Colors.secondaryButton.swiftUIColor)
            )
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .foregroundStyle(Asset.Colors.secondaryText.swiftUIColor)
    }
}

extension View {
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        self.modifier(PrimaryButtonModifier())
    }
    
    func primaryCancelButtonStyle(isEnabled: Bool = true) -> some View {
        self.modifier(PrimaryCancelButtonModifier())
    }
    
    func signInButtonStyle() -> some View {
        self.modifier(SignInButtonModifier())
    }
}
