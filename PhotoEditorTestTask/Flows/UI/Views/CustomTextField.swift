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
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomTextField(title: title, text: $text, isValid: error == nil)
            
            Text(error ?? "" )
                .accentText()
                .padding(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
