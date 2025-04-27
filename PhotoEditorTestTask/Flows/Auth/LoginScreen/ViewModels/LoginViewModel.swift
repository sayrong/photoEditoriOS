//
//  LoginViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 21.04.2025.
//
import Combine

protocol LoginCoordinatorDelegate: AnyObject {
    func loginDidComplete()
    func forgotPasswordRequested()
    func registrationRequested()
    func loginDidFail(with message: AlertMessage)
}

final class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoadingState: Bool = false
    
    var canSubmitForm: Bool {
        validator.isValidEmail(email) && validator.isValidPassword(password)
    }
    
    var isEmailFieldCorrect: Bool {
        email.isEmpty || validator.isValidEmail(email)
    }
    
    var isPasswordFieldCorrect: Bool {
        password.isEmpty || validator.isValidPassword(password)
    }
    
    private weak var delegate: LoginCoordinatorDelegate?
    private var validator: IUserCredentialsValidator
    private var authService: IAuthService
    
    init(delegate: LoginCoordinatorDelegate?, validator: IUserCredentialsValidator, authService: IAuthService) {
        self.delegate = delegate
        self.validator = validator
        self.authService = authService
    }
    
    func signInWithGoogle() {
        
    }

    func logInDidTap() {
        isLoadingState = true
        
        Task { [weak self] in
            guard let self else { return }
            
            let result = await authService.login(email, password)
            
            await MainActor.run {
                self.isLoadingState = false
                switch result {
                case .success:
                    self.delegate?.loginDidComplete()
                case .failure(let authError):
                    let error = AlertMessage(title: L10n.error, message: authError.userMessage)
                    self.delegate?.loginDidFail(with: error)
                }
            }
        }
    }
    
    func forgotPwdDidTap() {
        delegate?.forgotPasswordRequested()
    }
    
    func registrationDidTap() {
        delegate?.registrationRequested()
    }
}
