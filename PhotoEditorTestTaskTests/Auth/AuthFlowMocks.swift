//
//  AuthFlowMocks.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 17.05.2025.
//

import UIKit
@testable import PhotoEditorTestTask

class MockValidator: IUserCredentialsValidator {
    var emailValid = true
    var passwordValid = true
    func isValidEmail(_ email: String) -> Bool { emailValid }
    func isValidPassword(_ password: String) -> Bool { passwordValid }
}

final class MockAuthService: IAuthService {
    var currentUserStub: User? = nil
    var loginResult: Result<User, AuthError> = .failure(.invalidCredentials)
    var googleSignInResult: Result<User, AuthError> = .failure(.invalidCredentials)
    var registerResult: Result<User, AuthError> = .failure(.invalidCredentials)
    var passwordResetResult: Result<Void, AuthError> = .failure(.networkError)
    var emailValidForRegistrationResult: Result<Bool, AuthError> = .success(true)
    
    var addAuthStateChangeListenerHandler: ((AuthStateChangeHandler) -> AuthStateListenerHandle)?
    var removeAuthStateChangeListenerHandler: ((AuthStateListenerHandle) -> Void)?
    var refreshUserTokenCalled = false

    func currentUser() -> User? {
        return currentUserStub
    }
    
    func login(_ email: String, _ password: String) async -> Result<User, AuthError> {
        return loginResult
    }
    
    func signInWithGoogle(presentingControllerProvider: PresentingControllerProvider) async -> Result<User, AuthError> {
        return googleSignInResult
    }
    
    func register(_ email: String, _ password: String) async -> Result<User, AuthError> {
        return registerResult
    }
    
    func sendPasswordReset(withEmail email: String) async -> Result<Void, AuthError> {
        return passwordResetResult
    }
    
    func isEmailValidForRegistration(_ email: String) async -> Result<Bool, AuthError> {
        return emailValidForRegistrationResult
    }
    
    func addAuthStateChangeListener(_ handler: @escaping AuthStateChangeHandler) -> AuthStateListenerHandle {
        return addAuthStateChangeListenerHandler?(handler) ?? UUID()
    }
    
    func removeAuthStateChangeListener(_ handle: AuthStateListenerHandle) {
        removeAuthStateChangeListenerHandler?(handle)
    }
    
    func refreshUserToken() {
        refreshUserTokenCalled = true
    }
}

class MockDelegate: LoginCoordinatorDelegate {
    var didComplete = false
    var didFail: AlertMessage?
    var didRequestForgot = false
    var didRequestRegistration = false
    var didCompleteHandler: (() -> Void)?
    var didFailHandler: ((AlertMessage) -> Void)?

    func loginDidComplete() {
        didComplete = true
        didCompleteHandler?()
    }
    func forgotPasswordRequested() { didRequestForgot = true }
    func registrationRequested() { didRequestRegistration = true }
    func loginDidFail(with message: AlertMessage) {
        didFail = message
        didFailHandler?(message)
    }
}
