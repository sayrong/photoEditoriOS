//
//  Untitled.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 25.04.2025.
//

final class PMockRegistrationCoordinatorDelegate: RegistrationCoordinatorDelegate {
    func registerDidComplete() {}
    func registrationDidFail(with message: AlertMessage) {}
}

final class PMockLoginCoordinatorDelegate: LoginCoordinatorDelegate {
    func loginDidFail(with message: AlertMessage) {}
    func loginDidComplete() {}
    func forgotPasswordRequested() {}
    func registrationRequested() {}
}

final class PMockPasswordResetCoordinatorDelegate: PasswordResetCoordinatorDelegate {
    func passwordResetDidCancel() {}
    func passwordResetDidComplete(with message: AlertMessage) {}
    func passwordResetDidFail(with message: AlertMessage) {}
}

final class PMockValidator: IUserCredentialsValidator {
    func isValidEmail(_ email: String) -> Bool {
        return false
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return false
    }
}

final class PMockAuthService: IAuthService {
    func currentUser() -> User? {
        return User(id: "124", email: "vv@qq.com")
    }
    
    func refreshUserToken() { }
    
    func addAuthStateChangeListener(_ handler: @escaping AuthStateChangeHandler) -> AuthStateListenerHandle {
        return .init()
    }
    
    func removeAuthStateChangeListener(_ handle: AuthStateListenerHandle) { }
    
    func sendPasswordReset(withEmail email: String) async -> Result<Void, AuthError> {
        return .success(())
    }
    
    func signInWithGoogle(presentingControllerProvider: any PresentingControllerProvider) async -> Result<User, AuthError> {
        return .success(User(id: "124", email: "vv@qq.com"))
    }
    
    func login(_ email: String, _ password: String) async -> Result<User, AuthError> {
        return .success(User(id: "124", email: "vv@qq.com"))
    }
    
    func logout() async -> Result<Void, AuthError> {
        return .success(())
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
        RegistrationViewModel(delegate: PMockRegistrationCoordinatorDelegate(),
                                                       validator: PMockValidator(),
                                                       authService: PMockAuthService())
    }
}

extension LoginViewModel {
    static func preview() -> LoginViewModel {
        LoginViewModel(delegate: PMockLoginCoordinatorDelegate(),
                       validator: PMockValidator(),
                       authService: PMockAuthService())
    }
}

extension PasswordResetViewModel {
    static func preview() -> PasswordResetViewModel {
        PasswordResetViewModel(delegate: PMockPasswordResetCoordinatorDelegate(),
                               validator: PMockValidator(),
                               authService: PMockAuthService())
    }
}
