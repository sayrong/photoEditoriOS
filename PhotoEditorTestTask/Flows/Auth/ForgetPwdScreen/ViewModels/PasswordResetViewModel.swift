//
//  PasswordResetViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 25.04.2025.
//

import SwiftUI

protocol PasswordResetCoordinatorDelegate: AnyObject {
    func passwordResetDidComplete(with message: AlertMessage)
    func passwordResetDidFail(with message: AlertMessage)
    func passwordResetDidCancel()
}

class PasswordResetViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    
    private weak var delegate: PasswordResetCoordinatorDelegate?
    private var validator: IUserCredentialsValidator
    private var authService: IAuthService
    
    init(delegate: PasswordResetCoordinatorDelegate, validator: IUserCredentialsValidator, authService: IAuthService) {
        self.delegate = delegate
        self.validator = validator
        self.authService = authService
    }
    
    var canSubmit: Bool {
        validator.isValidEmail(email) && !isLoading
    }
    
    var emailValidationMessage: String? {
        return email.isEmpty || validator.isValidEmail(email) ? nil : L10n.incorrectEmail
    }
    
    func resetPassword() {
        guard canSubmit else { return }
        
        isLoading = true
        
        Task { [weak self] in
            guard let self else { return }
            
            let result = await authService.sendPasswordReset(withEmail: email)
            
            await MainActor.run {
                self.isLoading = false
                switch result {
                case .success:
                    let msg = AlertMessage(title: "", message: L10n.passwordResetHaveBeenSent)
                    self.delegate?.passwordResetDidComplete(with: msg)
                case .failure(let authError):
                    let error = AlertMessage(title: L10n.error, message: authError.userMessage)
                    self.delegate?.passwordResetDidFail(with: error)
                }
            }
        }
    }
    
    func cancel() {
        delegate?.passwordResetDidCancel()
    }
}
