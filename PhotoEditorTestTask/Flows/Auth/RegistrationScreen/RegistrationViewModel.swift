//
//  RegistrationViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 24.04.2025.
//

import Combine
import Foundation

protocol RegistrationCoordinatorDelegate: AnyObject {
    func registerDidComplete()
    func registrationDidFail(with message: AlertMessage)
}

final class RegistrationViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var emailValidationError: String?
    @Published var passwordValidationError: String?
    @Published var confirmPasswordValidationError: String?
    
    @Published var isEmailChecking: Bool = false
    @Published var isLoadingState: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var canSubmitForm: Bool {
        validator.isValidEmail(email)
            && validator.isValidPassword(password)
            && confirmPassword == password
            && emailValidationError == nil
    }
    
    private weak var delegate: RegistrationCoordinatorDelegate?
    private var validator: IUserCredentialsValidator
    private var authService: IAuthService
    
    init(delegate: RegistrationCoordinatorDelegate, validator: IUserCredentialsValidator, authService: IAuthService) {
        self.delegate = delegate
        self.validator = validator
        self.authService = authService
        emailValidationSetup()
        passwordValidationSetup()
        confirmPasswordValidationSetup()
    }
    
    func registerUser() {
        isLoadingState = true
        
        Task { [weak self] in
            guard let self else { return }
            
            let result = await authService.register(email, password)
            
            await MainActor.run {
                self.isLoadingState = false
                switch result {
                case .success:
                    self.delegate?.registerDidComplete()
                case .failure(let authError):
                    let error = AlertMessage(title: L10n.error, message: authError.userMessage)
                    self.delegate?.registrationDidFail(with: error)
                }
            }
        }
    }
    
    // MARK: Fields Validation
    private func emailValidationSetup() {
        $email
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] email in
                guard let self else { return }
                
                guard !email.isEmpty else {
                    self.emailValidationError = nil
                    return
                }
                
                guard self.validator.isValidEmail(email) else {
                    self.emailValidationError = L10n.incorrectEmail
                    return
                }
                self.emailValidationError = nil
                self.isEmailChecking = true
                
                Task {
                    let result = await self.authService.isEmailValidForRegistration(email)
                    await MainActor.run { self.isEmailChecking = false }
                    switch result {
                    case .success(let isValid):
                        if !isValid {
                            await MainActor.run {
                                self.emailValidationError = L10n.emailSAlreadyTaken
                            }
                        }
                    case .failure:
                        await MainActor.run {
                            self.emailValidationError = L10n.serverError
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func passwordValidationSetup() {
        $password
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] password in
                guard let self else { return }
                
                guard !password.isEmpty else {
                    self.passwordValidationError = nil
                    return
                }
                
                guard self.validator.isValidPassword(password) else {
                    self.passwordValidationError = L10n.incorrectPassword
                    return
                }
                self.passwordValidationError = nil
            }
            .store(in: &cancellables)
    }
    
    private func confirmPasswordValidationSetup() {
        $confirmPassword
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] password in
                guard let self else { return }
                
                guard !password.isEmpty else {
                    self.confirmPasswordValidationError = nil
                    return
                }
                
                guard self.validator.isValidPassword(password) else {
                    self.confirmPasswordValidationError = L10n.incorrectPassword
                    return
                }
                guard password == self.password else {
                    self.confirmPasswordValidationError = L10n.passwordsDonTMatch
                    return
                }
                
                self.confirmPasswordValidationError = nil
            }
            .store(in: &cancellables)
    }
}
