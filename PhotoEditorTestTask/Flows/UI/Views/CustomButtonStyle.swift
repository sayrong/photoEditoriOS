//
//  CustomButtonStyle.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 13.05.2025.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.5) // Adjust opacity for disabled state
    }
}
