//
//  CustomSecureField.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 24.04.2025.
//

import SwiftUI

struct CustomSecureField: View {
    
    let title: String
    @Binding var text: String
    let isValid: Bool
    @State var isPasswordVisible: Bool = false
    
    var body: some View {
        HStack {
            if isPasswordVisible {
                CustomTextField(title: title, text: $text, isValid: isValid)
            } else {
                SecureField(title, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .errorBorder(isValid: isValid)
            }
        }.overlay(alignment: .trailing) {
            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(.gray)
                    .padding(.trailing, 8)
            }
            .padding(.trailing)
        }
    }
}

struct CustomSecureFieldWithError: View {
    let title: String
    @Binding var text: String
    var error: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomSecureField(title: title, text: $text, isValid: error == nil)
            
            Text(error ?? "Error" )
                .accentText()
                .padding(.leading)
                .opacity(error == nil ? 0 : 1)
        }
    }
}
