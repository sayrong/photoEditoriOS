//
//  RegistrationViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 24.04.2025.
//

import Combine
import Foundation

final class RegistrationViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var emailValidationError: String?
    @Published var passwordValidationError: String?
    @Published var confirmPasswordValidationError: String?
    
    @Published var isEmailChecking: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var canSubmitForm: Bool {
        validator.isValidEmail(email)
            && validator.isValidPassword(password)
            && confirmPassword == password
            && emailValidationError == nil
    }
    
    private var validator: IUserCredentialsValidator
    private var authService: IAuthService
    
    init(validator: IUserCredentialsValidator, authService: IAuthService) {
        self.validator = validator
        self.authService = authService
        emailValidationSetup()
        passwordValidationSetup()
        confirmPasswordValidationSetup()
    }
    
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
                    self.emailValidationError = "Некорректный email"
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
                                self.emailValidationError = "Email уже занят"
                            }
                        }
                    case .failure:
                        await MainActor.run {
                            self.emailValidationError = "Ошибка сервера"
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
                    self.passwordValidationError = "Некорректный пароль"
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
                    self.confirmPasswordValidationError = "Некорректный пароль"
                    return
                }
                guard password == self.password else {
                    self.confirmPasswordValidationError = "Пароли не совпадают"
                    return
                }
                
                self.confirmPasswordValidationError = nil
            }
            .store(in: &cancellables)
    }
}
