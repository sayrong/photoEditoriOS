//
//  AuthModuleFactory.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 22.04.2025.
//

protocol IAuthModuleFactory {
    func makeLoginModule(delegate: LoginCoordinatorDelegate) -> LoginView
    func makeRegisterModule() -> RegistrationView
}

class AuthModuleFactory: IAuthModuleFactory {
    
    private let container: DependencyContainer
        
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func makeLoginModule(delegate: LoginCoordinatorDelegate) -> LoginView {
        let viewModel = LoginViewModel(delegate: delegate, validator: UserCredentialsValidator())
        return LoginView(viewModel: viewModel)
    }
    
    func makeRegisterModule() -> RegistrationView {
        let authService = FirebaseAuthService()
        let viewModel = RegistrationViewModel(validator: UserCredentialsValidator(),
                                              authService: authService)
        return RegistrationView(viewModel: viewModel)
    }
}
