//
//  EmailTextField.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 24.04.2025.
//

import SwiftUI

struct EmailTextField: View {
    
    let title: String
    @Binding var text: String
    let isValid: Bool
    var iconName: String?
    
    var body: some View {
        HStack {
            Image(systemName: "envelope")
                .foregroundColor(.gray)
            
            TextField(title, text: $text)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .errorBorder(text: $text, isValid: isValid)
    }
}

struct EmailTextFieldWithError: View {
    
    let title: String
    @Binding var text: String
    var error: String?
    @Binding var isValidating: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            EmailTextField(title: title, text: $text, isValid: error == nil)
                .overlay(alignment: .trailing) {
                    ProgressView()
                        .padding(.trailing, 12)
                        .opacity(isValidating ? 1 : 0)
                }
            
            Text(error ?? "Error" )
                .accentText()
                .padding(.leading)
                .opacity(error == nil ? 0 : 1)
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        EmailTextField(title: "Email", text: .constant(""), isValid: true)
        
        EmailTextFieldWithError(title: "Type", text: .constant("abc"),
                                 error: "Error Message", isValidating: .constant(true))
    }
    .frame(maxHeight: .infinity)
    .padding()
    .background(Asset.Colors.background.swiftUIColor)
    
}
