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
    
    init(container: DependencyContainer = .shared) {
        self.container = container
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
            Text("Main Flow")
        }
    }
    
    private func getAuthCoordinatorView() -> some View {
        AuthCoordinatorView(coordinator: authCoordinator)
    }
    
    private func switchToMain() {
        currentFlow = .main
    }
    
    private func switchToAuth() {
        currentFlow = .auth
    }
}
