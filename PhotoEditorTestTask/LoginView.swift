//
//  ContentView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 18.04.2025.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            header
            singInWith
            orDivider
            credentialsForm($email, $password)
            Spacer()
        }
        .padding()
        //Limit size to adapt to iPad
        .frame(maxWidth: 400, maxHeight: 800, alignment: .center)
    }
    
    private var header: some View {
        VStack {
            Text(L10n.signIn)
                .titleText()
                .padding(.vertical)
            Text(L10n.welcomeMessage)
                .captionText()
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var singInWith: some View {
        Button {
            
        } label: {
            HStack(spacing: 8) {
                Asset.Images.iconGoogle.swiftUIImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                
                Text(L10n.signInWithGoogle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Asset.Colors.secondaryText.swiftUIColor)
            }
        }
        .signInButtonStyle()
    }
    
    private var orDivider: some View {
        HStack {
            line
            Text(L10n.or)
                .captionText()
            line
        }
    }

    private var line: some View {
        VStack {
            Divider()
                .background(.gray)
        }
        .padding(20)
    }
    
    private func credentialsForm(_ email: Binding<String>, _ pwd: Binding<String>) -> some View {
        VStack {
            TextField(L10n.email, text: $email)
                .textFieldStyle(.roundedBorder)
            TextField(L10n.password, text: $password)
                .textFieldStyle(.roundedBorder)
            HStack {
                Spacer()
                forgetPasswordAction
            }.padding()
            logInButton
            dontHaveAccountBlock
                .padding()
        }
    }
    
    private var forgetPasswordAction: some View {
        Button {
            
        } label: {
            Text(L10n.forgetPassword)
                .captionText()
        }
    }
    
    private var logInButton: some View {
        Button {
            
        } label: {
            Text(L10n.logIn)
        }
        .primaryButtonStyle()
    }
    
    private var dontHaveAccountBlock: some View {
        HStack {
            Text(L10n.donTHaveAccount)
                .captionText()
            Button {
                
            } label: {
                Text(L10n.signUp)
                    .accentText()
            }
        }
    }
}

#Preview {
    LoginView()
}
