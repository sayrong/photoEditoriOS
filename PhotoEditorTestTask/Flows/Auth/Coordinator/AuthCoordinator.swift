//
//  AuthCoordinator.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 21.04.2025.
//

import SwiftUI

final class AuthCoordinator: ObservableObject {
    
    enum Route: Identifiable {
        var id: Self { self }

        case login
        case forgotPassword
        case register
    }
    
    @Published var path: [Route] = []
    @Published var presentedSheet: Route?
    
    private var moduleFactory: IAuthModuleFactory
    private var onFinish: (() -> Void)?
    
    init(
        moduleFactory: IAuthModuleFactory,
        onFinish: (() -> Void)? = nil
    ) {
        self.moduleFactory = moduleFactory
        self.onFinish = onFinish
    }
    
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .login:
            loginView()
        case .forgotPassword:
            Text("Forgot")
        case .register:
            Text("Register")
        }
    }

    private func loginView() -> some View {
        moduleFactory.makeLoginModule(delegate: self)
    }
    
    // MARK: Navigation
    private func navigateTo(destination: Route) {
        path.append(destination)
    }
    
    private func navigateBack() {
        path.removeLast()
    }
}

extension AuthCoordinator: LoginModuleDelegate {
    func loginDidComplete() {
        navigateTo(destination: .login)
    }
    
    func forgotPasswordRequested() {
        presentedSheet = .forgotPassword
    }
    
    func registrationRequested() {
        navigateTo(destination: .register)
    }
}
