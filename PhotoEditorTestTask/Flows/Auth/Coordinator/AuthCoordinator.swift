//
//  AuthCoordinator.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 21.04.2025.
//

import SwiftUI

struct AlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

final class AuthCoordinator: ObservableObject {
    
    enum Route: Identifiable {
        var id: Self { self }

        case login
        case forgotPassword
        case register
    }
    
    @Published var path: [Route] = []
    @Published var presentedSheet: Route?
    @Published var mainAlertMessage: AlertMessage?
    @Published var sheetAlertMessage: AlertMessage?
    
    var afterSheetClose: (() -> Void)?
    
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
            passwordResetView()
        case .register:
            registerView()
        }
    }

    private func loginView() -> some View {
        moduleFactory.makeLoginModule(delegate: self)
    }
    
    private func registerView() -> some View {
        moduleFactory.makeRegisterModule(delegate: self)
    }
    
    private func passwordResetView() -> some View {
        moduleFactory.makePasswordResetModule(delegate: self)
    }
    
    // MARK: Navigation
    private func navigateTo(destination: Route) {
        path.append(destination)
    }
    
    private func navigateBack() {
        path.removeLast()
    }
    
    // MARK: Alert
    private func showMainAlert(_ message: AlertMessage) {
        mainAlertMessage = message
    }
    
    private func showSheetAlert(_ message: AlertMessage) {
        sheetAlertMessage = message
    }
    
    private func showAlertAfterSheetClose(_ message: AlertMessage) {
        afterSheetClose = { [weak self] in
            self?.showMainAlert(message)
            self?.afterSheetClose = nil
        }
        presentedSheet = nil
    }
}

extension AuthCoordinator: LoginCoordinatorDelegate {
    func loginDidComplete() {
        onFinish?()
    }
    
    func forgotPasswordRequested() {
        presentedSheet = .forgotPassword
    }
    
    func registrationRequested() {
        navigateTo(destination: .register)
    }
    
    func loginDidFail(with message: AlertMessage) {
        showMainAlert(message)
    }
}

extension AuthCoordinator: RegistrationCoordinatorDelegate {
    
    func registerDidComplete() {
        onFinish?()
    }
    
    func registrationDidFail(with message: AlertMessage) {
        showMainAlert(message)
    }
}

extension AuthCoordinator: PasswordResetCoordinatorDelegate {
    func passwordResetDidComplete(with message: AlertMessage) {
        showAlertAfterSheetClose(message)
    }
    
    func passwordResetDidFail(with message: AlertMessage) {
        showSheetAlert(message)
    }
    
    func passwordResetDidCancel() {
        presentedSheet = nil
    }
}
