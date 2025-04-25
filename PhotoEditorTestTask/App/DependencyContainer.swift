//
//  DependencyContainer.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 21.04.2025.
//

class DependencyContainer {
    static let shared = DependencyContainer()
    
    private var authServiceInstance: IAuthService?
    
    func authService() -> IAuthService {
        if authServiceInstance == nil {
            authServiceInstance = FirebaseAuthService()
        }
        return authServiceInstance!
    }
    
    func resetServices() {
        authServiceInstance = nil
    }
}
