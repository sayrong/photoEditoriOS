//
//  ContentView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 18.04.2025.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Spacer()
            header
            singInWith
            orDivider
            credentialsForm($viewModel.email, $viewModel.password)
            Spacer()
        }
        .padding()
        .background(Asset.Colors.background.swiftUIColor)
        .loadingOverlay(viewModel.isLoadingState)
        .adaptiveFrame()
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
            viewModel.signInWithGoogle()
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
        VStack(spacing: 20) {
            EmailTextField(title: L10n.email,
                           text: email,
                           isValid: viewModel.isEmailFieldCorrect)
            CustomSecureField(title: L10n.password,
                              text: pwd,
                              isValid: viewModel.isPasswordFieldCorrect)
            HStack {
                Spacer()
                forgetPasswordAction
            }
            
            logInButton
            dontHaveAccountBlock
        }
    }
    
    private var forgetPasswordAction: some View {
        Button {
            viewModel.forgotPwdDidTap()
        } label: {
            Text(L10n.forgetPassword)
                .captionText()
        }
    }
    
    private var logInButton: some View {
        Button {
            viewModel.logInDidTap()
        } label: {
            Text(L10n.logIn)
        }
        .primaryButtonStyle()
        .disabled(!viewModel.canSubmitForm)
        .opacity(!viewModel.canSubmitForm ? 0.5 : 1.0)
    }
    
    private var dontHaveAccountBlock: some View {
        HStack {
            Text(L10n.donTHaveAccount)
                .captionText()
            Button {
                viewModel.registrationDidTap()
            } label: {
                Text(L10n.signUp)
                    .accentText()
            }
        }
    }
}

#Preview {
    LoginView(viewModel: .preview())
}
