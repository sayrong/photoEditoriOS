//
//  View+.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 24.04.2025.
//

import SwiftUI

extension View {
    func errorBorder(text: Binding<String>, isValid: Bool) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(text.wrappedValue.isEmpty || isValid ? Color(hex: 0xDEE2E6) : Asset.Colors.destructive.swiftUIColor, lineWidth: 1)
        )
    }
}

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}
