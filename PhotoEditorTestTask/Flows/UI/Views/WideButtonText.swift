//
//  WideButtonText.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 27.04.2025.
//

import SwiftUI

struct WideButtonText: View {
    
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}
