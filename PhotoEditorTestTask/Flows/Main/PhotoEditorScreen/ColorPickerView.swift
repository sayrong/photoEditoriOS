//
//  ColorPickerView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 15.05.2025.
//

import SwiftUI

extension Notification.Name {
    static let colorDidChange = Notification.Name("ColorDidChange")
    static let currentActiveElementColor = Notification.Name("CurrentActiveElementColor")
}

struct ColorPickerView: View {
    @State private var selectedColor: Color = .black

    var body: some View {
        ColorPicker("", selection: $selectedColor)
            .onChange(of: selectedColor) { _, newColor in
                NotificationCenter.default.post(
                    name: .colorDidChange,
                    object: nil,
                    userInfo: ["color": UIColor(newColor)]
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: .currentActiveElementColor)) { notification in
                if let userInfo = notification.userInfo,
                   let uiColor = userInfo["color"] as? UIColor {
                    selectedColor = Color(uiColor)
                }
            }
            .padding()
    }
}
