//
//  LoginViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 21.04.2025.
//
import Combine

protocol LoginModuleDelegate: AnyObject {
    func loginDidComplete()
    func forgotPasswordRequested()
    func registrationRequested()
}


class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    var canSubmitForm: Bool {
        validator.isValidEmail(email) && validator.isValidPassword(password)
    }
    
    var isEmailFieldCorrect: Bool {
        email.isEmpty || validator.isValidEmail(email)
    }
    
    var isPasswordFieldCorrect: Bool {
        password.isEmpty || validator.isValidPassword(password)
    }
    
    private weak var delegate: LoginModuleDelegate?
    private var validator: IUserCredentialsValidator
    
    init(delegate: LoginModuleDelegate?, validator: IUserCredentialsValidator) {
        self.delegate = delegate
        self.validator = validator
    }
    
    func signInWithGoogle() {
        
    }
    
    func logInDidTap() {
        delegate?.loginDidComplete()
    }
    
    func forgotPwdDidTap() {
        delegate?.forgotPasswordRequested()
    }
    
    func registrationDidTap() {
        delegate?.registrationRequested()
    }
}

#if DEBUG
extension LoginViewModel {
    static var preview: LoginViewModel {
        LoginViewModel(delegate: nil, validator: UserCredentialsValidator())
    }
}
#endif

