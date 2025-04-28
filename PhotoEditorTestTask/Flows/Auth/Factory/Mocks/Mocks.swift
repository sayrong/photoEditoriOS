//
//  Untitled.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 25.04.2025.
//

final class MockRegistrationCoordinatorDelegate: RegistrationCoordinatorDelegate {
    func registerDidComplete() {}
    func registrationDidFail(with message: AlertMessage) {}
}

final class MockLoginCoordinatorDelegate: LoginCoordinatorDelegate {
    func loginDidFail(with message: AlertMessage) {}
    func loginDidComplete() {}
    func forgotPasswordRequested() {}
    func registrationRequested() {}
}

final class MockPasswordResetCoordinatorDelegate: PasswordResetCoordinatorDelegate {
    func passwordResetDidCancel() {}
    func passwordResetDidComplete(with message: AlertMessage) {}
    func passwordResetDidFail(with message: AlertMessage) {}
}

final class MockValidator: IUserCredentialsValidator {
    func isValidEmail(_ email: String) -> Bool {
        return false
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return false
    }
}

final class MockAuthService: IAuthService {
    func sendPasswordReset(withEmail email: String) async -> Result<Void, AuthError> {
        return .success(())
    }
    
    func signInWithGoogle(presentingControllerProvider: any PresentingControllerProvider) async -> Result<User, AuthError> {
        return .success(User(id: "124", email: "vv@qq.com"))
    }
    
    func login(_ email: String, _ password: String) async -> Result<User, AuthError> {
        return .success(User(id: "124", email: "vv@qq.com"))
    }
    
    func isEmailValidForRegistration(_ email: String) async -> Result<Bool, AuthError> {
        return .success(true)
    }
    
    func register(_ email: String, _ password: String) async -> Result<User, AuthError> {
        return .success(User(id: "124", email: "vv@qq.com"))
    }
}

extension RegistrationViewModel {
    static func preview() -> RegistrationViewModel {
        RegistrationViewModel(delegate: MockRegistrationCoordinatorDelegate(),
                                                       validator: MockValidator(),
                                                       authService: MockAuthService())
    }
}

extension LoginViewModel {
    static func preview() -> LoginViewModel {
        LoginViewModel(delegate: MockLoginCoordinatorDelegate(),
                       validator: MockValidator(),
                       authService: MockAuthService())
    }
}

extension PasswordResetViewModel {
    static func preview() -> PasswordResetViewModel {
        PasswordResetViewModel(delegate: MockPasswordResetCoordinatorDelegate(),
                               validator: MockValidator(),
                               authService: MockAuthService())
    }
}
