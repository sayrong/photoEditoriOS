//
//  AppCoordinator.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 21.04.2025.
//

import SwiftUI

final class AppCoordinator: ObservableObject {
    
    enum AppFlow {
        case auth
        case main
    }
    
    @Published var currentFlow: AppFlow = .auth
    
    private let container: DependencyContainer
    private var authService: IAuthService?
    private var authStateListenerHandle: AuthStateListenerHandle?
    
    init(container: DependencyContainer = .shared) {
        self.container = container
        self.authService = container.authService()
        updateCurrentFlow()
        subscribeToAuthStateChanges()
    }

    private lazy var authCoordinator = AuthCoordinator(
        moduleFactory: AuthModuleFactory(container: container),
        onFinish: { [weak self] in self?.switchToMain() }
    )
    
    @ViewBuilder
    var rootView: some View {
        switch currentFlow {
        case .auth:
            getAuthCoordinatorView()
        case .main:
            getMainCoordinatorView()
        }
    }
    
    private func getAuthCoordinatorView() -> some View {
        AuthCoordinatorView(coordinator: authCoordinator)
    }
    
    private func getMainCoordinatorView() -> some View {
        MainCoordinatorView(coordinator: MainCoordinator())
    }
    
    private func switchToMain() {
        currentFlow = .main
    }
    
    private func switchToAuth() {
        currentFlow = .auth
    }
    
    private func updateCurrentFlow() {
        if let user = authService?.currentUser() {
            switchToMain()
        } else {
            switchToAuth()
        }
    }
    
    private func subscribeToAuthStateChanges() {
        authStateListenerHandle = authService?.addAuthStateChangeListener { [weak self] user in
            guard let self = self else { return }

            if user != nil {
                self.switchToMain()
            } else {
                self.switchToAuth()
            }
        }
        
        // Workaround to get actual token state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.authService?.refreshUserToken()
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            authService?.removeAuthStateChangeListener(handle)
        }
    }
}
