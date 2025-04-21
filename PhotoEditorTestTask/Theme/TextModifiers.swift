//
//  TextModifiers.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 18.04.2025.
//

import SwiftUI

struct TitleTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(Asset.Colors.accentColor.swiftUIColor)
    }
}

struct BodyTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 24, weight: .regular))
            .foregroundColor(Asset.Colors.primaryText.swiftUIColor)
    }
}

struct ButtonTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 24, weight: .regular))
            .foregroundColor(Asset.Colors.primaryButtonText.swiftUIColor)
    }
}

struct CaptionTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Asset.Colors.secondaryText.swiftUIColor)
    }
}

struct AccentTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(Asset.Colors.accentColor.swiftUIColor)
    }
}

extension View {
    func titleText() -> some View {
        self.modifier(TitleTextModifier())
    }
    
    func bodyText() -> some View {
        self.modifier(BodyTextModifier())
    }

    func captionText() -> some View {
        self.modifier(CaptionTextModifier())
    }

    func accentText() -> some View {
        self.modifier(AccentTextModifier())
    }
    
    func buttonText() -> some View {
        self.modifier(ButtonTextModifier())
    }
}
