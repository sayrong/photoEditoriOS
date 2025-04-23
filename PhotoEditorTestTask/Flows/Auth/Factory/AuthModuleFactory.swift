//
//  AuthModuleFactory.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 22.04.2025.
//

protocol IAuthModuleFactory {
    func makeLoginModule(delegate: LoginModuleDelegate) -> LoginView
}

class AuthModuleFactory: IAuthModuleFactory {
    
    private let container: DependencyContainer
        
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func makeLoginModule(delegate: LoginModuleDelegate) -> LoginView {
        let viewModel = LoginViewModel(delegate: delegate, validator: UserCredentialsValidator())
        return LoginView(viewModel: viewModel)
    }
}
