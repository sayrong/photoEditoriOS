//
//  AuthModuleFactory.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 22.04.2025.
//

protocol IAuthModuleFactory {
    func makeLoginModule(delegate: LoginCoordinatorDelegate) -> LoginView
    func makeRegisterModule(delegate: RegistrationCoordinatorDelegate) -> RegistrationView
}

class AuthModuleFactory: IAuthModuleFactory {
    
    private let container: DependencyContainer
        
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func makeLoginModule(delegate: LoginCoordinatorDelegate) -> LoginView {
        let viewModel = LoginViewModel(delegate: delegate,
                                       validator: UserCredentialsValidator(),
                                       authService: container.authService() )
        return LoginView(viewModel: viewModel)
    }
    
    func makeRegisterModule(delegate: RegistrationCoordinatorDelegate) -> RegistrationView {
        let viewModel = RegistrationViewModel(delegate: delegate,
                                              validator: UserCredentialsValidator(),
                                              authService: container.authService())
        return RegistrationView(viewModel: viewModel)
    }
}
