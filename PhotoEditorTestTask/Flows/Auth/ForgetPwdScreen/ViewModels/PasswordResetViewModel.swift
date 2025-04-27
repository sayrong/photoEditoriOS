//
//  PasswordResetViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 25.04.2025.
//

import SwiftUI

protocol PasswordResetCoordinatorDelegate: AnyObject {
    func passwordResetDidComplete()
    func registrationDidFail(with error: String)
}

class PasswordResetViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    @Published var emailValidationMessage = ""
    
    private weak var delegate: RegistrationCoordinatorDelegate?
    private var validator: IUserCredentialsValidator
    
    init(delegate: RegistrationCoordinatorDelegate, validator: IUserCredentialsValidator) {
        self.delegate = delegate
        self.validator = validator
    }
    
    var canSubmit: Bool {
        validator.isValidEmail(email) && !isLoading
    }
    
    func resetPassword() {
        guard canSubmit else { return }
        
        isLoading = true
        
        // Simulate API call
    }
    
    // "We couldn't find an account with that email address. Please check and try again."
    //title - "Password Reset"
    //msg - "Password reset instructions have been sent to your email."
    
    //title - "Error"
    //msg - viewModel.errorMessage
}
