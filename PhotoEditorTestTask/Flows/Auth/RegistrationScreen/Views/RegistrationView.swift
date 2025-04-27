//
//  RegistrationView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 23.04.2025.
//

import SwiftUI

struct RegistrationView: View {
    
    @ObservedObject private var viewModel: RegistrationViewModel
    
    init(viewModel: RegistrationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            header()
            registrationFields()
            registerButton()
            Spacer()
        }
        .padding()
        .background(Asset.Colors.background.swiftUIColor)
        .loadingOverlay(viewModel.isLoadingState)
        .adaptiveFrame()
    }
    
    private func header() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(Asset.Colors.secondaryAccent.swiftUIColor)
                .padding(.bottom, 8)
            
            Text(L10n.createAccount)
                .titleText()
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(L10n.fillDetailsToCreateANewAccount)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func registrationFields() -> some View {
        VStack(spacing: 10) {
            EmailTextFieldWithError(title: L10n.email,
                                    text: $viewModel.email,
                                    error: viewModel.emailValidationError,
                                    isValidating: $viewModel.isEmailChecking)
            
            CustomSecureFieldWithError(title: L10n.password,
                                       text: $viewModel.password,
                                       error: viewModel.passwordValidationError)
            
            CustomSecureFieldWithError(title: L10n.confirmPassword,
                                       text: $viewModel.confirmPassword,
                                       error: viewModel.confirmPasswordValidationError)
            
        }
        .padding(.horizontal)
    }
    
    private func registerButton() -> some View {
        Button {
            viewModel.registerUser()
        } label: {
            Text(L10n.register)
        }
        .primaryButtonStyle()
        .disabled(!viewModel.canSubmitForm)
        .opacity(!viewModel.canSubmitForm ? 0.5 : 1.0)
    }
}

#Preview {
    RegistrationView(viewModel: .preview())
}
