//
//  CustomTextField.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 24.04.2025.
//

import SwiftUI

struct CustomTextField: View {
    
    let title: String
    @Binding var text: String
    let isValid: Bool
    
    var body: some View {
        TextField(title, text: $text)
            .autocorrectionDisabled(true)
            #if !os(macOS)
            .textInputAutocapitalization(.never)
            #endif
            .keyboardType(.emailAddress)
            .textFieldStyle(.roundedBorder)
            .errorBorder(isValid: isValid)
    }
}

struct CustomTextFieldWithError: View {
    
    let title: String
    @Binding var text: String
    var error: String?
    @Binding var isValidating: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomTextField(title: title, text: $text, isValid: error == nil)
                .overlay(alignment: .trailing) {
                    ProgressView()
                        .padding(.trailing, 8)
                        .opacity(isValidating ? 1 : 0)
                }
            
            Text(error ?? "Error" )
                .accentText()
                .padding(.leading)
                .opacity(error == nil ? 0 : 1)
        }
    }
}
