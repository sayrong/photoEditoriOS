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
            Image(systemName: "lock.fill")
                .foregroundColor(.gray)
                .frame(width: 20)

            Group {
                if isPasswordVisible {
                    TextField(title, text: $text)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    SecureField(title, text: $text)
                }
            }
            .frame(minHeight: 22)
            
            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .errorBorder(text: $text, isValid: isValid)
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

#Preview {
    VStack(spacing: 30) {
        CustomSecureField(title: "Password", text: .constant(""), isValid: true)
        
        CustomSecureFieldWithError(title: "Password", text: .constant("12345"),
                                   error: "Error Message")
    }
    .frame(maxHeight: .infinity)
    .padding()
    .background(Asset.Colors.background.swiftUIColor)
}
