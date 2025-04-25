//
//  Untitled.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 25.04.2025.
//

final class MockRegistrationCoordinatorDelegate: RegistrationCoordinatorDelegate {
    func registerDidComplete() {}
    func registrationDidFail(with error: String) {}
}

final class MockLoginCoordinatorDelegate: LoginCoordinatorDelegate {
    func loginDidFail(with error: String) {}
    func loginDidComplete() {}
    func forgotPasswordRequested() {}
    func registrationRequested() {}
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
