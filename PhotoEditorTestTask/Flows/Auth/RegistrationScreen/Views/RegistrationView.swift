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
        .loadingOverlay(viewModel.isLoadingState)
    }
    
    private func header() -> some View {
        Text(L10n.createAccount)
            .titleText()
            .padding(.vertical)
    }
    
    private func registrationFields() -> some View {
        VStack(spacing: 10) {
            CustomTextFieldWithError(title: L10n.email,
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
