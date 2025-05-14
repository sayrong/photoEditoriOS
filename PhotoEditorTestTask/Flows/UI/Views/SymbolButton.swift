//
//  SymbolButton.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 14.05.2025.
//

import SwiftUI

struct SymbolButton: View {
    
    let symbolName: String
    var closure: (() -> Void)?
    
    init(_ symbolName: String, closure: (() -> Void)? = nil) {
        self.symbolName = symbolName
        self.closure = closure
    }
    
    var body: some View {
        Button {
            closure?()
        } label: {
            Image(systemName: symbolName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(.horizontal, 12)
        }
        .buttonStyle(CustomButtonStyle())
    }
}
